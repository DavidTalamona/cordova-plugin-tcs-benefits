/**
 */
package ch.apnet.plugin.tcs;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.telecom.Call;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

import ch.apnet.plugin.tcs.TCSKVStorage;
import ch.apnet.plugin.tcs.TCSKVStorageMock;

import android.util.Log;


public class TcsPlugin extends CordovaPlugin {
	private static final String TAG = "TcsPlugin";

	private SharedPreferences prefs;
	private Context context;

	private TCSKVStorage storage = new TCSKVStorageMock();
	private boolean isTrackingLocation = false;

	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);

		this.context = this.cordova.getActivity().getApplicationContext();
		this.prefs = getPreferences();

		Log.d(TAG, "Initializing TcsPlugin");
	}

	private SharedPreferences getPreferences() {
		// Request shared preferences for this app id
		SharedPreferences prefs = this.context.getSharedPreferences("ch.apnet.plugin.tcs", Context.MODE_PRIVATE);
		return prefs;
	}

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

		} else if (action.equals("getMemberNumber")) {
			String memberNumber = getMemberNumber();
			callbackContext.success(memberNumber);

		}
		return true;
	}

	private void startTrackingLocationUpdates(final CallbackContext cb) {
		isTrackingLocation = true;
		cordova.getThreadPool().execute(new Runnable() {
			public void run() {
				while (isTrackingLocation) {
					try {
						JSONObject result = new JSONObject();
						result.put("latitude", new Double(47.6961188));
						result.put("longitutde", new Double(47.696897));
						result.put("accuracy", new Double(76.3));

						cb.success(result);

						Thread.sleep(5000);
					}
					catch (Exception ex) {}

				}
			}
		});
	}

	private void stopTrackingLocationUpdates() {
		isTrackingLocation = false;
	}

	private boolean hasGpsPermission() {
		return true;
	}

	private boolean requestGpsPermission() {
		return true;
	}

	private void storageSave(String key, String value) {
		this.storage.setStringValue(key, value, this.prefs);
	}

	private String storageLoad(String key) {
		return this.storage.getStringValue(key, this.prefs);
	}

	private String getMemberNumber() {
		return "105278489";
	}

}