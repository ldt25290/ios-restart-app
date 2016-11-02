//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import bumper
import LGCoreKit

struct FeatureFlags {
    static func setup() {
        Bumper.initialize()
    }

    static var websocketChat: Bool = {
        if Bumper.enabled {
            return Bumper.websocketChat
        }
        return false
    }()
    
    static var notificationsSection: Bool = {
        if Bumper.enabled {
            return Bumper.notificationsSection
        }
        return ABTests.notificationCenterEnabled.value
    }()
    
    static var showNPSSurvey: Bool {
        if Bumper.enabled {
            return Bumper.showNPSSurvey
        }
        return ABTests.showNPSSurvey.value
    }

    static var nonStopProductDetail: Bool {
        if Bumper.enabled {
            return Bumper.nonStopProductDetail
        }
        return ABTests.nonStopProductDetail.value
    }

    static var onboardinPermissionsMode: OnboardingPermissionsMode {
        if Bumper.enabled {
            return Bumper.onboardingPermissionsMode
        }
        return OnboardingPermissionsMode.fromPosition(ABTests.onboardingPermissionsMode.value)
    }

    static var messageOnFavorite: MessageOnFavoriteMode {
        if Bumper.enabled {
            return Bumper.messageOnFavoriteMode
        }
        return MessageOnFavoriteMode.fromPosition(ABTests.messageOnFavorite.value)
    }

    static var interestedUsersMode: InterestedUsersMode {
        if Bumper.enabled {
            return Bumper.interestedUsersMode
        }
        return InterestedUsersMode.fromPosition(ABTests.interestedUsersMode.value)
    }

    static var filtersReorder: Bool {
        if Bumper.enabled {
            return Bumper.filtersReorder
        }
        return ABTests.filtersReorder.value
    }

    static var freePostingMode: FreePostingMode {
        guard freePostingModeAllowed else { return .Disabled }

        if Bumper.enabled {
            return Bumper.freePostingMode
        }
        return FreePostingMode.fromPosition(ABTests.freePostingMode.value)
    }

    static var directPostInOnboarding: Bool {
        if Bumper.enabled {
            return Bumper.directPostInOnboarding
        }
        return ABTests.directPostInOnboarding.value
    }


    // MARK: - Private

    private static var freePostingModeAllowed: Bool {
        let locale = NSLocale.currentLocale()
        let locationManager = Core.locationManager

        // Free posting is not allowed in Turkey. Check location & phone region.
        let turkey = "tr"
        let systemCountryCode = (locale.objectForKey(NSLocaleCountryCode) as? String ?? "").lowercaseString
        let countryCode = (locationManager.currentPostalAddress?.countryCode ?? systemCountryCode).lowercaseString

        return systemCountryCode != turkey && countryCode != turkey
    }
}
