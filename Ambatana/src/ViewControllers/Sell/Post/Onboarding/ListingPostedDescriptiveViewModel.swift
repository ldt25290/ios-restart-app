//
//  ListingPostedDescriptiveViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum PostingDescriptionType {
    case withTitle
    case noTitle
}

class ListingPostedDescriptiveViewModel: BaseViewModel, PostingCategoriesPickDelegate {

    var descriptionType: PostingDescriptionType

    var doneText: String {
        return LGLocalizedString.postDescriptionDoneText
    }

    var saveButtonText: String {
        return LGLocalizedString.postDescriptionSaveButtonText
    }

    var discardButtonText: String {
        return LGLocalizedString.postDescriptionDiscardButtonText
    }

    var listingInfoTitleText: String {
        return LGLocalizedString.postDescriptionInfoTitle.uppercased()
    }

    var namePlaceholder: String {
        return LGLocalizedString.postDescriptionNamePlaceholder
    }
    var categoryButtonPlaceholder: String {
        return LGLocalizedString.postDescriptionCategoryTitle
    }
    var descriptionPlaceholder: String {
        return LGLocalizedString.postDescriptionDescriptionPlaceholder
    }
    var categoryButtonImage: UIImage? {
        return #imageLiteral(resourceName: "ic_arrow_right_white").withRenderingMode(.alwaysTemplate)
    }

    private var nameChanged: Bool {
        return listingName.value != originalName.value
    }

    private var categoryChanged: Bool {
        return listingCategory.value != originalCategory
    }

    private var descriptionChanged: Bool {
        return listingDescription.value != originalDescription && listingDescription.value != ""
    }

    let listingImage: UIImage?
    let listingName = Variable<String>("")
    let listingCategory = Variable<ListingCategory?>(nil)
    let listingDescription = Variable<String?>(nil)

    let originalName = Variable<String>("")
    var originalCategory: ListingCategory?
    var originalDescription: String?

    weak var navigator: BlockingPostingNavigator?

    private let tracker: Tracker
    private var listing: Listing
    private let listingRepository: ListingRepository
    private let featureFlags: FeatureFlaggeable
    private let imageSource: EventParameterPictureSource
    private let postingSource: PostingSource


    // MARK: - Lifecycle
    
    convenience init(listing: Listing, listingImages: [UIImage], imageSource: EventParameterPictureSource, postingSource: PostingSource) {
        self.init(listing: listing,
                  listingImages: listingImages,
                  imageSource: imageSource,
                  postingSource: postingSource,
                  tracker: TrackerProxy.sharedInstance,
                  listingRepository: Core.listingRepository,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(listing: Listing, listingImages: [UIImage], imageSource: EventParameterPictureSource,
         postingSource: PostingSource, tracker: Tracker, listingRepository: ListingRepository,
         featureFlags: FeatureFlaggeable) {
        self.listing = listing
        self.listingImage = listingImages.first
        self.imageSource = imageSource
        self.postingSource = postingSource
        self.tracker = tracker
        self.listingRepository = listingRepository
        self.featureFlags = featureFlags

        self.descriptionType = listing.nameAuto != nil ? .withTitle : .noTitle
        self.listingName.value = listing.nameAuto ?? ""
        self.originalName.value = listing.nameAuto ?? ""
        self.listingCategory.value = listing.category
        self.originalCategory = listing.category
        super.init()
        self.originalDescription = self.descriptionPlaceholder
    }


    // MARK: Public methods

    func updateListingNameWith(text: String?) {
        guard let name = text else { return }
        listingName.value = name
    }

    func updateListingDescriptionWith(text: String?) {
        listingDescription.value = text ?? descriptionPlaceholder
    }

    // MARK: - Private Methods

    private func infoHasChanged() -> Bool {
        return nameChanged || categoryChanged || descriptionChanged
    }


    // MARK: - Navigation

    func openCategoriesPicker() {
        navigator?.openCategoriesPickerWith(selectedCategory: listingCategory.value, delegate: self)
    }

    func closePosting(discardingListing: Bool) {
        defer {
            if discardingListing {
                trackPostSellAbandon()
                navigator?.closePosting()
            } else {
                trackPostSellComplete()
                navigator?.postingSucceededWith(listing: listing)
            }
        }
        if discardingListing {
            guard let listingId = listing.objectId else { return }
            listingRepository.delete(listingId: listingId, completion: nil)
        } else if infoHasChanged() {
            let updatedParams: ListingEditionParams
            if let category = listingCategory.value, category.isCar {
                guard let carParams = CarEditionParams(listing: listing) else { return }
                carParams.name = listingName.value
                carParams.category = .cars
                carParams.descr = descriptionChanged ? listingDescription.value : nil
                updatedParams = .car(carParams)
            } else {
                guard let productParams = ProductEditionParams(listing: listing) else { return }
                productParams.name = listingName.value
                productParams.category = listingCategory.value ?? .other
                productParams.descr = descriptionChanged ? listingDescription.value : nil
                updatedParams = .product(productParams)
            }
            listingRepository.update(listingParams: updatedParams, completion: nil)
        }
    }

    
    // MARK: - Tracker
    
    fileprivate func trackPostSellComplete() {
        let trackingInfo = PostListingTrackingInfo(buttonName: .done,
                                                   sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: imageSource,
                                                   price: String.fromPriceDouble(listing.price.value),
                                                   typePage: postingSource.typePage,
                                                   mostSearchedButton: postingSource.mostSearchedButton,
                                                   machineLearningInfo: MachineLearningTrackingInfo.defaultValues())
        
        let event = TrackerEvent.listingSellComplete(listing,
                                                     buttonName: trackingInfo.buttonName,
                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice,
                                                     pictureSource: trackingInfo.imageSource,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                     typePage: trackingInfo.typePage,
                                                     mostSearchedButton: trackingInfo.mostSearchedButton,
                                                     machineLearningTrackingInfo: trackingInfo.machineLearningInfo)
        tracker.trackEvent(event)
    }
    
    fileprivate func trackPostSellAbandon() {
        let event = TrackerEvent.listingSellAbandon(abandonStep: .summaryOnboarding)
        tracker.trackEvent(event)
    }
    

    // MARK: PostingCategoriesPickDelegate

    func didSelectCategory(category: ListingCategory) {
        listingCategory.value = category
    }
}