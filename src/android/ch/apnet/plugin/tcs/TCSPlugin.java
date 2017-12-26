package ch.apnet.plugin.tcs;

import android.content.Context;
import android.location.Location;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

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
import kotlin.jvm.functions.Function2;

public class TCSPlugin extends CordovaPlugin {
	private static final String TAG = "TCSPlugin";

	private Context context;

	private TCSComponentsProvider tcsProvider;
	private TCSAndroidPermissionManager tcsPermission;
	private TCSKVStorage tcsStorage;
	private TCSPushComponent tcsPush;
	private Function1<Location, Unit> gpsTrackingFunction;

	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);

		this.context = this.cordova.getActivity().getApplicationContext();
		this.tcsProvider = TCSBenefitsModule.getTcsProvider();
		this.tcsPermission = TCSBenefitsModule.getTcsPermissionManager();
		this.tcsStorage = this.tcsProvider.provideKVComponent();
		this.tcsPush = TCSBenefitsModule.getTcsPush();
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
			requestGpsPermission(args.getString(0), callbackContext);

		} else if (action.equals("storageSave")) {
			storageSave(args.getString(0), args.getString(1));

		} else if (action.equals("storageLoad")) {
			String savedString = storageLoad(args.getString(0));
			callbackContext.success(savedString);

		} else if (action.equals("storageClear")) {
			storageClear(args.getString(0));

		} else if (action.equals("getMemberInfo")) {
			getMemberInfo(callbackContext);

		} else if (action.equals("getStartupParameters")) {
			Log.d("startup", "startup");
			getStartupParameters(callbackContext);

		} else if (action.equals("getPushToken")) {
			tcsPush.subscribeOnPushTokenUpdates(new Function1<String, Unit>() {
				@Override
				public Unit invoke(String s) {
					PluginResult result = new PluginResult(PluginResult.Status.OK, s);
					result.setKeepCallback(true);
					callbackContext.sendPluginResult(result);
					return null;
				}
			});
		} else if (action.equals("navigateBack")) {
			this.cordova.getActivity().finish();
		}
		return true;
	}

	private void startTrackingLocationUpdates(final CallbackContext cb) {
		final TCSGPSComponent tcsGps = this.tcsProvider.provideGPSLocationComponent();
		this.gpsTrackingFunction = new Function1<Location, Unit>() {
			@Override
			public Unit invoke(Location location) {
				JSONObject gpsObj = new JSONObject();

				try {
					gpsObj.put("latitude", location.getLatitude());
					gpsObj.put("longitude", location.getLongitude());
					gpsObj.put("accuracy", location.getAccuracy());

					PluginResult result = new PluginResult(PluginResult.Status.OK, gpsObj);
					result.setKeepCallback(true);
					cb.sendPluginResult(result);

				}
				catch (JSONException ex) {}
				return null;
			}
		};

		tcsGps.startTrackingLocationUpdates(this.cordova.getActivity(), this.gpsTrackingFunction);
	}

	private void stopTrackingLocationUpdates() {
		final TCSGPSComponent tcsGps = this.tcsProvider.provideGPSLocationComponent();
		tcsGps.stopTrackingLocationUpdates(this.gpsTrackingFunction);
	}

	private boolean hasGpsPermission() {
		return this.tcsPermission.isLocationPermissionGranted(this.context);
	}

	private void requestGpsPermission(String requestPermissionText, final CallbackContext cb) {
		TCSBenefitsPermissionListener listener = new TCSBenefitsPermissionListener(cb);
		this.tcsPermission.requestLocationPermission(this.cordova.getActivity(), requestPermissionText, listener);
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

	private void getStartupParameters(final CallbackContext cb) {
		if (TCSBenefitsModule.startupJSON != null) {
			cb.success(TCSBenefitsModule.startupJSON);
			TCSBenefitsModule.startupJSON = null;
		}
		else {
			cb.success("");
		}
	}

	private void getMemberInfo(final CallbackContext cb) {
		TCSUserComponent tcsUser = this.tcsProvider.provideUserComponent();
		if (tcsUser.isLoggedIn()) {
			tcsUser.getAccountInfo(new Function1<Account, Unit>() {
				@Override
				public Unit invoke(Account account) {
					JSONObject result = new JSONObject();

					try {
						result.put("memberNumber", account.getPersonalReference());
						result.put("email", account.getEmail());
						result.put("sectionCode", account.getSectionCode());

						cb.success(result);
					}
					catch (JSONException ex) {}

					return null;
				}
			}, new Function2<Integer, String, Unit>() {
				@Override
				public Unit invoke(Integer integer, String s) {
					Log.e("Error", s);
					return null;
				}
			}); // function2 = errorCallback
		}
		else {
			cb.success("");
		}

	}

}