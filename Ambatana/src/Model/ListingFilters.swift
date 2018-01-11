//
//  ListingFilters.swift
//  LetGo
//
//  Created by Eli Kohen on 10/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum FilterPriceRange: Equatable {
    case freePrice
    case priceRange(min: Int?, max: Int?)

    var min: Int? {
        switch self {
        case .freePrice:
            return nil
        case let .priceRange(min: minPrice, max: _):
            return minPrice
        }
    }

    var max: Int? {
        switch self {
        case .freePrice:
            return nil
        case let .priceRange(min: _, max: maxPrice):
            return maxPrice
        }
    }

    var free: Bool {
        switch self {
        case .freePrice:
            return true
        case .priceRange:
            return false
        }
    }
}

func ==(a: FilterPriceRange, b: FilterPriceRange) -> Bool {
    switch (a, b) {
    case (let .priceRange(minA, maxA), let .priceRange(minB, maxB)) where minA == minB && maxA == maxB : return true
    case (.freePrice, .freePrice): return true
    default: return false
    }
}

struct ListingFilters {
    
    var place: Place?
    var distanceRadius: Int?
    var distanceType: DistanceType
    var selectedCategories: [ListingCategory]
    var selectedTaxonomyChildren: [TaxonomyChild]
    var selectedTaxonomy: Taxonomy?
    var selectedWithin: ListingTimeCriteria
    var selectedOrdering: ListingSortCriteria?
    var filterCoordinates: LGLocationCoordinates2D? {
        return place?.location
    }
    var priceRange: FilterPriceRange

    var carMakeId: RetrieveListingParam<String>?
    var carMakeName: String?
    var carModelId: RetrieveListingParam<String>?
    var carModelName: String?
    var carYearStart: RetrieveListingParam<Int>?
    var carYearEnd: RetrieveListingParam<Int>?
    
    var realEstatePropertyType: RealEstatePropertyType?
    var realEstateOfferType: RealEstateOfferType?
    var realEstateNumberOfBedrooms: NumberOfBedrooms?
    var realEstateNumberOfBathrooms: NumberOfBathrooms?

    init() {
        self.init(
            place: nil,
            distanceRadius: Constants.distanceSliderDefaultPosition,
            distanceType: DistanceType.systemDistanceType(),
            selectedCategories: [],
            selectedTaxonomyChildren: [],
            selectedTaxonomy: nil,
            selectedWithin: ListingTimeCriteria.defaultOption,
            selectedOrdering: ListingSortCriteria.defaultOption,
            priceRange: .priceRange(min: nil, max: nil),
            carMakeId: nil,
            carMakeName: nil,
            carModelId: nil,
            carModelName: nil,
            carYearStart: nil,
            carYearEnd: nil,
            realEstatePropertyType: nil,
            realEstateOfferType: nil,
            realEstateNumberOfBedrooms: nil,
            realEstateNumberOfBathrooms: nil
        )
    }
    
    init(place: Place?,
         distanceRadius: Int,
         distanceType: DistanceType,
         selectedCategories: [ListingCategory],
         selectedTaxonomyChildren: [TaxonomyChild],
         selectedTaxonomy: Taxonomy?,
         selectedWithin: ListingTimeCriteria,
         selectedOrdering: ListingSortCriteria?,
         priceRange: FilterPriceRange,
         carMakeId: RetrieveListingParam<String>?,
         carMakeName: String?,
         carModelId: RetrieveListingParam<String>?,
         carModelName: String?,
         carYearStart: RetrieveListingParam<Int>?,
         carYearEnd: RetrieveListingParam<Int>?,
         realEstatePropertyType: RealEstatePropertyType?,
         realEstateOfferType: RealEstateOfferType?,
         realEstateNumberOfBedrooms: NumberOfBedrooms?,
         realEstateNumberOfBathrooms: NumberOfBathrooms?
         ) {
        self.place = place
        self.distanceRadius = distanceRadius > 0 ? distanceRadius : nil
        self.distanceType = distanceType
        self.selectedCategories = selectedCategories
        self.selectedTaxonomyChildren = selectedTaxonomyChildren
        self.selectedTaxonomy = selectedTaxonomy
        self.selectedWithin = selectedWithin
        self.selectedOrdering = selectedOrdering
        self.priceRange = priceRange
        self.carMakeId = carMakeId
        self.carMakeName = carMakeName
        self.carModelId = carModelId
        self.carModelName = carModelName
        self.carYearStart = carYearStart
        self.carYearEnd = carYearEnd
        self.realEstatePropertyType = realEstatePropertyType
        self.realEstateOfferType = realEstateOfferType
        self.realEstateNumberOfBedrooms = realEstateNumberOfBedrooms
        self.realEstateNumberOfBathrooms = realEstateNumberOfBathrooms
    }
    
