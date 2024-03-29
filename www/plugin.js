
var exec = require('cordova/exec');

var PLUGIN_NAME = 'TCSPlugin';

var TCSPlugin = {
	startTrackingLocationUpdates: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'startTrackingLocationUpdates', []);
	},
	stopTrackingLocationUpdates: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'stopTrackingLocationUpdates', []);
	},
	hasGpsPermission: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'hasGpsPermission', []);
	},
	requestGpsPermission: function(permissionReasonText, cb) {
		exec(cb, null, PLUGIN_NAME, 'requestGpsPermission', [permissionReasonText]);
	},
	hasCameraPermission: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'hasCameraPermission', []);
	},
	requestCameraPermission: function(permissionReasonText, permissionDeniedText, cb) {
		exec(cb, null, PLUGIN_NAME, 'requestCameraPermission', [permissionReasonText, permissionDeniedText]);
	},
	storageSave: function(key, value, cb) {
		exec(cb, null, PLUGIN_NAME, 'storageSave', [key, value]);
	},
	storageLoad: function(key, cb) {
		exec(cb, null, PLUGIN_NAME, 'storageLoad', [key]);
	},
	storageClear: function(key, cb) {
		exec(cb, null, PLUGIN_NAME, 'storageClear', [key]);
	},
	getMemberInfo: function(cb, cbError) { // returns empty string if no user is logged in
		exec(cb, cbError, PLUGIN_NAME, 'getMemberInfo', []);
	},
	getStartupParameters: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'getStartupParameters', []);
	},
	getPushToken: function(permissionReasonText, cb) {
		exec(cb, null, PLUGIN_NAME, 'getPushToken', [permissionReasonText]);
	},
	navigateBack: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'navigateBack', []);
	},
	enableSwipeBack: function(isEnabled, cb) {
		exec(cb, null, PLUGIN_NAME, 'enableSwipeBack', [isEnabled])
	},
	showPage: function(page, cb) {
		exec(cb, null, PLUGIN_NAME, 'showPage', [page])
	},
	registerCustomEvents: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'registerCustomEvents', [])
	},
	getLanguage: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'getLanguage')
	},
	openInSystemBrowser: function(url, cb) {
		exec(cb, null, PLUGIN_NAME, 'openInSystemBrowser', [url])
	},
	getAccessToken: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'getAccessToken', [])
	},
	isProductionEnvironment: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'isProductionEnvironment', [])
	},

};

module.exports = TCSPlugin;
