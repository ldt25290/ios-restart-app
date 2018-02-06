//
//  MostSearchedItemsListViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 03/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

enum MostSearchedItemsSource {
    case categoriesHeader
    case userProfile
    case cameraBadge
    case card
    case expandableMenu
}

class MostSearchedItemsListViewModel: BaseViewModel {
    
    weak var navigator: MostSearchedItemsNavigator?
    let isSearchEnabled: Bool
    fileprivate let locationManager: LocationManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let keyValueStorage: KeyValueStorage
    
    let mostSearchedItems: [LocalMostSearchedItem]
    var titleString: String {
        if let city = locationManager.currentLocation?.postalAddress?.city {
            return LGLocalizedString.trendingItemsViewTitle(city)
        } else {
            return LGLocalizedString.trendingItemsViewTitleNoLocation
        }
    }
    
    
    // MARK: - Lifecycle
    
    convenience init(isSearchEnabled: Bool, locationManager: LocationManager) {
        self.init(featureFlags: FeatureFlags.sharedInstance,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  isSearchEnabled: isSearchEnabled,
                  locationManager: locationManager)
    }
    
    init(featureFlags: FeatureFlaggeable,
         notificationsManager: NotificationsManager,
         keyValueStorage: KeyValueStorage,
         isSearchEnabled: Bool,
         locationManager: LocationManager) {
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.isSearchEnabled = isSearchEnabled
        self.locationManager = locationManager
        mostSearchedItems = LocalMostSearchedItem.allValues
        super.init()
        
        let isShowingSellBadge = featureFlags.mostSearchedDemandedItems == .cameraBadge &&
            !keyValueStorage[.mostSearchedItemsCameraBadgeAlreadyShown]
        if isShowingSellBadge {
            keyValueStorage[.mostSearchedItemsCameraBadgeAlreadyShown] = true
            notificationsManager.clearNewSellFeatureIndicator()
        }
    }
    
    
    // MARK: - Navigation
    
    func closeButtonPressed() {
        navigator?.cancel()
    }
    
    func searchButtonAction(listingTitle: String) {
        navigator?.openSearchFor(listingTitle: listingTitle)
    }
    
    func postButtonAction(item: LocalMostSearchedItem) {
        navigator?.openSell(mostSearchedItem: item)
    }
    
    
    // MARK: - Most Searched Items data
    
    func itemAtIndex(_ index: Int) -> LocalMostSearchedItem {
        return mostSearchedItems[index]
    }
}
