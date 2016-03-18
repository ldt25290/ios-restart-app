//
//  AmplitudeTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Amplitude_iOS
import LGCoreKit

public class AmplitudeTracker: Tracker {
    
    // Constants
    // > User properties
    private static let userPropIdKey = "user-id"
    private static let userPropEmailKey = "user-email"
    private static let userPropLatitudeKey = "user-lat"
    private static let userPropLongitudeKey = "user-lon"

    private static let userPropTypeKey = "UserType"
    private static let userPropTypeValueReal = "1"
    private static let userPropTypeValueDummy = "0"

    private static let userPropInstallationIdKey = "installation-id"

    // enabled permissions
    private static let userPropPushEnabled = "push-enabled"
    private static let userPropGpsEnabled = "gps-enabled"

    // > Prefix
    private static let dummyEmailPrefix = "usercontent"
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        Amplitude.instance().trackingSessionEvents = false
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        
    }
    
    public func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        setUser(Core.myUserRepository.myUser)
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
    }

    public func setInstallation(installation: Installation) {
        var identify = AMPIdentify.identify()
        identify.set(AmplitudeTracker.userPropInstallationIdKey, value: installation.objectId)
        Amplitude.instance().identify(identify)
    }

    public func setUser(user: MyUser?) {
        let userId = user?.email ?? ""
        Amplitude.instance().setUserId(userId)

        var isDummy = false
        let dummyRange = (user?.email ?? "").rangeOfString(AmplitudeTracker.dummyEmailPrefix)
        if let isDummyRange = dummyRange where isDummyRange.startIndex == (user?.email ?? "").startIndex {
            isDummy = true
        }
        
        var properties: [NSObject : AnyObject] = [:]
        properties[AmplitudeTracker.userPropIdKey] = user?.objectId ?? ""
        properties[AmplitudeTracker.userPropLatitudeKey] = user?.location?.coordinate.latitude
        properties[AmplitudeTracker.userPropLongitudeKey] = user?.location?.coordinate.longitude

        let userType = isDummy ? AmplitudeTracker.userPropTypeValueDummy : AmplitudeTracker.userPropTypeValueReal
        properties[AmplitudeTracker.userPropTypeKey] = userType

        let pushEnabledValue = UIApplication.sharedApplication().isRegisteredForRemoteNotifications() ? "true" : "false"
        properties[AmplitudeTracker.userPropPushEnabled] = pushEnabledValue
        let gpsEnabled = Core.locationManager.locationServiceStatus == .Enabled(.Authorized) ? "true" : "false"
        properties[AmplitudeTracker.userPropGpsEnabled] = gpsEnabled

        Amplitude.instance().setUserProperties(properties)
    }
    
    public func trackEvent(event: TrackerEvent) {
        Amplitude.instance().logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)

    }
    
    public func updateCoordinates() {
        setUser(Core.myUserRepository.myUser)
    }

    public func notificationsPermissionChanged() {
        setUser(Core.myUserRepository.myUser)
    }

    public func gpsPermissionChanged() {
        setUser(Core.myUserRepository.myUser)
    }
}
)