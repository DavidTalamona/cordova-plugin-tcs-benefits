package ch.apnet.plugin.tcs;

import android.content.SharedPreferences;

public interface TCSKVStorage {
	String getStringValue(String key, SharedPreferences prefs);
	void setStringValue(String key, String value, SharedPreferences prefs);
}