//
//  AppsFlyerTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import AppsFlyerLib
import LGCoreKit

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .FirstMessage, .ProductMarkAsSold, .ProductSellStart, .ProductSellComplete,
                 .ProductSellComplete24h, .CommercializerStart, .CommercializerComplete:
                return true
            default:
                return false
            }
        }
    }

    // Criteo: https://ambatana.atlassian.net/browse/ABIOS-1966 (2)
    var shouldTrackRegisteredUIAchievement: Bool {
        get {
            switch name {
            case .LoginFB, .LoginGoogle, .SignupEmail:
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
        guard let user = user else { return }

        let tracker = AppsFlyerTracker.sharedTracker()
        if let email = user.email {
            tracker.setUserEmails([email], withCryptType: EmailCryptTypeSHA1)
        }
        tracker.trackEvent("af_user_status", withValues: ["ui_status": "login"])
    }
    
    func trackEvent(event: TrackerEvent) {
        let tracker = AppsFlyerTracker.sharedTracker()
        if event.shouldTrack {
            tracker.trackEvent(event.actualName, withValues: event.params?.stringKeyParams)
        }
        if event.shouldTrackRegisteredUIAchievement {
            tracker.trackEvent(AFEventAchievementUnlocked, withValues: ["ui_achievement": "registered"])
        }
    }

    func setLocation(location: LGLocation?) {}
    func setNotificationsPermission(enabled: Bool) {}
    func setGPSPermission(enabled: Bool) {}
    func setMarketingNotifications(enabled: Bool) {}
}
