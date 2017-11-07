//
//  PostingDetailsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

class PostingDetailsViewModel : BaseViewModel, PostingAddDetailTableViewDelegate, PostingAddDetailSummaryTableViewDelegate {
    
    var title: String {
        return step.title
    }
    
    var buttonTitle: String {
        switch step {
        case .bathrooms, .bedrooms, .offerType, .price, .propertyType:
            return  previousStepIsSummary ? LGLocalizedString.productPostDone : LGLocalizedString.postingButtonSkip
        default:
            return LGLocalizedString.productPostDone
        }
    }
    
    var isSummaryStep: Bool {
        return step == .summary
    }
    
    private var currencySymbol: String? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return currencyHelper.currencyWithCountryCode(countryCode).symbol
    }
    
    private var countryCode: String? {
        return locationManager.currentLocation?.countryCode
    }
    
    var makeContentView: PostingViewConfigurable? {
        var values: [String]
        switch step {
        case .bathrooms:
            values = NumberOfBathrooms.allValues.flatMap { $0.localizedString }
        case .bedrooms:
            values = NumberOfBedrooms.allValues.flatMap { $0.localizedString }
        case .offerType:
            values = RealEstateOfferType.allValues.flatMap { $0.localizedString }
        case .propertyType:
            values = RealEstatePropertyType.allValues.flatMap { $0.localizedString }
        case .price:
           
            let priceView = PostingAddDetailPriceView(currencySymbol: currencySymbol,
                                                      freeEnabled: featureFlags.freePostingModeAllowed, frame: CGRect.zero)
            priceView.priceListing.asObservable().bindTo(priceListing).addDisposableTo(disposeBag)
            return priceView
        case .summary:
            let summaryView = PostingAddDetailSummaryTableView(postCategory: postListingState.category)
            summaryView.delegate = self
            return summaryView
        case .location, .year, .make, .model:
            return nil
        }
        let view: PostingAddDetailTableView = PostingAddDetailTableView(values: values, delegate: self)
        return view
    }
    
    var currentPrice: ListingPrice? {
        return postListingState.price
    }
    
    private let tracker: Tracker
    private let currencyHelper: CurrencyHelper
    private let locationManager: LocationManager
    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository
    
    private let step: PostingDetailStep
    private var postListingState: PostListingState
    private var uploadedImageSource: EventParameterPictureSource?
    private let postingSource: PostingSource
    private let postListingBasicInfo: PostListingBasicDetailViewModel
    private let priceListing = Variable<ListingPrice>(Constants.defaultPrice)
    private let previousStepIsSummary: Bool
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    
    convenience init(step: PostingDetailStep,
                     postListingState: PostListingState,
                     uploadedImageSource: EventParameterPictureSource?,
                     postingSource: PostingSource,
                     postListingBasicInfo: PostListingBasicDetailViewModel,
                     previousStepIsSummary: Bool) {
        self.init(step: step,
                  postListingState: postListingState,
                  uploadedImageSource: uploadedImageSource,
                  postingSource: postingSource,
                  postListingBasicInfo: postListingBasicInfo,
                  previousStepIsSummary: previousStepIsSummary,
                  tracker: TrackerProxy.sharedInstance,
                  currencyHelper: Core.currencyHelper,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  myUserRepository: Core.myUserRepository)
    }
    
    init(step: PostingDetailStep,
         postListingState: PostListingState,
         uploadedImageSource: EventParameterPictureSource?,
         postingSource: PostingSource,
         postListingBasicInfo: PostListingBasicDetailViewModel,
         previousStepIsSummary: Bool,
         tracker: Tracker,
         currencyHelper: CurrencyHelper,
         locationManager: LocationManager,
         featureFlags: FeatureFlaggeable,
         myUserRepository: MyUserRepository) {
        self.step = step
        self.postListingState = postListingState
        self.uploadedImageSource = uploadedImageSource
        self.postingSource = postingSource
        self.postListingBasicInfo = postListingBasicInfo
        self.previousStepIsSummary = previousStepIsSummary
        self.tracker = tracker
        self.currencyHelper = currencyHelper
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
    }
    
    func closeButtonPressed() {
        postAndClose()
    }

    func nextbuttonPressed() {
        guard let next = step.nextStep else {
            postAndClose()
            return
        }
        if step == .price {
            set(price: priceListing.value)
        }
        let nextStep = previousStepIsSummary ? .summary : next
        advanceNextStep(next: nextStep)
    }
    
    private func postAndClose() {
        navigator?.openLoginIfNeededFromListingPosted(from: .sell, loggedInAction: { [weak self] in
            self?.postListing()
        }, cancelAction: { [weak self] in
            self?.navigator?.cancelPostListing()
        })
    }
    
    private func advanceNextStep(next: PostingDetailStep) {
        navigator?.nextPostingDetailStep(step: next, postListingState: postListingState, uploadedImageSource: uploadedImageSource, postingSource: postingSource, postListingBasicInfo: postListingBasicInfo, previousStepIsSummary: false)
    }
    
    private func postListing() {
        guard let location = locationManager.currentLocation?.location else {
            navigator?.cancelPostListing()
            return
        }
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? Constants.currencyDefault)
        let listingCreationParams =  ListingCreationParams.make(title: postListingBasicInfo.title.value,
                                                                description: postListingBasicInfo.description.value,
                                                                currency: currency,
                                                                location: location,
                                                                postalAddress: postalAddress,
                                                                postListingState: postListingState)
        
        let trackingInfo: PostListingTrackingInfo = PostListingTrackingInfo(buttonName: .summary, sellButtonPosition: postingSource.sellButtonPosition, imageSource: uploadedImageSource, price: String(describing: postListingState.price?.value))
        navigator?.closePostProductAndPostInBackground(params: listingCreationParams, trackingInfo: trackingInfo)
    }
    
    private func set(price: ListingPrice) {
        postListingState = postListingState.updating(price: price)
    }
    
    // MARK: - PostingAddDetailTableViewDelegate 
    
    func indexSelected(index: Int) {
        var numberOfBathrooms: NumberOfBathrooms? = nil
        var numberOfBedrooms: NumberOfBedrooms? = nil
        var realEstatePropertyType: RealEstatePropertyType? = nil
        var realEstateOfferType: RealEstateOfferType? = nil
        
        switch step {
        case .bathrooms:
            numberOfBathrooms = NumberOfBathrooms.allValues[index]
        case .bedrooms:
            numberOfBedrooms = NumberOfBedrooms.allValues[index]
        case .offerType:
            realEstateOfferType = RealEstateOfferType.allValues[index]
        case .propertyType:
            realEstatePropertyType = RealEstatePropertyType.allValues[index]
        case .price:
            return
        case .summary, .location, .make, .model, .year:
            return
        }

        var realEstateInfo = postListingState.verticalAttributes?.realEstateAttributes ?? RealEstateAttributes.emptyRealEstateAttributes()
        realEstateInfo = realEstateInfo.updating(propertyType: realEstatePropertyType,
                                                 offerType: realEstateOfferType,
                                                 bedrooms: numberOfBedrooms?.rawValue,
                                                 bathrooms: numberOfBathrooms?.rawValue)
        postListingState = postListingState.updating(realEstateInfo: realEstateInfo)
        delay(0.3) { [weak self] in
            guard let strongSelf = self else { return }
            guard let next = strongSelf.step.nextStep else { return }
            let nextStep = strongSelf.previousStepIsSummary ? .summary : next
            strongSelf.advanceNextStep(next: nextStep)
        }
    }
    
    func indexDeselected(index: Int) {
        var removeBathrooms = false
        var removeBedrooms = false
        var removePropertyType = false
        var removeOfferType = false
        
        switch step {
        case .bathrooms:
            removeBathrooms = true
        case .bedrooms:
            removeBedrooms = true
        case .offerType:
            removeOfferType = true
        case .propertyType:
            removePropertyType = true
        case .price:
            return
        case .summary, .location, .make, .model, .year:
            return
        }
        if let realEstateInfo = postListingState.verticalAttributes?.realEstateAttributes {
            let realEstateInfo = realEstateInfo.removing(propertyType: removePropertyType, offerType: removeOfferType, bedrooms: removeBedrooms, bathrooms: removeBathrooms)
            postListingState = postListingState.updating(realEstateInfo: realEstateInfo)
        }
    }
    
    func findValueSelected() -> Int? {
        var positionSelected: Int? = nil
        switch step {
        case .propertyType:
            positionSelected = postListingState.verticalAttributes?.realEstateAttributes?.propertyType?.position
        case .offerType:
            positionSelected = postListingState.verticalAttributes?.realEstateAttributes?.offerType?.position
        case .bedrooms:
            if let bedrooms = postListingState.verticalAttributes?.realEstateAttributes?.bedrooms {
                positionSelected = NumberOfBedrooms(rawValue: bedrooms)?.position
            }
        case .bathrooms:
            if let bathrooms = postListingState.verticalAttributes?.realEstateAttributes?.bathrooms {
                positionSelected = NumberOfBathrooms(rawValue:bathrooms)?.position
            }
        case .price, .make, .model, .year, .location, .summary:
            return nil
        }
        return positionSelected
    }
    
    
    // MARK: - PostingAddDetailSummaryTableViewDelegate
    
    func postingAddDetailSummary(_ postingAddDetailSummary: PostingAddDetailSummaryTableView, didSelectIndex: PostingSummaryOption) {
        navigator?.nextPostingDetailStep(step: didSelectIndex.postingDetailStep, postListingState: postListingState, uploadedImageSource: uploadedImageSource, postingSource: postingSource, postListingBasicInfo: postListingBasicInfo, previousStepIsSummary: true)
    }
    
    func valueFor(section: PostingSummaryOption) -> String? {
        var value: String?
        switch section {
        case .price:
            if let countryCodeValue = countryCode {
                 value = postListingState.price?.stringValue(currency: currencyHelper.currencyWithCountryCode(countryCodeValue), isFreeEnabled: featureFlags.freePostingModeAllowed)
            }
        case .propertyType:
            value = postListingState.verticalAttributes?.realEstateAttributes?.propertyType?.localizedString
        case .offerType:
            value = postListingState.verticalAttributes?.realEstateAttributes?.offerType?.localizedString
        case .bedrooms:
            if let bedrooms = postListingState.verticalAttributes?.realEstateAttributes?.bedrooms {
                value = NumberOfBedrooms(rawValue: bedrooms)?.summaryLocalizedString
            }
        case .bathrooms:
            if let bathrooms = postListingState.verticalAttributes?.realEstateAttributes?.bathrooms {
                value = NumberOfBathrooms(rawValue:bathrooms)?.summaryLocalizedString
            }
        case .location:
            value = myUserRepository.myUser?.location?.postalAddress?.cityStateString ?? locationManager.currentLocation?.postalAddress?.cityStateString
        case .make:
            value = postListingState.verticalAttributes?.carAttributes?.make
        case .model:
            value = postListingState.verticalAttributes?.carAttributes?.model
        case .year:
            value = String(describing: postListingState.verticalAttributes?.carAttributes?.year)
        }
        return value
    }
}
