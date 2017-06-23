//
//  ListingRepositoryParams.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 27/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

// MARK: - PARAMS

public struct RetrieveListingParam<T: Equatable> {
    public let value: T
    public let isNegated: Bool
    
    public init(value: T, isNegated: Bool) {
        self.value = value
        self.isNegated = isNegated
    }
}

public struct RetrieveListingParams {
    public var queryString: String?
    public var coordinates: LGLocationCoordinates2D?
    public var countryCode: String?
    public var categoryIds: [Int]?
    public var sortCriteria: ListingSortCriteria?
    public var timeCriteria: ListingTimeCriteria?
    public var offset: Int?                 // skip results
    public var numProducts: Int?            // number products to return
    public var statuses: [ListingStatus]?   // Default 1,3
    public var maxPrice: Int?
    public var minPrice: Int?
    public var freePrice: Bool?
    public var distanceRadius: Int?
    public var distanceType: DistanceType?
    public var makeId: RetrieveListingParam<String>?
    public var modelId: RetrieveListingParam<String>?
    public var startYear: RetrieveListingParam<Int>?
    public var endYear: RetrieveListingParam<Int>?
    public var abtest: String?
    
    public init() { }
    
    var relatedProductsApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["num_results"] = numProducts
        params["offset"] = offset
        return params
    }
    
    var userListingApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        
        params["num_results"] = numProducts
        params["offset"] = offset
        params["country_code"] = countryCode

        if let statuses = statuses {
            if statuses.contains(.sold) || statuses.contains(.soldOld) {
                params["status"] = UserListingStatus.sold.rawValue
            } else {
                params["status"] = UserListingStatus.selling.rawValue
            }
        }
        return params
    }
    
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["search_term"] = queryString
        params["quadkey"] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        // In case country code is empty we send the request without it.
        if countryCode != "" {
            params["country_code"] = countryCode
        }
        let categories = categoryIds?.map { String($0) }.joined(separator: ",")
        if categories != "" {
            params["categories"] = categories
        }
        if let freePrice = freePrice, freePrice {
            params["price_flag"] = ListingPriceFlag.free.rawValue
        }
        params["max_price"] = maxPrice
        params["min_price"] = minPrice
        params["distance_radius"] = distanceRadius
        params["distance_type"] = distanceType?.string
        params["num_results"] = numProducts
        params["offset"] = offset
        params["sort"] = sortCriteria?.string
        params["since"] = timeCriteria?.string
        params["abtest"] = abtest
        
        // Car attributes
        var carsPositiveAttrs = [String: Any]()
        var carsNegativeAttrs = [String: Any]()
        
        if let makeId = makeId {
            let value = makeId.value
            if makeId.isNegated {
                carsNegativeAttrs["make"] = value
            } else {
                carsPositiveAttrs["make"] = value
            }
        }
        if let modelId = modelId {
            let value = modelId.value
            if modelId.isNegated {
                carsNegativeAttrs["model"] = value
            } else {
                carsPositiveAttrs["model"] = value
            }
        }
        if let startYear = startYear {
            let value = startYear.value
            if startYear.isNegated {
                carsNegativeAttrs["start_year"] = value
            } else {
                carsPositiveAttrs["start_year"] = value
            }
        }
        if let endYear = endYear {
            let value = endYear.value
            if endYear.isNegated {
                carsNegativeAttrs["end_year"] = value
            } else {
                carsPositiveAttrs["end_year"] = value
            }
        }
        
        if carsPositiveAttrs.keys.count > 0 {
            params["attributes"] = carsPositiveAttrs
        }
        if carsNegativeAttrs.keys.count > 0 {
            params["negative_attributes"] = carsNegativeAttrs
        }
        return params
    }
}

public struct IndexTrendingListingsParams {
    let countryCode: String?
    let coordinates: LGLocationCoordinates2D?
    let numProducts: Int?            // number products to return
    let offset: Int                  // skip results

    public init(countryCode: String?, coordinates: LGLocationCoordinates2D?, numProducts: Int? = nil, offset: Int = 0) {
        self.countryCode = countryCode
        self.coordinates = coordinates
        self.numProducts = numProducts
        self.offset = offset
    }

    public func paramsWithOffset(_ offset: Int) -> IndexTrendingListingsParams {
        return IndexTrendingListingsParams(countryCode: countryCode, coordinates: coordinates,
                                           numProducts: numProducts, offset: offset)
    }
    
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["quadkey"] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        params["country_code"] = countryCode
        params["num_results"] = numProducts
        params["offset"] = offset
        return params
    }
}

