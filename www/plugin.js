
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
	storageSave: function(key, value, cb) {
		exec(cb, null, PLUGIN_NAME, 'storageSave', [key, value]);
	},
	storageLoad: function(key, cb) {
		exec(cb, null, PLUGIN_NAME, 'storageLoad', [key]);
	},
	storageClear: function(key, cb) {
		exec(cb, null, PLUGIN_NAME, 'storageClear', [key]);
	},
	getMemberInfo: function(cb) { // returns empty string if no user is logged in
		exec(cb, null, PLUGIN_NAME, 'getMemberInfo', []);
	},
	getStartupParameters: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'getStartupParameters', []);
	},
	getPushToken: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'getPushToken', []);
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
	}

};

module.exports = TCSPlugin;
