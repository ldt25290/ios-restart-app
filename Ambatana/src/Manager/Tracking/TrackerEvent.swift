//
//  TrackerEvent.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

func ==(a: TrackerEvent, b: TrackerEvent) -> Bool {
    if a.name == b.name && a.actualName == b.actualName,
        let paramsA = a.params, let paramsB = b.params {
        return paramsA.stringKeyParams.keys.count == paramsB.stringKeyParams.keys.count
    }
    return false
}

struct TrackerEvent {
    static let notApply: String = "N/A"
    fileprivate static let itemsCountThreshold = 50

    private(set) var name: EventName
    var actualName: String {
        return name.rawValue
    }
    private(set) var params: EventParameters?

    static func location(locationType: LGLocationType?,
                         locationServiceStatus: LocationServiceStatus,
                         typePage: EventParamenterLocationTypePage,
                         zipCodeFilled: Bool?,
                         distanceRadius: Int?) -> TrackerEvent {
        var params = EventParameters()
        if let locationType = locationType {
            params[.locationType] = locationType.rawValue
        }
        params[.typePage] = typePage.rawValue
        if let zipCodeFilled = zipCodeFilled {
            params[.zipCode] = zipCodeFilled ? EventParameterBoolean.trueParameter.rawValue : EventParameterBoolean.falseParameter.rawValue
        } else {
            params[.zipCode] = EventParameterBoolean.notAvailable.rawValue
        }
        if let distanceRadius = distanceRadius {
            params[.filterDistanceRadius] = distanceRadius
        } else {
            params[.filterDistanceRadius] = "default"
        }
        let enabled: Bool
        let allowed: Bool
        switch locationServiceStatus {
        case .enabled(let authStatus):
            enabled = true
            switch authStatus {
            case .authorized:
                allowed = true
            case .notDetermined, .restricted, .denied:
                allowed = false
            }
        case .disabled:
            enabled = false
            allowed = false
            break
        }
        params[.locationEnabled] = enabled
        params[.locationAllowed] = allowed
        return TrackerEvent(name: .location, params: params)
    }