public class ProductEditionParams: ProductCreationParams {
    let productId: String
    let userId: String

    public convenience init?(listing: Listing) {
        guard let productId = listing.objectId, let userId = listing.user.objectId else { return nil }
        let editedProduct: Product
        switch listing {
        case let .car(car):
            editedProduct = ProductEditionParams.createProductParams(withCar: car)
        case let .product(product):
            editedProduct = product
        }
        self.init(product: editedProduct,
                  productId: productId,
                  userId: userId)
    }

    public convenience init?(product: Product) {
        guard let productId = product.objectId, let userId = product.user.objectId else { return nil }
        self.init(product: product,
                  productId: productId,
                  userId: userId)
    }

    init(product: Product,
         productId: String,
         userId: String) {
        self.productId = productId
        self.userId = userId
        super.init(name: product.name,
                   description: product.descr,
                   price: product.price,
                   category: product.category,
                   currency: product.currency,
                   location: product.location,
                   postalAddress: product.postalAddress,
                   languageCode: product.languageCode ?? Locale.current.identifier,
                   images: product.images)
        if let languageCode = product.languageCode {
            self.languageCode = languageCode
        }
    }

    func apiEditionEncode() -> [String: Any] {
        return super.apiCreationEncode(userId: userId)
    }

    static private func createProductParams(withCar car: Car) -> Product {
        let product = LGProduct(objectId: car.objectId, updatedAt: car.updatedAt, createdAt: car.createdAt, name: car.name,
                                nameAuto: car.nameAuto, descr: car.descr, price: car.price, currency: car.currency,
                                location: car.location, postalAddress: car.postalAddress, languageCode: car.languageCode,
                                category: .motorsAndAccessories, status: car.status, thumbnail: car.thumbnail, thumbnailSize: car.thumbnailSize,
                                images: car.images, user: car.user, featured: car.featured)
        return product
    }
}

public class ProductCreationParams {

    public var name: String?
    public var descr: String?
    public var price: ListingPrice
    public var category: ListingCategory
    public var currency: Currency
    public var location: LGLocationCoordinates2D
    public var postalAddress: PostalAddress
    public var images: [File]
    var languageCode: String

    public convenience init(name: String?,
                            description: String?,
                            price: ListingPrice,
                            category: ListingCategory,
                            currency: Currency,
                            location: LGLocationCoordinates2D,
                            postalAddress: PostalAddress,
                            images: [File]) {
        self.init(name: name,
                  description: description,
                  price: price,
                  category: category,
                  currency: currency,
                  location: location,
                  postalAddress: postalAddress,
                  languageCode: Locale.current.identifier,
                  images: images)
    }
    
    public init(name: String?,
                description: String?,
                price: ListingPrice,
                category: ListingCategory,
                currency: Currency,
                location: LGLocationCoordinates2D,
                postalAddress: PostalAddress,
                languageCode: String,
                images: [File]) {
        self.name = name
        self.descr = description
        self.price = price
        self.category = category
        self.currency = currency
        self.location = location
        self.postalAddress = postalAddress
        self.languageCode = languageCode
        self.images = images
    }

    func apiCreationEncode(userId: String) -> [String: Any] {
        var params: [String: Any] = [:]
        params["name"] = name
        params["category"] = category.rawValue
        params["languageCode"] = languageCode
        params["userId"] = userId
        params["description"] = descr
        params["price"] = price.value
        params["price_flag"] = price.priceFlag.rawValue
        params["currency"] = currency.code
        params["latitude"] = location.latitude
        params["longitude"] = location.longitude
        params["countryCode"] = postalAddress.countryCode
        params["city"] = postalAddress.city
        params["address"] = postalAddress.address
        params["zipCode"] = postalAddress.zipCode

        let tokensString = images.flatMap{$0.objectId}.map{"\"" + $0 + "\""}.joined(separator: ",")
        params["images"] = "[" + tokensString + "]"

        return params
    }
}

public class CarCreationParams {
    
    public var name: String?
    public var descr: String?
    public var price: ListingPrice
    public var category: ListingCategory
    public var currency: Currency
    public var location: LGLocationCoordinates2D
    public var postalAddress: PostalAddress
    public var images: [File]
    var languageCode: String
    public var carAttributes: CarAttributes
    
