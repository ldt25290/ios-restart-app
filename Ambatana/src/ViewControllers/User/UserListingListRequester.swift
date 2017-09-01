//
//  UserListingListRequester.swift
//  LetGo
//
//  Created by Eli Kohen on 19/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol UserListingListRequester: ListingListRequester {
    var userObjectId: String? { get set }
}

class UserFavoritesListingListRequester: UserListingListRequester {
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        // method needed for protocol implementation, not used for user
        return nil
    }
    var countryCode: String? {
        // method needed for protocol implementation, not used for user
        return nil
    }

    let itemsPerPage: Int = 0 // Not used, favorites doesn't paginate
    var userObjectId: String? = nil
    let listingRepository: ListingRepository
    let locationManager: LocationManager

    convenience init() {
        self.init(listingRepository: Core.listingRepository, locationManager: Core.locationManager)
    }

    init(listingRepository: ListingRepository, locationManager: LocationManager) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
    }

    func canRetrieve() -> Bool { return true }
    
    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        listingsRetrieval { result in
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }
    
    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        //User favorites doesn't have pagination.
        let listingsResult = ListingsResult(value: [])
        completion?(ListingsRequesterResult(listingsResult: listingsResult, context: nil))
        return
    }

    private func listingsRetrieval(_ completion: ListingsCompletion?) {
        guard let userId = userObjectId else { return }
        listingRepository.indexFavorites(userId, completion: completion)
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        // favorites has no pagination
        return true
    }

    func updateInitialOffset(_ newOffset: Int) { }

    func duplicate() -> ListingListRequester {
        let r = UserFavoritesListingListRequester()
        r.userObjectId = userObjectId
        return r
    }

    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? UserFavoritesListingListRequester else { return false }
        return userObjectId == requester.userObjectId
    }
}


class UserStatusesListingListRequester: UserListingListRequester {
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        // method needed for protocol implementation, not used for user
        return nil
    }
    var countryCode: String? {
        // method needed for protocol implementation, not used for user
        return nil
    }
    
    let itemsPerPage: Int
    var userObjectId: String? = nil
    private let statuses: [ListingStatus]
    private let listingRepository: ListingRepository
    private let locationManager: LocationManager
    private var offset: Int = 0

    convenience init(statuses: [ListingStatus], itemsPerPage: Int) {
        self.init(listingRepository: Core.listingRepository, locationManager: Core.locationManager, statuses: statuses,
                  itemsPerPage: itemsPerPage)
    }

    init(listingRepository: ListingRepository, locationManager: LocationManager, statuses: [ListingStatus],
         itemsPerPage: Int) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.statuses = statuses
        self.itemsPerPage = itemsPerPage
    }

    func canRetrieve() -> Bool { return userObjectId != nil }

    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        offset = 0
        listingsRetrieval(completion)
    }
    
    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        listingsRetrieval(completion)
    }
    
    private func listingsRetrieval(_ completion: ListingsRequesterCompletion?) {
        guard let userId = userObjectId else { return  }
        listingRepository.index(userId: userId, params: retrieveListingsParams) { [weak self] result in
            if let products = result.value, !products.isEmpty {
                self?.offset += products.count
                //User posted previously -> Store it
                KeyValueStorage.sharedInstance.userPostProductPostedPreviously = true
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(_ newOffset: Int) { }

    func duplicate() -> ListingListRequester {
        let r = UserStatusesListingListRequester(statuses: statuses, itemsPerPage: itemsPerPage)
        r.offset = offset
        r.userObjectId = userObjectId
        return r
    }

    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? UserStatusesListingListRequester else { return false }
        return userObjectId == requester.userObjectId
    }
    
    private var retrieveListingsParams: RetrieveListingParams {
        var params: RetrieveListingParams = RetrieveListingParams()
        params.offset = offset
        params.numListings = itemsPerPage
        if let currentLocation = locationManager.currentLocation {
            params.coordinates = LGLocationCoordinates2D(location: currentLocation)
        }
        params.countryCode = locationManager.currentLocation?.countryCode
        params.sortCriteria = .creation
        params.statuses = statuses
        return params
    }
}