    func updating(selectedCategories: [ListingCategory]) -> ListingFilters {
        return ListingFilters(place: place,
                              distanceRadius: distanceRadius ?? Constants.distanceSliderDefaultPosition,
                              distanceType: distanceType,
                              selectedCategories: selectedCategories,
                              selectedTaxonomyChildren: selectedTaxonomyChildren,
                              selectedTaxonomy: selectedTaxonomy,
                              selectedWithin: selectedWithin,
                              selectedOrdering: selectedOrdering,
                              priceRange: priceRange,
                              carMakeId: carMakeId,
                              carMakeName: carMakeName,
                              carModelId: carModelId,
                              carModelName: carModelName,
                              carYearStart: carYearStart,
                              carYearEnd: carYearEnd,
                              realEstatePropertyType: realEstatePropertyType,
                              realEstateOfferType: realEstateOfferType,
                              realEstateNumberOfBedrooms: realEstateNumberOfBedrooms,
                              realEstateNumberOfBathrooms: realEstateNumberOfBathrooms)
    }
    
    
    mutating func toggleCategory(_ category: ListingCategory) {
        if let categoryIndex = indexForCategory(category) {
            // DESELECT
            selectedCategories.remove(at: categoryIndex)
        } else {
            // SELECT
            selectedCategories = [category]
        }
    }
    
    func hasSelectedCategory(_ category: ListingCategory) -> Bool {
        return indexForCategory(category) != nil
    }
    
    var hasAnyRealEstateAttributes: Bool {
        return realEstateOfferType != nil || realEstatePropertyType != nil || realEstateNumberOfBathrooms != nil || realEstateNumberOfBedrooms != nil
    }
    
    var hasAnyCarAttributes: Bool {
        return carMakeId != nil || carMakeId != nil || carYearStart != nil || carYearEnd != nil
    }

    func isDefault() -> Bool {
        if let _ = place { return false } //Default is nil
        if let _ = distanceRadius { return false } //Default is nil
        if !selectedCategories.isEmpty { return false }
        if !selectedTaxonomyChildren.isEmpty { return false }
        if let _ = selectedTaxonomy { return false } //Default is nil
        if selectedWithin != ListingTimeCriteria.defaultOption { return false }
        if selectedOrdering != ListingSortCriteria.defaultOption { return false }
        if priceRange != .priceRange(min: nil, max: nil) { return false }
        if hasAnyCarAttributes { return false }
        if hasAnyRealEstateAttributes { return false }
        return true
    }
    
    private func indexForCategory(_ category: ListingCategory) -> Int? {
        for i in 0..<selectedCategories.count {
            if(selectedCategories[i] == category){
                return i
            }
        }
        return nil
    }
}

extension RetrieveListingParam: Equatable {
    static public func == (a: RetrieveListingParam, b: RetrieveListingParam) -> Bool {
        return a.value == b.value && a.isNegated == b.isNegated
    }
}

extension Place: Equatable {
    public static func == (a: Place, b: Place) -> Bool {
        return a.name == b.name &&
        a.postalAddress == b.postalAddress &&
        a.location == b.location &&
        a.placeResumedData == b.placeResumedData
    }
}

extension ListingFilters: Equatable {
    static func ==(a: ListingFilters, b: ListingFilters) -> Bool {
        guard a.selectedTaxonomyChildren.count == b.selectedTaxonomyChildren.count else { return false }
        for (index, element) in a.selectedTaxonomyChildren.enumerated() {
            guard element == b.selectedTaxonomyChildren[index] else { return false }
        }
        
        return a.place == b.place &&
        a.distanceRadius == b.distanceRadius &&
        a.distanceType == b.distanceType &&
        a.selectedCategories == b.selectedCategories &&
        a.selectedTaxonomy == b.selectedTaxonomy &&
        a.selectedWithin == b.selectedWithin &&
        a.selectedOrdering == b.selectedOrdering &&
        a.filterCoordinates == b.filterCoordinates &&
        a.priceRange == b.priceRange &&
        a.carMakeId == b.carMakeId &&
        a.carModelId == b.carModelId &&
        a.carYearStart == b.carYearStart &&
        a.carYearEnd == b.carYearEnd &&
        a.realEstatePropertyType == b.realEstatePropertyType &&
        a.realEstateOfferType == b.realEstateOfferType &&
        a.realEstateNumberOfBedrooms == b.realEstateNumberOfBedrooms &&
        a.realEstateNumberOfBathrooms == b.realEstateNumberOfBathrooms
    }
}
