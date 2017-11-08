var exec = require('cordova/exec');

exports.hasGpsPermission = function(arg0, success, error) {
	exec(success, error, "TcsPlugin", "echo", []);
};
