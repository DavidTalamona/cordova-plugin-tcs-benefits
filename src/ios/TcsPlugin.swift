@objc(TcsPlugin) class TcsPlugin : CDVPlugin {

  let isTracking = false;

  @objc(startTrackingLocationUpdates:)
  func startTrackingLocationUpdates(command: CDVInvokedUrlCommand) {
    isTracking = true;
    commandDelegate.run(inBackground: {() -> Void in
      while(isTracking) {

        let payload: String? = nil
        payload = "{" + "'latitude': " + 47.6961188 + "," +
        "'longitude': " + 47.696897 + "," +
        "'accuracy': " + 76.3 + "}"

        var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: payload)
        commandDelegate.send(pluginResult, callbackId: command.callbackId)

        sleep(5)
      }
    })
  }

  @objc(stopTrackingLocationUpdates:)
  func stopTrackingLocationUpdates(command: CDVInvokedUrlCommand) {
    isTracking = false;
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
    let pluginResult = CDVPluginResult(
      status: CDVCommandStatus_OK,
      messageAs: "1"
    )

    self.commandDelegate!.send(
      pluginResult,
      callbackId: command.callbackId
    )
  }

  @objc(storageSave:)
  func storageSave(command: CDVInvokedUrlCommand) {

    let key = command.arguments[0] as? String ?? ""
    let value = command.arguments[1] as? String ?? ""

    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: key)
    userDefaults.synchronize()
  }

  @objc(storageLoad:)
  func storageLoad(command: CDVInvokedUrlCommand) {
    let key = command.arguments[0] as? String ?? ""

    if let value: String = UserDefaults.standard.object(forKey: key) as String? { }

    let pluginResult = CDVPluginResult(
      status: CDVCommandStatus_OK,
      messageAs: value
    )

    self.commandDelegate!.send(
      pluginResult,
      callbackId: command.callbackId
    )
  }

  @objc(storageClear:)
  func storageClear(command: CDVInvokedUrlCommand) {
    let key = command.arguments[0] as? String ?? ""

    let userDefaults = UserDefaults.standard
    userDefaults.removeObjectForKey(key)
    userDefaults.synchronize()
  }

  @objc(getMemberNumber:)
  func getMemberNumber(command: CDVInvokedUrlCommand) {
  	let pluginResult = CDVPluginResult(
      status: CDVCommandStatus_OK,
      messageAs: "105278489"
    )

    self.commandDelegate!.send(
      pluginResult,
      callbackId: command.callbackId
    )
  }

}