    static func loginVisit(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .loginVisit, params: params)
    }

    static func loginAbandon(_ source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .loginAbandon, params: params)
    }

    static func loginFB(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .loginFB, params: params)
    }
    
    static func loginGoogle(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .loginGoogle, params: params)
    }

    static func loginEmail(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .loginEmail, params: params)
    }

    static func signupEmail(_ source: EventParameterLoginSourceValue, newsletter: EventParameterBoolean)
        -> TrackerEvent {
            var params = EventParameters()
            params.addLoginParams(source)
            params[.newsletter] = newsletter.rawValue
            return TrackerEvent(name: .signupEmail, params: params)
    }

    static func logout() -> TrackerEvent {
        return TrackerEvent(name: .logout, params: nil)
    }

    static func passwordResetVisit() -> TrackerEvent {
        return TrackerEvent(name: .passwordResetVisit, params: nil)
    }

    static func loginEmailError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .loginEmailError, params: params)
    }

    static func loginFBError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .loginFBError, params: params)
    }

    static func loginGoogleError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .loginGoogleError, params: params)
    }

    static func signupError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .signupError, params: params)
    }

    static func passwordResetError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .passwordResetError, params: params)
    }

    static func loginBlockedAccountStart(_ network: EventParameterAccountNetwork, reason: EventParameterBlockedAccountReason) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .loginBlockedAccountStart, params: params)
    }

    static func loginBlockedAccountContactUs(_ network: EventParameterAccountNetwork, reason: EventParameterBlockedAccountReason) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .loginBlockedAccountContactUs, params: params)
    }

    static func loginBlockedAccountKeepBrowsing(_ network: EventParameterAccountNetwork, reason: EventParameterBlockedAccountReason) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .loginBlockedAccountKeepBrowsing, params: params)
    }

    static func listingList(_ user: User?, categories: [ListingCategory]?, taxonomy: TaxonomyChild?, searchQuery: String?,
                            resultsCount: ItemsCount?, feedSource: EventParameterFeedSource, success: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()

        params[.feedSource] = feedSource.rawValue
        params[.categoryId] = TrackerEvent.stringFrom(categories: categories)
        params[.keywordName] = taxonomy?.name ?? TrackerEvent.notApply
        // Search query
        if let actualSearchQuery = searchQuery {
            params[.searchString] = actualSearchQuery
        }
        if let count = resultsCount {
            params[.numberOfItems] = count.value
        }
        params[.listSuccess] = success.rawValue
        return TrackerEvent(name: .listingList, params: params)
    }
    
    static func listingListVertical(category: ListingCategory, keywords: [String],
                                    matchingFields: [String], nonMatchingFields: [String]) -> TrackerEvent {
        var params = EventParameters()
        params[.categoryId] = String(category.rawValue)
        params[.verticalKeyword] = keywords.isEmpty ? TrackerEvent.notApply : keywords.joined(separator: "_")
        params[.verticalMatchingFields] = matchingFields.isEmpty ? TrackerEvent.notApply : matchingFields.joined(separator: ",")
        params[.verticalNoMatchingFields] = nonMatchingFields.isEmpty ? TrackerEvent.notApply : nonMatchingFields.joined(separator: ",")

        return TrackerEvent(name: .listingListVertical, params: params)
    }

    static func exploreCollection(_ collectionTitle: String) -> TrackerEvent {
        var params = EventParameters()
        params[.collectionTitle] = collectionTitle
        return TrackerEvent(name: .exploreCollection, params: params)
    }

    static func searchStart(_ user: User?) -> TrackerEvent {
        let params = EventParameters()

        return TrackerEvent(name: .searchStart, params: params)
    }

    static func searchComplete(_ user: User?, searchQuery: String, isTrending: Bool, success: EventParameterSearchCompleteSuccess, isLastSearch: Bool, isSuggestiveSearch: Bool, suggestiveSearchIndex: Int?)
        -> TrackerEvent {
            var params = EventParameters()
            params[.searchString] = searchQuery
            params[.searchSuccess] = success.rawValue
            params[.trendingSearch] = isTrending
            params[.lastSearch] = isLastSearch
            params[.searchSuggestion] = isSuggestiveSearch
            if let suggestiveSearchPosition = suggestiveSearchIndex {
                params[.searchSuggestionPosition] = suggestiveSearchPosition
            }
            return TrackerEvent(name: .searchComplete, params: params)
    }

    static func filterStart() -> TrackerEvent {
        return TrackerEvent(name: .filterStart, params: nil)
    }

    static func filterLocationStart() -> TrackerEvent {
        return TrackerEvent(name: .filterLocationStart, params: nil)
    }

    static func filterComplete(_ coordinates: LGLocationCoordinates2D?, distanceRadius: Int?,
                               distanceUnit: DistanceType, categories: [ListingCategory]?, sortBy: ListingSortCriteria?,
                               postedWithin: ListingTimeCriteria?, priceRange: FilterPriceRange, freePostingModeAllowed: Bool,
                               carSellerType: String?, carMake: String?, carModel: String?, carYearStart: Int?, carYearEnd: Int?, propertyType: String?,
                               offerType: [String]?, bedrooms: Int?, bathrooms: Float?, sizeSqrMetersMin: Int?,
                               sizeSqrMetersMax: Int?, rooms: NumberOfRooms?) -> TrackerEvent {
        var params = EventParameters()

        // Filter Coordinates
        if let actualCoords = coordinates {
            params[.filterLat] = actualCoords.latitude
            params[.filterLng] = actualCoords.longitude
        } else {
            params[.filterLat] = "default"
            params[.filterLng] = "default"
        }

        // Distance
        params[.filterDistanceRadius] = distanceRadius ?? "default"
        params[.filterDistanceUnit] = distanceUnit.string

        // Categories
        params[.categoryId] = TrackerEvent.stringFrom(categories: categories)

        // Sorting
        if let sortByParam = eventParameterSortByTypeForSorting(sortBy) {
            params[.filterSortBy] = sortByParam.rawValue
        }
        if let postedWithin = eventParameterPostedWithinForTime(postedWithin) {
            params[.filterPostedWithin] = postedWithin.rawValue
        }

        params[.priceFrom] = eventParameterHasPriceFilter(priceRange.min).rawValue
        params[.priceTo] = eventParameterHasPriceFilter(priceRange.max).rawValue
        
        params[.freePosting] = eventParameterFreePostingWithPriceRange(freePostingModeAllowed, priceRange: priceRange).rawValue

        var verticalFields: [String] = []

        if let carSellerType = carSellerType {
            params[.carSellerType] = carSellerType
        }
        
        if let make = carMake {
            params[.make] = make
            verticalFields.append(EventParameterName.make.rawValue)
        } else {
            params[.make] = TrackerEvent.notApply
        }
        if let make = carModel {
            params[.model] = make
            verticalFields.append(EventParameterName.model.rawValue)
        } else {
            params[.model] = TrackerEvent.notApply
        }

        if let carYearStart = carYearStart {
            params[.yearStart] = String(carYearStart)
            verticalFields.append(EventParameterName.yearStart.rawValue)
        } else {
            params[.yearStart] = TrackerEvent.notApply
        }
        if let carYearEnd = carYearEnd {
            params[.yearEnd] = String(carYearEnd)
            verticalFields.append(EventParameterName.yearEnd.rawValue)
        } else {
            params[.yearEnd] = TrackerEvent.notApply
        }
        
        if let propertyType = propertyType {
            params[.propertyType] = String(propertyType)
            verticalFields.append(EventParameterName.propertyType.rawValue)
        } else {
            params[.propertyType] = TrackerEvent.notApply
        }
        
        if let offerType = offerType {
            params[.offerType] = offerType.joined(separator: ",")
            verticalFields.append(EventParameterName.offerType.rawValue)
        } else {
            params[.offerType] = TrackerEvent.notApply
        }
        
        if let bedrooms = bedrooms {
            params[.bedrooms] = String(bedrooms)
            verticalFields.append(EventParameterName.bedrooms.rawValue)
        } else {
            params[.bedrooms] = TrackerEvent.notApply
        }
        
        if let bathrooms = bathrooms {
            params[.bathrooms] = String(bathrooms)
            verticalFields.append(EventParameterName.bathrooms.rawValue)
        } else {
            params[.bathrooms] = TrackerEvent.notApply
        }
        
        if let sizeSqrMetersMin = sizeSqrMetersMin {
            params[.sizeSqrMetersMin] = String(sizeSqrMetersMin)
            verticalFields.append(EventParameterName.sizeSqrMetersMin.rawValue)
        } else {
            params[.sizeSqrMeters] = TrackerEvent.notApply
        }
        
        if let sizeSqrMetersMax = sizeSqrMetersMax {
            params[.sizeSqrMetersMax] = String(sizeSqrMetersMax)
            verticalFields.append(EventParameterName.sizeSqrMetersMax.rawValue)
        } else {
            params[.sizeSqrMetersMax] = TrackerEvent.notApply
        }
        
        if let rooms = rooms {
            params[.rooms] = rooms.trackingString
            verticalFields.append(EventParameterName.rooms.rawValue)
        } else {
            params[.rooms] = TrackerEvent.notApply
        }

        params[.verticalFields] = verticalFields.isEmpty ? TrackerEvent.notApply : verticalFields.joined(separator: ",")

        return TrackerEvent(name: .filterComplete, params: params)
    }

    static func listingVisitPhotoViewer(_ listing: Listing,
                                        source: EventParameterListingVisitSource,
                                        numberOfPictures: Int) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.listingVisitSource] = source.rawValue
        params[.photoViewerNumberOfPhotos] = numberOfPictures
        return TrackerEvent(name: .listingVisitPhotoViewer, params: params)
    }

    static func listingVisitPhotoChat(_ listing: Listing,
                                        source: EventParameterListingVisitSource) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.listingVisitSource] = source.rawValue
        return TrackerEvent(name: .listingVisitPhotoChat, params: params)
    }


    static func listingDetailVisit(_ listing: Listing, visitUserAction: ListingVisitUserAction,
                source: EventParameterListingVisitSource, feedPosition: EventParameterFeedPosition,
                isBumpedUp: EventParameterBoolean, containsVideo: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.userAction] = visitUserAction.rawValue
        params[.listingVisitSource] = source.rawValue
        params[.feedPosition] = feedPosition.value
        params[.isBumpedUp] = isBumpedUp.rawValue
        params[.isVideo] = containsVideo.rawValue
        return TrackerEvent(name: .listingDetailVisit, params: params)
    }

    static func listingDetailCall(_ listing: Listing,
                                  source: EventParameterListingVisitSource,
                                  typePage: EventParameterTypePage,
                                  sellerAverageUserRating: Float?,
                                  feedPosition: EventParameterFeedPosition,
                                  isFreePosting: EventParameterBoolean,
                                  isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.listingVisitSource] = source.rawValue
        params[.sellerUserRating] = sellerAverageUserRating
        params[.typePage] = typePage.rawValue
        params[.feedPosition] = feedPosition.value
        params[.freePosting] = isFreePosting.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .listingDetailCall, params: params)
    }

    static func chatBannerCall(_ chatListing: ChatListing,
                               source: EventParameterListingVisitSource,
                               typePage: EventParameterTypePage,
                               sellerAverageUserRating: Float?,
                               isFreePosting: EventParameterBoolean,
                               isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addChatListingParams(chatListing)
        params[.listingVisitSource] = source.rawValue
        params[.sellerUserRating] = sellerAverageUserRating
        params[.typePage] = typePage.rawValue
        params[.feedPosition] = EventParameterFeedPosition.none.value
        params[.freePosting] = isFreePosting.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .listingDetailCall, params: params)
    }

    static func listingNotAvailable(_ source: EventParameterListingVisitSource, reason: EventParameterNotAvailableReason) -> TrackerEvent {
        var params = EventParameters()
        params[.listingVisitSource] = source.rawValue
        params[.notAvailableReason] = reason.rawValue
        return TrackerEvent(name: .listingNotAvailable, params: params)
    }

    static func listingDetailVisitMoreInfo(_ listing: Listing,
                                           isMine: EventParameterBoolean,
                                           adShown: EventParameterBoolean,
                                           adType: EventParameterAdType?,
                                           queryType: EventParameterAdQueryType?,
                                           query: String?,
                                           visibility: EventParameterAdVisibility?,
                                           errorReason: EventParameterAdSenseRequestErrorReason?) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)

        params[.isMine] = isMine.rawValue
        params[.adShown] = adShown.rawValue
        params[.adType] = adType?.rawValue ?? TrackerEvent.notApply
        params[.adQueryType] = queryType?.rawValue ?? TrackerEvent.notApply
        params[.adQuery] = query ?? TrackerEvent.notApply
        params[.adVisibility] = visibility?.rawValue ?? TrackerEvent.notApply
        params[.reason] = errorReason?.rawValue ?? TrackerEvent.notApply

        return TrackerEvent(name: .listingDetailVisitMoreInfo, params: params)
    }

    static func adTapped(listingId: String?,
                                 adType: EventParameterAdType?,
                                 isMine: EventParameterBoolean,
                                 queryType: EventParameterAdQueryType?,
                                 query: String?,
                                 willLeaveApp: EventParameterBoolean,
                                 typePage: EventParameterTypePage,
                                 categories: [ListingCategory]?,
                                 feedPosition: EventParameterFeedPosition) -> TrackerEvent {
        var params = EventParameters()

        params[.listingId] = listingId ?? TrackerEvent.notApply
        params[.adType] = adType?.rawValue ?? TrackerEvent.notApply
        params[.isMine] = isMine.rawValue
        params[.adQueryType] = queryType?.rawValue ?? TrackerEvent.notApply
        params[.adQuery] = query ?? TrackerEvent.notApply
        params[.adActionLeftApp] = willLeaveApp.rawValue
        params[.typePage] = typePage.rawValue
        params[.feedPosition] = feedPosition.value
        params[.categoryId] = TrackerEvent.stringFrom(categories: categories)

        return TrackerEvent(name: .adTapped, params: params)
    }

    static func listingFavorite(_ listing: Listing, typePage: EventParameterTypePage,
                                isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.typePage] = typePage.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .listingFavorite, params: params)
    }

    static func listingShare(_ listing: Listing, network: EventParameterShareNetwork?,
                             buttonPosition: EventParameterButtonPosition,
                             typePage: EventParameterTypePage, isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)

        // When starting share if native then the network is considered as N/A
        var actualNetwork = network ?? .notAvailable
        switch actualNetwork {
        case .native:
            actualNetwork = .notAvailable
        case .email, .facebook, .whatsapp, .twitter, .fbMessenger, .telegram, .sms, .copyLink, .notAvailable:
            break
        }
        params[.shareNetwork] = actualNetwork.rawValue
        params[.buttonPosition] = buttonPosition.rawValue
        params[.typePage] = typePage.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .listingShare, params: params)
    }

    static func listingShareCancel(_ listing: Listing, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addListingParams(listing)
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .listingShareCancel, params: params)
    }

    static func listingShareComplete(_ listing: Listing, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addListingParams(listing)
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .listingShareComplete, params: params)
    }

    static func listingDetailOpenChat(_ listing: Listing, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .listingOpenChat, params: params)
    }

    static func listingMarkAsSold(trackingInfo: MarkAsSoldTrackingInfo) -> TrackerEvent {
        let params = trackingInfo.makeEventParameters()
        return TrackerEvent(name: .listingMarkAsSold, params: params)
    }
    
    static func listingMarkAsSoldAtLetgo(trackingInfo: MarkAsSoldTrackingInfo) -> TrackerEvent {
        let params = trackingInfo.makeEventParameters()
        return TrackerEvent(name: .listingMarkAsSoldAtLetgo, params: params)
    }
    
    static func listingMarkAsSoldOutsideLetgo(trackingInfo: MarkAsSoldTrackingInfo) -> TrackerEvent {
        let params = trackingInfo.makeEventParameters()
        return TrackerEvent(name: .listingMarkAsSoldOutsideLetgo, params: params)
    }

    static func listingMarkAsUnsold(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId
        params[.listingPrice] = listing.price.value
        params[.listingCurrency] = listing.currency.code
        params[.categoryId] = listing.category.rawValue
        return TrackerEvent(name: .listingMarkAsUnsold, params: params)
    }

    static func listingReport(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        return TrackerEvent(name: .listingReport, params: params)
    }
    
    static func listingReportError(_ reportError: EventParameterProductReportError) -> TrackerEvent {
        var params = EventParameters()
        params.addRepositoryErrorParams(reportError)
        return TrackerEvent(name: .listingReportError, params: params)
    }

    static func listingSellStart(_ typePage: EventParameterTypePage,
                                 buttonName: EventParameterButtonNameType?,
                                 sellButtonPosition: EventParameterSellButtonPosition,
                                 category: ListingCategory?,
                                 mostSearchedButton: EventParameterMostSearched,
                                 predictiveFlow: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.buttonName] = buttonName?.rawValue
        params[.sellButtonPosition] = sellButtonPosition.rawValue
        params[.categoryId] = category?.rawValue ?? TrackerEvent.notApply
        params[.mostSearchedButton] = mostSearchedButton.rawValue
        params[.mlPredictiveFlow] = predictiveFlow
        return TrackerEvent(name: .listingSellStart, params: params)
    }
    
    static func listingSellComplete(_ listing: Listing,
                                    buttonName: EventParameterButtonNameType?,
                                    sellButtonPosition: EventParameterSellButtonPosition?,
                                    negotiable: EventParameterNegotiablePrice?,
                                    pictureSource: EventParameterPictureSource?,
                                    videoLength: TimeInterval?,
                                    freePostingModeAllowed: Bool,
                                    typePage: EventParameterTypePage,
                                    mostSearchedButton: EventParameterMostSearched,
                                    machineLearningTrackingInfo: MachineLearningTrackingInfo) -> TrackerEvent {
        var params = EventParameters()
        params[.freePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: listing.price).rawValue
        params[.listingId] = listing.objectId ?? ""
        params[.categoryId] = listing.category.rawValue
        params[.listingName] = listing.name ?? ""
        params[.numberPhotosPosting] = listing.images.count
        params[.sellButtonPosition] = sellButtonPosition?.rawValue
        params[.listingDescription] = !(listing.descr?.isEmpty ?? true)
        params[.typePage] = typePage.rawValue
        params[.mostSearchedButton] = mostSearchedButton.rawValue
        if let buttonName = buttonName {
            params[.buttonName] = buttonName.rawValue
        }
        if let negotiable = negotiable {
            params[.negotiablePrice] = negotiable.rawValue
        }
        if let pictureSource = pictureSource {
            params[.pictureSource] = pictureSource.rawValue
        }

        if let videoLength = videoLength {
            params[.videoLength] = videoLength
        }

        switch listing {
        case .car:
            params[.postingType] = EventParameterPostingType.car.rawValue
        case .product:
            params[.postingType] = EventParameterPostingType.stuff.rawValue
        case .realEstate:
            params[.postingType] = EventParameterPostingType.realEstate.rawValue
        }

        
        params[.make] = EventParameterMake.make(name: listing.car?.carAttributes.make).name
        params[.model] = EventParameterModel.model(name: listing.car?.carAttributes.model).name
        params[.year] = EventParameterYear.year(year: listing.car?.carAttributes.year).year
        
        if let realEstateAttributes = listing.realEstate?.realEstateAttributes {
            params[.propertyType] = EventParameterStringRealEstate.realEstateParam(name: realEstateAttributes.propertyType?.rawValue).name
            params[.offerType] = EventParameterStringRealEstate.realEstateParam(name: realEstateAttributes.offerType?.rawValue).name
            params[.bathrooms] = EventParameterBathroomsRealEstate.bathrooms(value: realEstateAttributes.bathrooms).name
            params[.bedrooms] = EventParameterBedroomsRealEstate.bedrooms(value: realEstateAttributes.bedrooms).name
            params[.rooms] = EventParameterRoomsRealEstate.rooms(bedrooms: realEstateAttributes.bedrooms, livingRooms: realEstateAttributes.livingRooms).name
            params[.sizeSqrMeters] = EventParameterSizeRealEstate.size(value: realEstateAttributes.sizeSquareMeters).name
        } else {
            params[.propertyType] = EventParameterStringRealEstate.notApply.name
            params[.offerType] = EventParameterStringRealEstate.notApply.name
            params[.bathrooms] = EventParameterBathroomsRealEstate.notApply.name
            params[.bedrooms] = EventParameterBedroomsRealEstate.notApply.name
            params[.rooms] = EventParameterRoomsRealEstate.notApply.name
            params[.sizeSqrMeters] = EventParameterSizeRealEstate.notApply.name
        }
    
        params[.mlPredictiveFlow] = machineLearningTrackingInfo.predictiveFlow
        params[.mlPredictionActive] = machineLearningTrackingInfo.predictionActive
        if let machineLearningData = machineLearningTrackingInfo.data {
            params[.mlPredictedTitle] = machineLearningData.predictedTitle
            params[.mlPredictedPrice] = machineLearningData.predictedPrice
            params[.mlPredictedCategory] = machineLearningData.predictedCategory?.rawValue ?? nil
            params[.listingName] = machineLearningData.title
            params[.listingPrice] = machineLearningData.price
            params[.mlListingCategory] = machineLearningData.category?.rawValue ?? nil
        }
        
        return TrackerEvent(name: .listingSellComplete, params: params)
    }
    
    static func predictedPosting(data: MLPredictionDetailsViewData) -> TrackerEvent {
        var params = EventParameters()
        params[.mlPredictedTitle] = data.predictedTitle
        params[.mlPredictedPrice] = data.predictedPrice
        params[.mlPredictedCategory] = data.predictedCategory?.rawValue ?? nil
        return TrackerEvent(name: .predictedPosting, params: params)
    }
    
    static func listingSellComplete24h(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        return TrackerEvent(name: .listingSellComplete24h, params: params)
    }

    static func listingSellError(_ error: EventParameterPostListingError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        return TrackerEvent(name: .listingSellError, params: params)
    }

    static func listingSellErrorClose(_ error: EventParameterPostListingError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        return TrackerEvent(name: .listingSellErrorClose, params: params)
    }

    static func listingSellErrorPost(_ error: EventParameterPostListingError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        return TrackerEvent(name: .listingSellErrorPost, params: params)
    }

    static func listingSellErrorData(_ error: EventParameterPostListingError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        params[.errorDetails] = error.details
        return TrackerEvent(name: .listingSellErrorData, params: params)
    }

    static func listingSellConfirmation(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        return TrackerEvent(name: .listingSellConfirmation, params: params)
    }

    static func listingSellConfirmationPost(_ listing: Listing, buttonType: EventParameterButtonType) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        params[.buttonType] = buttonType.rawValue
        return TrackerEvent(name: .listingSellConfirmationPost, params: params)
    }

    static func listingSellConfirmationEdit(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        return TrackerEvent(name: .listingSellConfirmationEdit, params: params)
    }

    static func listingSellConfirmationClose(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        return TrackerEvent(name: .listingSellConfirmationClose, params: params)
    }

    static func listingSellConfirmationShare(_ listing: Listing, network: EventParameterShareNetwork)
        -> TrackerEvent {
            var params = EventParameters()
            params[.listingId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .listingSellConfirmationShare, params: params)
    }

    static func listingSellConfirmationShareCancel(_ listing: Listing,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.listingId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .listingSellConfirmationShareCancel, params: params)
    }

    static func listingSellConfirmationShareComplete(_ listing: Listing,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.listingId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .listingSellConfirmationShareComplete, params: params)
    }
    
    static func listingSellAbandon(abandonStep: EventParameterPostingAbandonStep) -> TrackerEvent {
        var params = EventParameters()
        params[.abandonStep] = abandonStep.rawValue
        return TrackerEvent(name: .listingSellAbandon, params: params)
    }

    static func listingEditStart(_ user: User?, listing: Listing, pageType: EventParameterTypePage?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.listingId] = listing.objectId
        if let pageType = pageType {
            params[.typePage] = pageType.rawValue
        }
        return TrackerEvent(name: .listingEditStart, params: params)
    }

    static func listingEditFormValidationFailed(_ user: User?, listing: Listing, description: String)
        -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.listingId] = listing.objectId
            // Validation failure description
            params[.description] = description
            return TrackerEvent(name: .listingEditFormValidationFailed, params: params)
    }

    static func listingEditSharedFB(_ user: User?, listing: Listing?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productId = listing?.objectId {
            params[.listingId] = productId
        }
        return TrackerEvent(name: .listingEditSharedFB, params: params)
    }

    static func listingEditComplete(_ user: User?,
                                    listing: Listing,
                                    category: ListingCategory?,
                                    editedFields: [EventParameterEditedFields],
                                    pageType: EventParameterTypePage?
                                    ) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.listingId] = listing.objectId
        params[.categoryId] = category?.rawValue ?? 0
        params[.editedFields] = editedFields.map({$0.rawValue}).joined(separator: ",")

        params[.make] = EventParameterMake.make(name: listing.car?.carAttributes.make).name
        params[.model] = EventParameterModel.model(name: listing.car?.carAttributes.model).name
        params[.year] = EventParameterYear.year(year: listing.car?.carAttributes.year).year
        
        if let realEstateAttributes = listing.realEstate?.realEstateAttributes {
            params[.propertyType] = EventParameterStringRealEstate.realEstateParam(name: realEstateAttributes.propertyType?.rawValue).name
            params[.offerType] = EventParameterStringRealEstate.realEstateParam(name: realEstateAttributes.offerType?.rawValue).name
            params[.bathrooms] = EventParameterBathroomsRealEstate.bathrooms(value: realEstateAttributes.bathrooms).name
            params[.bedrooms] = EventParameterBedroomsRealEstate.bedrooms(value: realEstateAttributes.bedrooms).name
            params[.rooms] = EventParameterRoomsRealEstate.rooms(bedrooms: realEstateAttributes.bedrooms, livingRooms: realEstateAttributes.livingRooms).name
            params[.sizeSqrMeters] = EventParameterSizeRealEstate.size(value: realEstateAttributes.sizeSquareMeters).name
        } else {
            params[.propertyType] = EventParameterStringRealEstate.notApply.name
            params[.offerType] = EventParameterStringRealEstate.notApply.name
            params[.bathrooms] = EventParameterBathroomsRealEstate.notApply.name
            params[.bedrooms] = EventParameterBedroomsRealEstate.notApply.name
            params[.rooms] = EventParameterRoomsRealEstate.notApply.name
            params[.sizeSqrMeters] = EventParameterSizeRealEstate.notApply.name
        }
        if let pageType = pageType {
            params[.typePage] = pageType.rawValue
        }
        return TrackerEvent(name: .listingEditComplete, params: params)
    }

    static func listingDeleteStart(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId
        return TrackerEvent(name: .listingDeleteStart, params: params)
    }

    static func listingDeleteComplete(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId
        return TrackerEvent(name: .listingDeleteComplete, params: params)
    }

    static func relatedListings(listingId: String,
                                source: EventParameterRelatedListingsVisitSource?) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listingId
        if let src = source {
            params[.relatedSource] = src.rawValue
        }
        return TrackerEvent(name: .relatedListings, params: params)
    }
    
    static func relatedListings(listing: Listing,
                                source: EventParameterRelatedListingsVisitSource?) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        if let src = source {
            params[.relatedSource] = src.rawValue
        }
        return TrackerEvent(name: .relatedListings, params: params)
    }

    static func phoneNumberRequest(typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .phoneNumberRequest, params: params)
    }

    static func phoneNumberSent(typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .phoneNumberSent, params: params)
    }

    static func phoneNumberNotNow(typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .phoneNumberNotNow, params: params)
    }

    static func firstMessage(info: SendMessageTrackingInfo,
                             listingVisitSource: EventParameterListingVisitSource,
                             feedPosition: EventParameterFeedPosition,
                             containsVideo: EventParameterBoolean) -> TrackerEvent {
        var params = info.params
        params[.listingVisitSource] = listingVisitSource.rawValue
        params[.feedPosition] = feedPosition.value
        params[.isVideo] = containsVideo.rawValue
        return TrackerEvent(name: .firstMessage, params: params)
    }

    static func userMessageSent(info: SendMessageTrackingInfo) -> TrackerEvent {
        return TrackerEvent(name: .userMessageSent, params: info.params)
    }

    static func userMessageSentError(info: SendMessageTrackingInfo) -> TrackerEvent {
        return TrackerEvent(name: .userMessageSentError, params: info.params)
    }

    static func chatRelatedItemsStart(_ shownReason: EventParameterRelatedShownReason) -> TrackerEvent {
        var params = EventParameters()
        params[.shownReason] = shownReason.rawValue
        return TrackerEvent(name: .chatRelatedItemsStart, params: params)
    }

    static func chatRelatedItemsComplete(_ itemPosition: Int, shownReason: EventParameterRelatedShownReason) -> TrackerEvent {
        var params = EventParameters()
        params[.itemPosition] = itemPosition
        params[.shownReason] = shownReason.rawValue
        return TrackerEvent(name: .chatRelatedItemsComplete, params: params)
    }

    static func profileVisit(_ user: User, profileType: EventParameterProfileType, typePage: EventParameterTypePage, tab: EventParameterTab)
        -> TrackerEvent {
            var params = EventParameters()
            params[.typePage] = typePage.rawValue
            params[.userToId] = user.objectId
            params[.tab] = tab.rawValue
            params[.profileType] = profileType.rawValue
            return TrackerEvent(name: .profileVisit, params: params)
    }

    static func profileEditStart() -> TrackerEvent {
        return TrackerEvent(name: .profileEditStart, params: nil)
    }

    static func profileEditEditName() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditName, params: nil)
    }

    static func profileEditEditLocationStart() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditLocationStart, params: nil)
    }

    static func profileEditEditPicture() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditPicture, params: nil)
    }

    static func profileShareStart(_ type: EventParameterProfileType)  -> TrackerEvent {
        var params = EventParameters()
        params[.profileType] = type.rawValue
        return TrackerEvent(name: .profileShareStart, params: params)
    }

    static func profileShareComplete(_ type: EventParameterProfileType, shareNetwork: EventParameterShareNetwork)
        -> TrackerEvent {
        var params = EventParameters()
        params[.profileType] = type.rawValue
        params[.shareNetwork] = shareNetwork.rawValue
        return TrackerEvent(name: .profileShareComplete, params: params)
    }
    
    static func profileEditEmailStart(withUserId userId: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        return TrackerEvent(name: .profileEditEmailStart, params: params)
    }
    
    static func profileEditEmailComplete(withUserId userId: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        return TrackerEvent(name: .profileEditEmailComplete, params: params)
    }

    static func profileEditBioComplete(userId: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        return TrackerEvent(name: .profileEditBioComplete, params: params)
    }

    static func appInviteFriendStart(_ typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriendStart, params: params)
    }

    static func appInviteFriend(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriend, params: params)
    }

    static func appInviteFriendCancel(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriendCancel, params: params)
    }

    static func appInviteFriendDontAsk(_ typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriendDontAsk, params: params)
    }

    static func appInviteFriendComplete(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriendComplete, params: params)
    }

    static func appRatingStart(_ source: EventParameterRatingSource) -> TrackerEvent {
        var params = EventParameters()
        params[.appRatingSource] = source.rawValue
        return TrackerEvent(name: .appRatingStart, params: params)
    }

    static func appRatingRate(reason: EventParameterUserDidRateReason?) -> TrackerEvent {
        if let aReason = reason {
            var params = EventParameters()
            params[.appRatingReason] = aReason.rawValue
            return TrackerEvent(name: .appRatingRate, params: params)
        }
        return TrackerEvent(name: .appRatingRate, params: nil)
    }

    static func appRatingSuggest() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .appRatingSuggest, params: params)
    }

    static func appRatingDontAsk() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .appRatingDontAsk, params: params)
    }

    static func appRatingRemindMeLater() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .appRatingRemindMeLater, params: params)
    }

    static func permissionAlertStart(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterBoolean) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            params[.alertType] = alertType.rawValue
            params[.permissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .permissionAlertStart, params: params)
    }

    static func permissionAlertCancel(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterBoolean) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            params[.alertType] = alertType.rawValue
            params[.permissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .permissionAlertCancel, params: params)
    }

    static func permissionAlertComplete(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterBoolean) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            params[.alertType] = alertType.rawValue
            params[.permissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .permissionAlertComplete, params: params)
    }

    static func permissionSystemStart(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .permissionSystemStart, params: params)
    }

    static func permissionSystemCancel(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .permissionSystemCancel, params: params)
    }

    static func permissionSystemComplete(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .permissionSystemComplete, params: params)
    }

    static func profileReport(_ typePage: EventParameterTypePage, reportedUserId: String,
        reason: EventParameterReportReason) -> TrackerEvent{
            var params = EventParameters()
            params[.reportReason] = reason.rawValue
            params[.typePage] = typePage.rawValue
            params[.userToId] = reportedUserId
            return TrackerEvent(name: .profileReport, params: params)
    }

    static func profileBlock(_ typePage: EventParameterTypePage, blockedUsersIds: [String],
                             buttonPosition: EventParameterBlockButtonPosition) -> TrackerEvent{
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.userToId] = blockedUsersIds.joined(separator: ",")
        params[.blockButtonPosition] = buttonPosition.rawValue
        return TrackerEvent(name: .profileBlock, params: params)
    }

    static func profileUnblock(_ typePage: EventParameterTypePage, unblockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.userToId] = unblockedUsersIds.joined(separator: ",")
        return TrackerEvent(name: .profileUnblock, params: params)
    }

    static func userRatingStart(_ userId: String, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.userToId] = userId
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .userRatingStart, params: params)
    }

    static func userRatingComplete(_ userId: String, typePage: EventParameterTypePage,
                                          rating: Int, hasComments: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.userToId] = userId
        params[.typePage] = typePage.rawValue
        params[.ratingStars] = rating
        params[.ratingComments] = hasComments
        return TrackerEvent(name: .userRatingComplete, params: params)
    }

    static func openAppExternal(_ campaign: String? = nil, medium: String? = nil, source: DeepLinkSource) -> TrackerEvent {
        var params = EventParameters()
        params[.campaign] = campaign
        params[.medium] = medium
        switch source {
        case let .external(theSource):
            params[.source] = theSource
        case .push:
            params[.source] = "push"
        case .none:
            break
        }
        return TrackerEvent(name: .openApp, params: params)
    }

    static func chatDeleteComplete(numberOfConversations: Int, isInactiveConversation: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.chatsDeleted] = numberOfConversations
        params[.inactiveConversations] = isInactiveConversation
        return TrackerEvent(name: .chatDeleteComplete, params: params)
    }
    
    static func chatViewInactiveConversations() -> TrackerEvent {
        return TrackerEvent(name: .chatViewInactiveConversations, params: EventParameters())
    }
    
    static func chatInactiveConversationsShown() -> TrackerEvent {
        return TrackerEvent(name: .chatInactiveConversationsShown, params: EventParameters())
    }
    
    static func chatMarkMessagesAsRead() -> TrackerEvent {
        return TrackerEvent(name: .markMessagesAsRead, params: EventParameters())
    }
    
    static func expressChatStart(_ trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.expressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .expressChatStart, params: params)
    }

    static func expressChatComplete(_ numConversations: Int, trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.expressConversations] = numConversations
        params[.expressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .expressChatComplete, params: params)
    }

    static func expressChatDontAsk(_ trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.expressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .expressChatDontAsk, params: params)
    }
    
    static func npsStart() -> TrackerEvent {
        return TrackerEvent(name: .npsStart, params: nil)
    }
    
    static func npsComplete(_ score: Int) -> TrackerEvent {
        var params = EventParameters()
        params[.npsScore] = score
        return TrackerEvent(name: .npsComplete, params: params)
    }

    static func surveyStart(userId: String?, surveyUrl: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        params[.surveyUrl] = surveyUrl
        return TrackerEvent(name: .surveyStart, params: params)
    }

    static func surveyCompleted(userId: String?, surveyUrl: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        params[.surveyUrl] = surveyUrl
        return TrackerEvent(name: .surveyCompleted, params: params)
    }

    static func verifyAccountStart(_ typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .verifyAccountStart, params: params)
    }

    static func verifyAccountComplete(_ typePage: EventParameterTypePage, network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.accountNetwork] = network.rawValue
        return TrackerEvent(name: .verifyAccountComplete, params: params)
    }

    static func inappChatNotificationStart() -> TrackerEvent {
        return TrackerEvent(name: .inappChatNotificationStart, params: EventParameters())
    }

    static func inappChatNotificationComplete() -> TrackerEvent {
        return TrackerEvent(name: .inappChatNotificationComplete, params: EventParameters())
    }

    static func signupCaptcha() -> TrackerEvent {
        return TrackerEvent(name: .signupCaptcha, params: EventParameters())
    }
    
    static func loginCaptcha() -> TrackerEvent {
        return TrackerEvent(name: .loginCaptcha, params: EventParameters())
    }

    static func notificationCenterStart() -> TrackerEvent {
        return TrackerEvent(name: .notificationCenterStart, params: EventParameters())
    }

    static func notificationCenterComplete(source: EventParameterNotificationClickArea, cardAction: String?,
                                           notificationCampaign: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.notificationClickArea] = source.rawValue
        // cardAction is passed as string instead of EventParameterCardAction type as retention could send anything on the query parameter.
        params[.notificationAction] = cardAction ?? TrackerEvent.notApply
        params[.notificationCampaign] = notificationCampaign ?? TrackerEvent.notApply
        return TrackerEvent(name: .notificationCenterComplete, params: params)
    }

    static func marketingPushNotifications(_ userId: String?, enabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        params[.enabled] = enabled
        return TrackerEvent(name: .marketingPushNotifications, params: params)
    }

    static func bumpBannerShow(type: EventParameterBumpUpType,
                               listingId: String?,
                               storeProductId: String?,
                               isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.bumpUpType] = type.rawValue
        params[.listingId] = listingId ?? ""
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpBannerShow, params: params)
    }

    static func bumpBannerInfoShown(type: EventParameterBumpUpType,
                                    listingId: String?,
                                    storeProductId: String?,
                                    typePage: EventParameterTypePage?,
                                    isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.bumpUpType] = type.rawValue
        params[.listingId] = listingId ?? ""
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        if let typePage = typePage {
            params[.typePage] = typePage.rawValue
        }
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpInfoShown, params: params)
    }

    static func listingBumpUpStart(_ listing: Listing, price: EventParameterBumpUpPrice,
                                   type: EventParameterBumpUpType,
                                   storeProductId: String?,
                                   isPromotedBump: EventParameterBoolean,
                                   typePage: EventParameterTypePage?,
                                   isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)

        params[.bumpUpPrice] = price.description
        params[.bumpUpType] = type.rawValue
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        params[.promotedBump] = isPromotedBump.rawValue
        if let typePage = typePage {
            params[.typePage] = typePage.rawValue
        }
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpUpStart, params: params)
    }

    static func listingBumpUpComplete(_ listing: Listing, price: EventParameterBumpUpPrice,
                                      type: EventParameterBumpUpType,
                                      restoreRetriesCount: Int,
                                      network: EventParameterShareNetwork,
                                      transactionStatus: EventParameterTransactionStatus?,
                                      storeProductId: String?,
                                      isPromotedBump: EventParameterBoolean,
                                      typePage: EventParameterTypePage?,
                                      isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.bumpUpPrice] = price.description
        params[.bumpUpType] = type.rawValue
        params[.retriesNumber] = restoreRetriesCount
        params[.shareNetwork] = network.rawValue
        params[.transactionStatus] = transactionStatus?.rawValue ?? TrackerEvent.notApply
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        params[.promotedBump] = isPromotedBump.rawValue
        if let typePage = typePage {
            params[.typePage] = typePage.rawValue
        }
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpUpComplete, params: params)
    }

    static func listingBumpUpFail(type: EventParameterBumpUpType,
                                  listingId: String?,
                                  transactionStatus: EventParameterTransactionStatus?,
                                  storeProductId: String?,
                                  typePage: EventParameterTypePage?,
                                  isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.bumpUpType] = type.rawValue
        params[.listingId] = listingId ?? ""
        params[.transactionStatus] = transactionStatus?.rawValue ?? TrackerEvent.notApply
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        if let typePage = typePage {
            params[.typePage] = typePage.rawValue
        }
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpUpFail, params: params)
    }

    static func mobilePaymentComplete(paymentId: String, listingId: String?,
                                      transactionStatus: EventParameterTransactionStatus) -> TrackerEvent {
        var params = EventParameters()
        params[.paymentId] = paymentId
        params[.listingId] = listingId ?? ""
        params[.transactionStatus] = transactionStatus.rawValue
        return TrackerEvent(name: .mobilePaymentComplete, params: params)
    }

    static func mobilePaymentFail(reason: String?, listingId: String?,
                                  transactionStatus: EventParameterTransactionStatus) -> TrackerEvent {
        var params = EventParameters()
        params[.reason] = reason ?? ""
        params[.listingId] = listingId ?? ""
        params[.transactionStatus] = transactionStatus.rawValue
        return TrackerEvent(name: .mobilePaymentFail, params: params)
    }

    static func bumpUpNotAllowed(_ reason: EventParameterBumpUpNotAllowedReason) -> TrackerEvent {
        var params = EventParameters()
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .bumpNotAllowed, params: params)
    }

    static func bumpUpNotAllowedContactUs(_ reason: EventParameterBumpUpNotAllowedReason) -> TrackerEvent {
        var params = EventParameters()
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .bumpNotAllowedContactUs, params: params)
    }

    static func bumpUpPromo() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .bumpUpPromo, params: params)
    }

    static func chatWindowVisit(_ typePage: EventParameterTypePage, chatEnabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.chatEnabled] = chatEnabled
        return TrackerEvent(name: .chatWindowVisit, params: params)
    }
    
    static func emptyStateVisit(typePage: EventParameterTypePage, reason: EventParameterEmptyReason,
                                errorCode: Int?) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.reason] = reason.rawValue
        var errorDetails: String = TrackerEvent.notApply
        if let errorCode = errorCode {
            errorDetails = String(errorCode)
        }
        params[.errorDetails] = errorDetails
        return TrackerEvent(name: .emptyStateError, params: params)
    }
    
    static func userRatingReport(userFromId: String?,
                              ratingStars: Int) -> TrackerEvent{
        var params = EventParameters()
        params[.ratingStars] = ratingStars
        params[.userFromId] = userFromId
        return TrackerEvent(name: .userRatingReport, params: params)
    }
    
    static func filterCategoryHeaderSelected(position: Int, name: String) -> TrackerEvent {
        var params = EventParameters()
        params[.bubblePosition] = position
        params[.bubbleName] = name
        return TrackerEvent(name: .filterBubble, params: params)
    }
    
    static func onboardingInterestsComplete(superKeywords: [Int]) -> TrackerEvent {
        var params = EventParameters()
        params[.superKeywordsTotal] = superKeywords.count
        params[.superKeywordsIds] = superKeywords
        return TrackerEvent(name: .onboardingInterestsComplete, params: params)
    }
    
    static func categoriesStart(source: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = source.rawValue
        return TrackerEvent(name: .categoriesStart, params: params)
    }
    
    static func categoriesComplete(keywordName: String, source: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.keywordName] = keywordName
        params[.typePage] = source.rawValue
        return TrackerEvent(name: .categoriesComplete, params: params)
    }
    
    static func listingSellYourStuffButton() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .listingSellYourStuffButton, params: params)
    }

    static func productDetailOpenFeaturedInfoForListing(listingId: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listingId ?? ""
        return TrackerEvent(name: .featuredMoreInfo, params: params)
    }
    
    static func openOptionOnSummary(fieldOpen: EventParameterOptionSummary, postingType: EventParameterPostingType) -> TrackerEvent {
        var params = EventParameters()
        params[.openField] = fieldOpen.rawValue
        params[.postingType] = postingType.rawValue
        return TrackerEvent(name: .openOptionOnSummary, params: params)
    }
    
    static func tutorialDialogStart(typePage: EventParameterTypePage,
                                    typeTutorialDialog: EventParameterTutorialType) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.typeTutorialDialog] = typeTutorialDialog.rawValue
        return TrackerEvent(name: .tutorialDialogStart, params: params)
    }
    
    static func tutorialDialogComplete(typePage: EventParameterTypePage,
                                       typeTutorialDialog: EventParameterTutorialType) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.typeTutorialDialog] = typeTutorialDialog.rawValue
        return TrackerEvent(name: .tutorialDialogComplete, params: params)
    }
    
    static func tutorialDialogAbandon(typePage: EventParameterTypePage,
                                       typeTutorialDialog: EventParameterTutorialType,
                                       pageNumber: Int) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.typeTutorialDialog] = typeTutorialDialog.rawValue
        params[.pageNumber] = pageNumber
        return TrackerEvent(name: .tutorialDialogAbandon, params: params)
    }

    static func assistantMeetingStartFor(listingId: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listingId ?? TrackerEvent.notApply
        return TrackerEvent(name: .assistantMeetingStart, params: params)
    }


    // MARK: - Private methods

    private static func eventParameterSortByTypeForSorting(_ sorting: ListingSortCriteria?) -> EventParameterSortBy? {
        guard let sorting = sorting else { return nil }
        let sortBy: EventParameterSortBy?
        switch (sorting) {
        case .distance:
            sortBy = EventParameterSortBy.distance
        case .creation:
            sortBy = EventParameterSortBy.creationDate
        case .priceAsc:
            sortBy = EventParameterSortBy.priceAsc
        case .priceDesc:
            sortBy = EventParameterSortBy.priceDesc
        }
        
        return sortBy
    }

    private static func eventParameterPostedWithinForTime(_ time: ListingTimeCriteria?) -> EventParameterPostedWithin? {
        guard let time = time else { return nil }
        switch time {
        case .day:
            return .day
        case .week:
            return .week
        case .month:
            return .month
        case .all:
            return .all
        }
    }

    private static func eventParameterHasPriceFilter(_ price: Int?) -> EventParameterBoolean {
        return price != nil ? .trueParameter : .falseParameter
    }
    
    static func eventParameterFreePostingWithPrice(_ freePostingModeAllowed: Bool, price: ListingPrice) -> EventParameterBoolean {
        guard freePostingModeAllowed else {return .notAvailable}
        return price.isFree ? .trueParameter : .falseParameter
    }
    
    private static func eventParameterFreePostingWithPriceRange(_ freePostingModeAllowed: Bool, priceRange: FilterPriceRange) -> EventParameterBoolean {
        guard freePostingModeAllowed else {return .notAvailable}
        return priceRange.free ? .trueParameter : .falseParameter
    }

    private static func stringFrom(categories: [ListingCategory]?) -> String {
        // Categories
        var categoryIds: [String] = []
        if let actualCategories = categories {
            categoryIds = actualCategories.map { String($0.rawValue) }
        }
        return categoryIds.isEmpty ? "0" : categoryIds.joined(separator: ",")
    }
}

typealias ItemsCount = Int
fileprivate extension ItemsCount {
    var value: String {
        get {
            guard self <= TrackerEvent.itemsCountThreshold else {
                return "50"
            }
            return "\(self)"
        }
    }
}
