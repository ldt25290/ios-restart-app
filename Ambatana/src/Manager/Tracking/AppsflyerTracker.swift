//
//  AppsFlyerTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import AppsFlyer
import LGCoreKit

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .ProductOffer:
                return true
            case .ProductAskQuestion:
                return true
            case .ProductMarkAsSold:
                return true
            case .ProductSellComplete:
                return true
            case .CommercializerStart:
                return true
            case .CommercializerComplete:
                return true
            default:
                return false
            }
        }
    }
}

final class AppsflyerTracker: Tracker {
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        AppsFlyerTracker.sharedTracker().appsFlyerDevKey = EnvironmentProxy.sharedInstance.appsFlyerAPIKey
        AppsFlyerTracker.sharedTracker().appleAppID = EnvironmentProxy.sharedInstance.appleAppId
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        AppsFlyerTracker.sharedTracker().handleOpenURL(url, sourceApplication: sourceApplication, withAnnotation: annotation)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        AppsFlyerTracker.sharedTracker().trackAppLaunch()
    }

    func setInstallation(installation: Installation?) {
        let installationId = installation?.objectId ?? ""
        AppsFlyerTracker.sharedTracker().customerUserID = installationId
    }

    func setUser(user: MyUser?) {
        guard let email = user?.email else { return }
        AppsFlyerTracker.sharedTracker().setUserEmails([email], withCryptType: EmailCryptTypeSHA1)
    }
    
    func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {
            AppsFlyerTracker.sharedTracker().trackEvent(event.actualName, withValues: event.params?.stringKeyParams)
        }
    }

    func setLocation(location: LGLocation?) {}
    func setNotificationsPermission(enabled: Bool) {}
    func setGPSPermission(enabled: Bool) {}
}
