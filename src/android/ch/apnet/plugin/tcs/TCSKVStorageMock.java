package ch.apnet.plugin.tcs;

import android.content.SharedPreferences;

public class TCSKVStorageMock implements TCSKVStorage {
	@Override
	public String getStringValue(String key, SharedPreferences prefs) {
		return prefs.getString(key, null);
	}

	@Override
	public void setStringValue(String key, String value, SharedPreferences prefs) {
		SharedPreferences.Editor editor = prefs.edit();
		editor.putString(key, value);
		editor.commit();
	}
}
