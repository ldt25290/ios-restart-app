//
//  GANTracker.swift
//  LetGo
//
//  Created by Dídac on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .ProductSellComplete, .ProductDetailVisit, .ProductDetailVisitMoreInfo, .ProductAskQuestion, .ProductOffer, .UserMessageSent,
                 .ProductMarkAsSold, .ProductDeleteComplete, .SignupEmail, .LoginEmail, .LoginFB, .Logout:
                return true
            default:
                return false
            }
        }
    }

    var ganCategory: String {
        get {
            switch name {
            case .ProductDetailVisit, .ProductDetailVisitMoreInfo, .ProductAskQuestion, .ProductOffer:
                return "buyer"
            case .ProductSellComplete, .ProductMarkAsSold, .ProductDeleteComplete:
                return "seller"
            case .UserMessageSent, .SignupEmail, .LoginEmail, .LoginFB, .Logout:
                return "all"
            default:
                return "all"
            }
        }
    }
}

final class GANTracker: Tracker {

    // MARK: - Tracker

    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {

            var configureError:NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(configureError)")
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
        annotation: AnyObject?) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func setInstallation(installation: Installation?) {

    }

    func setUser(user: MyUser?) {

    }

    func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.allowIDFACollection = true  // Needed for remarketing features
            let builder = GAIDictionaryBuilder.createEventWithCategory(event.ganCategory, action:event.actualName,
                label: nil, value: nil)
            tracker.send(builder.build() as [NSObject:AnyObject])
        }
    }

    func setLocation(location: LGLocation?) {}
    func setNotificationsPermission(enabled: Bool) {}
    func setGPSPermission(enabled: Bool) {}
}
