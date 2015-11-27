//
//  FiltersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol FiltersViewModelDelegate: class {
    
    func viewModelDidUpdate(viewModel: FiltersViewModel)
    
}

protocol FiltersViewModelDataDelegate: class {
    
    func viewModelDidUpdateFilters(viewModel: FiltersViewModel, filters: ProductFilters)
    
}

class FiltersViewModel: BaseViewModel {
    
    //Model delegate
    weak var delegate: FiltersViewModelDelegate?
    
    //DataDelegate
    weak var dataDelegate : FiltersViewModelDataDelegate?
    
    //Distance vars
    var currentDistanceRadius : Int {
        get{
            return productFilter.distanceRadius
        }
        set{
            productFilter.distanceRadius = newValue
        }
    }
    
    var distanceType : DistanceType {
        return productFilter.distanceType
    }
      
    //Category vars
    private var categoriesManager: CategoriesManager
    private var categories: [ProductCategory]
    
    var numOfCategories : Int {
        return self.categories.count
    }
    
    //Within vars
    var numOfWithinTimes : Int {
        return self.withinTimes.count
    }
    private var withinTimes : [ProductTimeCriteria]
    
    //SortOptions vars
    var numOfSortOptions : Int {
        return self.sortOptions.count
    }
    private var sortOptions : [ProductSortCriteria]
    
    
    private var productFilter : ProductFilters
    
    
    override convenience init() {
        self.init(currentFilters: ProductFilters())
    }
    
    convenience init(currentFilters: ProductFilters) {
        self.init(categoriesManager: CategoriesManager.sharedInstance, categories: [], withinTimes: ProductTimeCriteria.allValues(), sortOptions: ProductSortCriteria.allValues(), currentFilters: currentFilters)
    }
    
    required init(categoriesManager: CategoriesManager, categories: [ProductCategory], withinTimes: [ProductTimeCriteria], sortOptions: [ProductSortCriteria], currentFilters: ProductFilters) {
        self.categoriesManager = categoriesManager
        self.categories = categories
        self.withinTimes = withinTimes
        self.sortOptions = sortOptions
        self.productFilter = currentFilters
        super.init()
    }
    
    // MARK: - Actions
    
    func resetFilters() {
        self.productFilter = ProductFilters()
        delegate?.viewModelDidUpdate(self)
    }
    
    func saveFilters() {
        
        // Tracking
        
        var categories : [String] = []
        
        for category in productFilter.selectedCategories {
            categories.append(String(category.rawValue))
        }
        
        let trackingEvent = TrackerEvent.filterComplete(productFilter.filterCoordinates, distanceRadius: productFilter.distanceRadius, distanceUnit: productFilter.distanceType, categories: productFilter.selectedCategories, sortBy: productFilter.selectedOrdering)
        TrackerProxy.sharedInstance.trackEvent(trackingEvent)
        
        dataDelegate?.viewModelDidUpdateFilters(self, filters: productFilter)
    }
    
    // MARK: Categories
    
    /**
    Retrieves the list of categories
    */
    func retrieveCategories() {
        
        // Data
        let myCompletion: CategoriesRetrieveServiceCompletion = { (result: CategoriesRetrieveServiceResult) in
            if let categories = result.value {
                self.categories = categories
                self.delegate?.viewModelDidUpdate(self)
            }
        }
        categoriesManager.retrieveCategoriesWithCompletion(myCompletion)
    }
    
    func selectCategoryAtIndex(index: Int) {
        guard index < numOfCategories else { return }
        
        productFilter.toggleCategory(categories[index])
        self.delegate?.viewModelDidUpdate(self)
    }
    
    func categoryTextAtIndex(index: Int) -> String? {
        guard index < numOfCategories else { return nil }
        
        return categories[index].name
    }
    
    func categoryIconAtIndex(index: Int) -> UIImage? {
        guard index < numOfCategories else { return nil }
        
        let category = categories[index]
        return category.imageSmallInactive?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }
    
    func categoryColorAtIndex(index: Int) -> UIColor {
        guard index < numOfCategories else { return StyleHelper.standardTextColor }
        
        let category = categories[index]
        return productFilter.hasSelectedCategory(category) ? category.color : StyleHelper.standardTextColor
    }
    
    // MARK: Within
    func selectWithinTimeAtIndex(index: Int) {
        guard index < numOfWithinTimes else { return }
        
        productFilter.selectedWithin = withinTimes[index]
        self.delegate?.viewModelDidUpdate(self)
    }
    
    func withinTimeNameAtIndex(index: Int) -> String? {
        guard index < numOfWithinTimes else { return nil }
        
        return withinTimes[index].name
    }
    
    func withinTimeSelectedAtIndex(index: Int) -> Bool {
        guard index < numOfWithinTimes else { return false }
        
        return withinTimes[index] == productFilter.selectedWithin
    }
    
    // MARK: Filter by
    
    func selectSortOptionAtIndex(index: Int) {
        guard index < numOfSortOptions else { return }
        
        productFilter.selectedOrdering = sortOptions[index]
        self.delegate?.viewModelDidUpdate(self)
    }

    func sortOptionTextAtIndex(index: Int) -> String? {
        guard index < numOfSortOptions else { return nil }
        
        return sortOptions[index].name
    }
    
    func sortOptionSelectedAtIndex(index: Int) -> Bool {
        guard index < numOfSortOptions else { return false }
        
        return sortOptions[index] == productFilter.selectedOrdering
    }

}
