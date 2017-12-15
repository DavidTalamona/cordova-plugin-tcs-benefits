package ch.apnet.plugin.tcs;

import android.util.Log;

import org.apache.cordova.CallbackContext;

import ch.tcs.android.tcsframework.managers.permissions.helperinterfaces.TCSPermissionRequestListener;

/**
 * Created by Toby on 15.11.2017.
 */

public class TCSBenefitsPermissionListener implements TCSPermissionRequestListener {

	private final CallbackContext callbackContext;

	TCSBenefitsPermissionListener(final CallbackContext callbackContext) {
		this.callbackContext = callbackContext;
	}

	@Override
	public void onPermissionGranted() {
		this.callbackContext.success("1");
	}

	@Override
	public void onPermissionDenied() {
		this.callbackContext.success("0");
	}

}
