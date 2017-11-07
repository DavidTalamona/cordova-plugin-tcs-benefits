@objc(TcsPlugin) class TcsPlugin : CDVPlugin {

  @objc(startTrackingLocationUpdates:)
  func startTrackingLocationUpdates(command: CDVInvokedUrlCommand) {
  }

  @objc(stopTrackingLocationUpdates:)
  func stopTrackingLocationUpdates(command: CDVInvokedUrlCommand) {
  }

  @objc(hasGpsPermission:)
  func hasGpsPermission(command: CDVInvokedUrlCommand) {
  	let pluginResult = CDVPluginResult(
		status: CDVCommandStatus_OK,
		messageAs: "1"
  	)

  	self.commandDelegate!.send(
	  pluginResult,
	  callbackId: command.callbackId
	)
  }

  @objc(requestGpsPermission:)
  func requestGpsPermission(command: CDVInvokedUrlCommand) {
  }

  @objc(storageSave:)
  func storageSave(command: CDVInvokedUrlCommand) {
  }

  @objc(storageLoad:)
  func storageLoad(command: CDVInvokedUrlCommand) {
  }

  @objc(storageClear:)
  func storageClear(command: CDVInvokedUrlCommand) {
  }

  @objc(getMemberNumber:)
  func getMemberNumber(command: CDVInvokedUrlCommand) {
  }

}