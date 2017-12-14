import Cordova
import TCSSDK
import CoreLocation

@objc(TCSPlugin)
class TCSPlugin : CDVPlugin, TCSLocationDelegate {

    private var tcsProvider: TCSComponentsProvider?
    private var tcsLocation: TCSLocation?
    private var tcsStorage: TCSKVStorage?
    private var tcsUser: TCSUserComponent?
    private var tcsPush: TCSPushNotifications?

    private var locationCommandInvoked: CDVInvokedUrlCommand?

    override func pluginInitialize() {
        super.pluginInitialize()

        self.tcsProvider = TCSBenefitsModule.getTcsProvider()
        self.tcsLocation = self.tcsProvider!.getTCSLocation()
        self.tcsStorage = self.tcsProvider!.getTCSKVStorageComponent()
        self.tcsUser = self.tcsProvider!.getTCSUserComponent()
        self.tcsPush = self.tcsProvider!.getTCSPushNotifications()
    }

    @objc(startTrackingLocationUpdates:)
    func startTrackingLocationUpdates(command: CDVInvokedUrlCommand) {
        self.locationCommandInvoked = command
        self.tcsLocation!.startMonitoringLocationUpdates(withDelegate: self)
    }

    @objc(stopTrackingLocationUpdates:)
    func stopTrackingLocationUpdates(command: CDVInvokedUrlCommand) {
        self.tcsLocation!.stopMonitoringLocationUpdates(withDelegate: self)
    }

    @objc(hasGpsPermission:)
    func hasGpsPermission(command: CDVInvokedUrlCommand) {
        let result = self.tcsLocation!.isPermissionAllowed()

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: result ? "1" : "0"
        )

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }

    @objc(requestGpsPermission:)
    func requestGpsPermission(command: CDVInvokedUrlCommand) {

        let requestText: String = command.arguments[0] as? String ?? ""

        let completion: TCSAskLocationPermissionCompletion = {[weak self] (determined, allowed) in
            var isAllowed = "0"
            if (allowed) {
                isAllowed = "1"
            }

            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: isAllowed
            )

            self!.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
        self.tcsLocation!.askForLocationPermission(withText: requestText, completion: completion)

    }

    @objc(storageSave:)
    func storageSave(command: CDVInvokedUrlCommand) {

        let key: String = command.arguments[0] as? String ?? ""
        let value: String = command.arguments[1] as? String ?? ""

        if (key != "" && value != "") {
            self.tcsStorage!.set(string: value, forKey: key)
        }
    }

    @objc(storageLoad:)
    func storageLoad(command: CDVInvokedUrlCommand) {
        let key = command.arguments[0] as? String ?? ""

        let value = self.tcsStorage!.string(forKey: key)

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

        self.tcsStorage!.removeValue(forKey: key)
    }

    @objc(getMemberInfo:)
    func getMemberInfo(command: CDVInvokedUrlCommand) {

        if (self.tcsUser!.isLoggedIn()) {
            let userProfile = self.tcsUser!.getUserProfile()!

            let jsonObject: [String: Any] = [
                "memberNumber": userProfile.membership,
                "email": userProfile.email ?? "",
                "sectionCode": userProfile.section
            ]

            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: jsonObject
            )

            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        } else {
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: ""
            )

            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }

    }

    @objc(registerDeepLinks:)
    func registerDeepLinks(command: CDVInvokedUrlCommand) {
        //TODO: implement
    }

    @objc(getPushToken:)
    func getPushToken(command: CDVInvokedUrlCommand) {
        let result = self.tcsPush!.deviceToken()

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: result
        )

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }

    func tcsLocationDidUpdate(location: CLLocation) {
        let jsonObject: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy
        ]

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: jsonObject
        )

        pluginResult?.setKeepCallbackAs(true)

        self.commandDelegate!.send(
            pluginResult,
            callbackId: self.locationCommandInvoked!.callbackId
        )
    }

}
