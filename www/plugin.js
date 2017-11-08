
var exec = require('cordova/exec');

var PLUGIN_NAME = 'TcsPlugin';

var TcsPlugin = {
	startTrackingLocationUpdates: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'startTrackingLocationUpdates', []);
	},
	stopTrackingLocationUpdates: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'stopTrackingLocationUpdates', []);
	},
	hasGpsPermission: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'hasGpsPermission', []);
	},
	requestGpsPermission: function(cb) {
		exec(cb, null, PLUGIN_NAME, 'requestGpsPermission', []);
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
	getMemberNumber: function(cb) { // returns null if no user is logged in
		exec(cb, null, PLUGIN_NAME, 'getMemberNumber', []);
	}
};

module.exports = TcsPlugin;
