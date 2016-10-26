//
//  TourNotificationsViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum TourNotificationNextStep {
    case Location
    case NoStep
}

final class TourNotificationsViewModel: BaseViewModel {

    weak var navigator: TourNotificationsNavigator?
    
    let title: String
    let subtitle: String
    let pushText: String
    let source: PrePermissionType
    var showPushInfo: Bool {
        switch FeatureFlags.onboardinPermissionsMode {
        case .Original, .OneButtonOriginalImages:
            return true
        case .OneButtonNewImages:
            return false
        }
    }
    var showAlertInfo: Bool {
        return !showPushInfo
    }
    var infoImage: UIImage? {
        switch FeatureFlags.onboardinPermissionsMode {
        case .Original, .OneButtonOriginalImages:
            return UIImage(named: "img_notifications")
        case .OneButtonNewImages:
            return UIImage(named: "img_permissions_background")
        }
    }
    var showNoButton: Bool {
        switch FeatureFlags.onboardinPermissionsMode {
        case .Original:
            return true
        case .OneButtonNewImages, .OneButtonOriginalImages:
            return false
        }
    }
    
    init(title: String, subtitle: String, pushText: String, source: PrePermissionType) {
        self.title = title
        self.subtitle = subtitle
        self.pushText = pushText
        self.source = source
    }

    func nextStep() -> TourNotificationNextStep? {
        guard navigator == nil else {
            navigator?.tourNotificationsFinish()
            return nil
        }
        switch source {
        case .Onboarding:
            return Core.locationManager.shouldAskForLocationPermissions() ? .Location : .NoStep
        case .ProductList, .Chat, .Sell, .Profile, .ProductListBanner:
            return .NoStep
        }
    }

    
    // MARK: - Tracking
    
    func viewDidLoad() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.Push, typePage: source.trackingParam, alertType: .FullScreen,
            permissionGoToSettings: .NotAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Push, typePage: source.trackingParam, alertType: .FullScreen,
            permissionGoToSettings: .NotAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapYesButton() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Push, typePage: source.trackingParam, alertType: .FullScreen,
            permissionGoToSettings: .NotAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
