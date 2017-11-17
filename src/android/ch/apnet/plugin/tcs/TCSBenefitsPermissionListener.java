package ch.apnet.plugin.tcs;

import ch.tcs.android.tcsframework.managers.permissions.helperinterfaces.TCSPermissionRequestListener;

/**
 * Created by Toby on 15.11.2017.
 */

public class TCSBenefitsPermissionListener implements TCSPermissionRequestListener {

	private boolean isPermissionGranted = false;

	@Override
	public void onPermissionGranted() {
		isPermissionGranted = true;
	}

	@Override
	public void onPermissionDenied() {
		isPermissionGranted = false;
	}

	public boolean isPermissionGranted() {
		return isPermissionGranted;
	}
}
