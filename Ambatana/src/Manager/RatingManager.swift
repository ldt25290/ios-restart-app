//
//  RatingManager.swift
//  LetGo
//
//  Created by Dídac on 03/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


class RatingManager {
    static let sharedInstance: RatingManager = RatingManager()

    private let keyValueStorage: KeyValueStorage
    private let crashManager: CrashManager


    // MARK: - Lifecycle

    convenience init() {
        let keyValueStorage = KeyValueStorage.sharedInstance
        let versionChecker = VersionChecker.sharedInstance
        let crashManager = CrashManager.sharedInstance

        self.init(keyValueStorage: keyValueStorage, crashManager: crashManager,
                  versionChange: versionChecker.versionChange)
    }

    init(keyValueStorage: KeyValueStorage, crashManager: CrashManager, versionChange: VersionChange) {
        self.keyValueStorage = keyValueStorage
        self.crashManager = crashManager
        switch versionChange {
        case .NewInstall, .Major, .Minor:
            keyValueStorage.userRatingAlreadyRated = false
            keyValueStorage.userRatingRemindMeLaterDate = nil
            keyValueStorage.userRatingShowProductListBanner = false
        case .Patch:
            keyValueStorage.userRatingRemindMeLaterDate = nil
        case .None:
            break
        }
    }
}


// MARK: - Internal methods

extension RatingManager {
    var shouldShowRating: Bool {
        guard !crashManager.appCrashed else { return false }
        guard !keyValueStorage.userRatingAlreadyRated else { return false }
        guard let remindMeLaterDate = keyValueStorage.userRatingRemindMeLaterDate else { return true }
        return remindMeLaterDate.timeIntervalSinceNow <= 0
    }
    var shouldShowRatingProductListBanner: Bool {
        guard !crashManager.appCrashed else { return false }
        guard !keyValueStorage.userRatingAlreadyRated else { return false }
        return keyValueStorage.userRatingShowProductListBanner
    }

    func userDidRate() {
        keyValueStorage.userRatingAlreadyRated = true
        keyValueStorage.userRatingShowProductListBanner = false
    }

    func userDidRemindLater() {
        if keyValueStorage.userRatingRemindMeLaterDate == nil {
            // If we don't have a remind later date then set it up
            let remindDate = NSDate().dateByAddingTimeInterval(Constants.ratingRepeatTime)
            keyValueStorage.userRatingRemindMeLaterDate = remindDate
        } else {
            // Otherwise, we set it in a distant future... (might be overriden when updating)
            keyValueStorage.userRatingRemindMeLaterDate = NSDate.distantFuture()
        }
        keyValueStorage.userRatingShowProductListBanner = true
    }

    func userDidCloseProductListBanner() {
        keyValueStorage.userRatingShowProductListBanner = false
    }
}
