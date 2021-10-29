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
import ch.apnet.module.tcs.android.TCSBenefitsView;
import ch.tcs.android.tcsframework.components.TCSGPSComponent;
import ch.tcs.android.tcsframework.components.TCSKVStorage;
import ch.tcs.android.tcsframework.components.TCSPushComponent;
import ch.tcs.android.tcsframework.components.TCSUserComponent;
import ch.tcs.android.tcsframework.domain.model.UserDataAccessToken;
import ch.tcs.android.tcsframework.managers.permissions.TCSAndroidPermissionManager;
import ch.tcs.android.tcsframework.providers.TCSComponentsProvider;
import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function1;

public class TCSPlugin extends CordovaPlugin {

	private Context context;

	private TCSComponentsProvider tcsProvider;
	private TCSAndroidPermissionManager tcsPermission;
	private TCSKVStorage tcsStorage;
	private TCSPushComponent tcsPush;
	private TCSUserComponent tcsUser;
	private Function1<Location, Unit> gpsTrackingFunction;

	private static CallbackContext customEventsCallback;

	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);

		this.context = this.cordova.getActivity().getApplicationContext();
		this.tcsProvider = TCSBenefitsModule.getTcsProvider();
		this.tcsPermission = TCSBenefitsModule.getTcsPermissionManager();
		this.tcsStorage = this.tcsProvider.provideKVComponent();
		this.tcsPush = TCSBenefitsModule.getTcsPush();
		this.tcsUser = TCSBenefitsModule.getTcsUser();
	}

	@Override
	public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

		switch (action) {
			case "startTrackingLocationUpdates":
				startTrackingLocationUpdates(callbackContext);

				break;
			case "stopTrackingLocationUpdates":
				stopTrackingLocationUpdates();

				break;
			case "hasGpsPermission":
				callbackContext.success(hasGpsPermission() ? "1" : "0");

				break;
			case "requestGpsPermission":
				requestGpsPermission(args.getString(0), callbackContext);

				break;
			case "hasCameraPermission":
				callbackContext.success(hasCameraPermission() ? "1" : "0");

				break;
			case "requestCameraPermission":
				requestCameraPermission(args.getString(0), args.getString(1), callbackContext);

				break;
			case "storageSave":
				storageSave(args.getString(0), args.getString(1));

				break;
			case "storageLoad":
				String savedString = storageLoad(args.getString(0));
				callbackContext.success(savedString);

				break;
			case "storageClear":
				storageClear(args.getString(0));

				break;
			case "getMemberInfo":
				getMemberInfo(callbackContext);

				break;
			case "getStartupParameters":
				getStartupParameters(callbackContext);

				break;
			case "getPushToken":
				callbackContext.success(tcsPush.getLastFetchedPushToken());

				break;
			case "navigateBack":
				this.cordova.getActivity().finish();

				break;
			case "showPage":
				String page = args.getString(0);
				showPage(page, callbackContext);

				break;
			case "registerCustomEvents":
				registerCustomEvents(callbackContext);

				break;
			case "getAccessToken":
				sendAccessToken(callbackContext);

				break;
			case "isProductionEnvironment":
				callbackContext.success(tcsUser.isUsedProductionEnvironment() ? "1" : "0");

				break;
		}
		return true;
	}

	public static void sendCustomEvent(String event) {
		if (TCSPlugin.customEventsCallback != null) {
			PluginResult result = new PluginResult(PluginResult.Status.OK, event);
			result.setKeepCallback(true);
			TCSPlugin.customEventsCallback.sendPluginResult(result);
		}
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
				catch (JSONException ex) {
					Log.d("Exception in GPS", ex.getMessage());
				}
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

	private boolean hasCameraPermission() {
		return this.tcsPermission.isCameraPermissionGranted(this.context);
	}

	private void requestCameraPermission(String requestPermissionText, String permissionDeniedText, final CallbackContext cb) {
		TCSBenefitsPermissionListener listener = new TCSBenefitsPermissionListener(cb);
		this.tcsPermission.requestCameraPermission(this.cordova.getActivity(), listener, requestPermissionText, permissionDeniedText);
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
		TCSBenefitsModule.loadMemberData( cb);
	}

	private void showPage(String page, final CallbackContext cb) {
		if (page.equalsIgnoreCase("login")) {
			tcsUser.showLoginScreen(new Function0<Unit>() {
				@Override
				public Unit invoke() {
					// Success Callback
					TCSBenefitsModule.loadMemberData( null);
					cb.success("1");
					return null;
				}
			}, new Function0<Unit>() {
				@Override
				public Unit invoke() {
					// error callback
					return null;
				}
			});
		} else if (page.equalsIgnoreCase("membercard")) {
			tcsUser.showMemberCard(new Function0<Unit>() {
				@Override
				public Unit invoke() {
					// Success Callback
					cb.success("1");
					return null;
				}
			});
		} else if (page.equalsIgnoreCase("promovideo")) {
			TCSBenefitsView.startPromoVideo(this.context);
		}
	}

	private void registerCustomEvents(final CallbackContext cb) {
		TCSPlugin.customEventsCallback = cb;
	}

	private void sendAccessToken(final CallbackContext cb) {
		tcsUser.getAccessToken(new Function1<UserDataAccessToken, Unit>() {
			@Override
			public Unit invoke(UserDataAccessToken token) {
				JSONObject json = new JSONObject();

				try {
					json.put("expiresIn", token.getExpiresIn());
					json.put("accessToken", token.getAccessToken());

					PluginResult result = new PluginResult(PluginResult.Status.OK, json);
					result.setKeepCallback(true);
					cb.sendPluginResult(result);

				}
				catch (JSONException ex) {
					Log.d("Exception in Token", ex.getMessage());
				}
				return null;
			}
		});
	}

}