    public init(name: String?, description: String?, price: ListingPrice, category: ListingCategory,
                currency: Currency, location: LGLocationCoordinates2D, postalAddress: PostalAddress, images: [File],
                carAttributes: CarAttributes) {
        self.name = name
        self.descr = description
        self.price = price
        self.category = category
        self.currency = currency
        self.location = location
        self.postalAddress = postalAddress
        self.languageCode = Locale.current.identifier
        self.images = images
        self.carAttributes = carAttributes
    }
    
    func apiCreationEncode(userId: String) -> [String: Any] {
        var params: [String:Any] = [:]
        params["name"] = name
        params["category"] = category.rawValue
        params["languageCode"] = languageCode
        params["userId"] = userId
        params["description"] = descr
        params["price"] = price.value
        params["price_flag"] = price.priceFlag.rawValue
        params["currency"] = currency.code
        params["latitude"] = location.latitude
        params["longitude"] = location.longitude
        params["countryCode"] = postalAddress.countryCode
        params["city"] = postalAddress.city
        params["address"] = postalAddress.address
        params["zipCode"] = postalAddress.zipCode
        
        let tokensString = images.flatMap{$0.objectId}.map{"\"" + $0 + "\""}.joined(separator: ",")
        params["images"] = "[" + tokensString + "]"

        var carAttributesDict: [String:Any] = [:]
        carAttributesDict["make"] = carAttributes.makeId ?? ""
        carAttributesDict["model"] = carAttributes.modelId ?? ""
        carAttributesDict["year"] = carAttributes.year ?? 0

        params["attributes"] = carAttributesDict
        
        return params
    }
}

public class CarEditionParams: CarCreationParams {
    let carId: String
    let userId: String

    public convenience init?(listing: Listing) {
        guard let carId = listing.objectId, let userId = listing.user.objectId else { return nil }
        let editedCar: Car
        switch listing {
        case let .car(car):
            editedCar = car
        case let .product(product):
            editedCar = CarEditionParams.createCarParams(withProduct: product)
        }
        self.init(car: editedCar, carId: carId, userId: userId)
    }

    public convenience init?(car: Car) {
        guard let carId = car.objectId, let userId = car.user.objectId else { return nil }
        self.init(car: car, carId: carId, userId: userId)
    }
    
    init(car: Car, carId: String, userId: String) {
        self.carId = carId
        self.userId = userId
        super.init(name: car.name,
                   description: car.descr,
                   price: car.price,
                   category: car.category,
                   currency: car.currency,
                   location: car.location,
                   postalAddress: car.postalAddress,
                   images: car.images,
                   carAttributes: car.carAttributes)
        if let languageCode = car.languageCode {
            self.languageCode = languageCode
        }
    }
    
    func apiEditionEncode() -> [String: Any] {
        return super.apiCreationEncode(userId: userId)
    }

    static private func createCarParams(withProduct product: Product) -> Car {
        let car = LGCar(objectId: product.objectId, updatedAt: product.updatedAt, createdAt: product.createdAt, name: product.name,
                        nameAuto: product.nameAuto, descr: product.descr, price: product.price, currency: product.currency,
                        location: product.location, postalAddress: product.postalAddress, languageCode: product.languageCode,
                        category: .cars, status: product.status, thumbnail: product.thumbnail, thumbnailSize: product.thumbnailSize,
                        images: product.images, user: product.user, featured: product.featured, carAttributes: nil)
        return car
    }
}

public enum SoldIn: String {
    case letgo = "letgo"
    case external = "external"
    
    public static let allValues: [SoldIn] = [.letgo, .external]
}


public struct CreateTransactionParams {
    let listingId: String
    let buyerId: String?
    let soldIn: SoldIn?
    
    public init(listingId: String, buyerId: String?, soldIn: SoldIn?) {
        self.listingId = listingId
        self.buyerId = buyerId
        self.soldIn = soldIn
    }
    
    
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["productId"] = listingId
        params["buyerUserId"] = buyerId
        params["soldIn"] = soldIn?.rawValue
        return params
    }
}


// MARK: - ENUMS & STRUCTS

public enum ListingSortCriteria: Int, Equatable {
    case distance = 1, priceAsc = 2, priceDesc = 3, creation = 4
    var string: String? {
        get {
            switch self {
            case .distance:
                return "distance"
            case .priceAsc:
                return "price_asc"
            case .priceDesc:
                return "price_desc"
            case .creation:
                return "recent"
            }
        }
    }
}

public enum ListingTimeCriteria: Int, Equatable {
    case day = 1, week = 2, month = 3, all = 4
    var string : String? {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .all:
            return nil
        }
    }
}

public enum UserListingStatus: String {
    case selling = "selling"
    case sold = "sold"
}
