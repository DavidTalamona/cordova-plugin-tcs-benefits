package ch.apnet.plugin.tcs;

import android.content.Context;
import android.location.Location;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import ch.apnet.module.tcs.android.TCSBenefitsDynamicLinksHandler;
import ch.apnet.module.tcs.android.TCSBenefitsModule;
import ch.tcs.android.tcsframework.components.TCSGPSComponent;
import ch.tcs.android.tcsframework.components.TCSKVStorage;
import ch.tcs.android.tcsframework.components.TCSPushComponent;
import ch.tcs.android.tcsframework.components.TCSUserComponent;
import ch.tcs.android.tcsframework.domain.model.login.Account;
import ch.tcs.android.tcsframework.managers.permissions.TCSAndroidPermissionManager;
import ch.tcs.android.tcsframework.providers.TCSComponentsProvider;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;


public class TCSPlugin extends CordovaPlugin {
	private static final String TAG = "TCSPlugin";

	private Context context;

	private TCSComponentsProvider tcsProvider;
	private TCSAndroidPermissionManager tcsPermission;
	private TCSKVStorage tcsStorage;
	private TCSBenefitsDynamicLinksHandler tcsLinks;
	private TCSPushComponent tcsPush;

	private boolean isTrackingLocation = false;

	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);

		this.context = this.cordova.getActivity().getApplicationContext();
		this.tcsProvider = TCSBenefitsModule.getTcsProvider();
		this.tcsPermission = TCSBenefitsModule.getTcsPermissionManager();
		this.tcsStorage = this.tcsProvider.provideKVComponent();
		this.tcsLinks = TCSBenefitsModule.getTcsLinksHandler();
		this.tcsPush = TCSBenefitsModule.getTcsPush();

		Log.d(TAG, "Finish Initializing TCSPlugin");
	}

	@Override
	public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

		if (action.equals("startTrackingLocationUpdates")) {
			startTrackingLocationUpdates(callbackContext);

		} else if (action.equals("stopTrackingLocationUpdates")) {
			stopTrackingLocationUpdates();

		} else if (action.equals("hasGpsPermission")) {
			boolean hasPermission = hasGpsPermission();
			callbackContext.success(hasPermission ? "1" : "0");

		} else if (action.equals("requestGpsPermission")) {
			boolean isPermissionGranted = requestGpsPermission();
			callbackContext.success(isPermissionGranted ? "1" : "0");

		} else if (action.equals("storageSave")) {
			storageSave(args.getString(0), args.getString(1));

		} else if (action.equals("storageLoad")) {
			String savedString = storageLoad(args.getString(0));
			callbackContext.success(savedString);

		} else if (action.equals("storageClear")) {
			storageClear(args.getString(0));

		} else if (action.equals("getMemberNumber")) {
			getMemberNumber(callbackContext);
		} else if (action.equals("registerDynamicLinks")) {
			tcsLinks.setCallbackContext(callbackContext);
		}
		return true;
	}

	private void startTrackingLocationUpdates(final CallbackContext cb) {
		isTrackingLocation = true;

		final TCSGPSComponent tcsGps = this.tcsProvider.provideGPSLocationComponent();
		tcsGps.startTrackingLocationUpdates(this.cordova.getActivity(), new Function1<Location, Unit>() {
			@Override
			public Unit invoke(Location location) {

				if (!isTrackingLocation) {
					tcsGps.stopTrackingLocationUpdates(this);
					return null;
				}

				JSONObject result = new JSONObject();

				try {
					result.put("latitude", location.getLatitude());
					result.put("longitude", location.getLongitude());
					result.put("accuracy", location.getAccuracy());

					cb.success(result);
				}
				catch (JSONException ex) {}

				return null;
			}
		});
	}

	private void stopTrackingLocationUpdates() {
		isTrackingLocation = false;
	}

	private boolean hasGpsPermission() {
		return this.tcsPermission.isLocationPermissionGranted(this.context);
	}

	private boolean requestGpsPermission() {
		TCSBenefitsPermissionListener listener = new TCSBenefitsPermissionListener();
		this.tcsPermission.requestLocationPermission(this.cordova.getActivity(), "GPS Permission", listener);
		return listener.isPermissionGranted();
	}

	private void storageSave(String key, String value) {
		this.tcsStorage.setStringValue(key, value);
	}

	private String storageLoad(String key) {
		return this.tcsStorage.getStringValue(key, null);
	}

	private void storageClear(String key) {
		this.tcsStorage.removeValue(key);
	}

	private void getMemberNumber(final CallbackContext cb) {
		TCSUserComponent tcsUser = this.tcsProvider.provideUserComponent();
		if (tcsUser.isLoggedIn()) {
			tcsUser.getAccountInfo(new Function1<Account, Unit>() {
				@Override
				public Unit invoke(Account account) {
					cb.success(account.getPersonalReference()); //TODO: which info on account is the TCS member number?
					return null;
				}
			}, null); // function2 = errorCallback, we ignore this...
		}
		else {
			cb.success();
		}

	}

}