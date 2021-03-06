import Cordova
import TCSSDK
import CoreLocation

@objc(TCSPlugin)
class TCSPlugin : CDVPlugin, TCSLocationDelegate {

    private var tcsProvider: TCSComponentsProvider?
    private var tcsLocation: TCSLocation?
    private var tcsCamera: TCSCameraComponent?
    private var tcsStorage: TCSKVStorage?
    private var tcsUser: TCSUserComponent?

    private var locationCommandInvoked: CDVInvokedUrlCommand?
    private static var customEventCallback: CDVInvokedUrlCommand?
    private static var customEventDelegate: CDVCommandDelegate?

    override func pluginInitialize() {
        super.pluginInitialize()

        TCSPlugin.customEventDelegate = self.commandDelegate

        self.tcsProvider = TCSBenefitsModule.getTcsProvider()
        self.tcsLocation = self.tcsProvider!.getTCSLocation()
        self.tcsStorage = self.tcsProvider!.getTCSKVStorageComponent()
        self.tcsUser = self.tcsProvider!.getTCSUserComponent()
        self.tcsCamera = self.tcsProvider!.getTCSCameraComponent()

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

    @objc(hasCameraPermission:)
    func hasCameraPermission(command: CDVInvokedUrlCommand) {
        let result = self.tcsCamera!.isPermissionAllowed()

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: result ? "1" : "0"
        )

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }

    @objc(requestCameraPermission:)
    func requestCameraPermission(command: CDVInvokedUrlCommand) {

        let requestText: String = command.arguments[0] as? String ?? ""

        let completion: TCSAskCameraPermissionCompletion = {[weak self] (allowed) in
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
        self.tcsCamera!.askForCameraPermission(withText: requestText, completion: completion)
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
        TCSBenefitsModule.loadMemberData(isLoadingCachedData: true, command: command, commandDelegate: self.commandDelegate)
    }

    @objc(getStartupParameters:)
    func getStartupParameters(command: CDVInvokedUrlCommand) {
        if (TCSBenefitsModule.startupJSON != nil) {
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: TCSBenefitsModule.startupJSON
            )
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )

            // reset startup parameter after request
            TCSBenefitsModule.startupJSON = nil

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

    @objc(getPushToken:)
    func getPushToken(command: CDVInvokedUrlCommand) {

        let requestText: String = command.arguments[0] as? String ?? ""
        let delegate = self.commandDelegate!

        if let tcsPush = self.tcsProvider!.getTCSPushNotifications() {
            let completion: TCSAskPushPermissionCompletion = {(allowed) in
                var result: String = ""
                if (allowed) {
                    if let token = tcsPush.deviceToken() {
                        result = token
                    }
                }
                let pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: result
                )
                delegate.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
            }

            if tcsPush.isRegisteredForPushNotifications() {
                completion(true)
            } else if (tcsPush.wasPushPermissionDialogShown()) {
                completion(false)
            } else {
                tcsPush.registerForPushNotifications(withText: requestText, completion: completion)
            }
        }

    }

    @objc(navigateBack:)
    func navigateBack(command: CDVInvokedUrlCommand) {
        TCSBenefitsModule.rootController.navigationController?.popViewController(animated: true)
        TCSBenefitsModule.refreshData(forceRefresh: true)
    }

    @objc(enableSwipeBack:)
    func enableSwipeBack(command: CDVInvokedUrlCommand) {
        let isEnabled = command.arguments[0] as? Bool ?? false
        TCSBenefitsModule.rootController.enableSwipeBack(isEnabled: isEnabled)
    }

    @objc(showPage:)
    func showPage(command: CDVInvokedUrlCommand) {
        let page = command.arguments[0] as? String ?? ""
        if (page.lowercased() == "login") {
            self.tcsUser!.showLoginScreen {
                let pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "1"
                )
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
            }
        } else if (page.lowercased() == "membercard") {
            self.tcsUser!.showMemberCard {
                let pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "1"
                )
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
            }
        } else if (page.lowercased() == "promovideo") {
            TCSBenefitsCardView.promoVideoStart()
        }
    }

    @objc(registerCustomEvents:)
    func registerCustomEvents(command: CDVInvokedUrlCommand) {
        TCSPlugin.customEventCallback = command
    }

    @objc(getLanguage:)
    func getLanguage(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: TCSBenefitsCardView.getCurrentLanguage()
        )
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }

    @objc(openInSystemBrowser:)
    func openInSystemBrowser(command: CDVInvokedUrlCommand) {
        let urlString: String = command.arguments[0] as? String ?? ""
        let url = URL(string: urlString)!
        UIApplication.shared.open(url)
    }

    static func sendCustomEvent(event: String) {
        if (TCSPlugin.customEventCallback != nil) {
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: event
            )

            pluginResult?.setKeepCallbackAs(true)

            if (TCSPlugin.customEventDelegate != nil) {
                TCSPlugin.customEventDelegate!.send(
                    pluginResult,
                    callbackId: TCSPlugin.customEventCallback!.callbackId
                )
            }
        }
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
