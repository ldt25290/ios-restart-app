//
//  UserProductListRequester.swift
//  LetGo
//
//  Created by Eli Kohen on 19/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol UserProductListRequester: ProductListRequester {
    var userObjectId: String? { get set }
}

class UserFavoritesProductListRequester: UserProductListRequester {

    var userObjectId: String? = nil
    let productRepository: ProductRepository
    let locationManager: LocationManager

    convenience init() {
        self.init(productRepository: Core.productRepository, locationManager: Core.locationManager)
    }

    init(productRepository: ProductRepository, locationManager: LocationManager) {
        self.productRepository = productRepository
        self.locationManager = locationManager
    }

    func canRetrieve() -> Bool { return true }

    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        guard let userId = userObjectId else { return }
        productRepository.indexFavorites(userId, completion: completion)
    }

    func isLastPage(resultCount: Int) -> Bool { return userObjectId != nil }
}


class UserStatusesProductListRequester: UserProductListRequester {

    let statuses: [ProductStatus]
    let productRepository: ProductRepository
    let locationManager: LocationManager

    var userObjectId: String? = nil

    convenience init(statuses: [ProductStatus]) {
        self.init(productRepository: Core.productRepository, locationManager: Core.locationManager, statuses: statuses)
    }

    init(productRepository: ProductRepository, locationManager: LocationManager, statuses: [ProductStatus]) {
        self.productRepository = productRepository
        self.locationManager = locationManager
        self.statuses = statuses
    }

    func canRetrieve() -> Bool { return userObjectId != nil }

    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        guard let params = retrieveProductsParams else { return }
        guard let userId = userObjectId else { return  }
        productRepository.index(userId: userId, params: params, pageOffset: offset, completion: completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount == 0
    }

    private var retrieveProductsParams: RetrieveProductsParams? {
        var params: RetrieveProductsParams = RetrieveProductsParams()
        if let currentLocation = locationManager.currentLocation {
            params.coordinates = LGLocationCoordinates2D(location: currentLocation)
        }
        params.countryCode = locationManager.currentPostalAddress?.countryCode
        params.sortCriteria = .Creation
        params.statuses = statuses
        return params
    }
}
