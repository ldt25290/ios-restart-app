//
//  SimpleListingsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 25/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


class SimpleListingsViewModel: BaseViewModel {

    weak var navigator: SimpleProductsNavigator?

    let title: String
    let listingVisitSource: EventParameterListingVisitSource
    let listingListRequester: ListingListRequester
    let listingListViewModel: ListingListViewModel
    let featureFlags: FeatureFlaggeable

    convenience init(relatedListingId: String,
                     listingVisitSource: EventParameterListingVisitSource) {
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let itemsPerPage = show3Columns ? Constants.numListingsPerPageBig : Constants.numListingsPerPageDefault
        let requester = RelatedListingListRequester(listingId: relatedListingId, itemsPerPage: itemsPerPage)
        self.init(requester: requester,
                  title: LGLocalizedString.relatedItemsTitle,
                  listingVisitSource: listingVisitSource)
    }

    convenience init(requester: ListingListRequester,
                     title: String,
                     listingVisitSource: EventParameterListingVisitSource) {
        self.init(requester: requester,
                  listings: nil,
                  title: title,
                  listingVisitSource: listingVisitSource,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    convenience init(requester: ListingListRequester,
                     listings: [Listing],
                     listingVisitSource: EventParameterListingVisitSource) {
        self.init(requester: requester,
                  listings: listings,
                  title: LGLocalizedString.relatedItemsTitle,
                  listingVisitSource: listingVisitSource,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(requester: ListingListRequester, listings: [Listing]?, title: String, listingVisitSource: EventParameterListingVisitSource,
         featureFlags: FeatureFlaggeable) {
        self.title = title
        self.listingVisitSource = listingVisitSource
        self.listingListRequester = requester
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        self.listingListViewModel = ListingListViewModel(requester: requester, listings: listings, numberOfColumns: columns)
        self.featureFlags = featureFlags
        super.init()
        listingListViewModel.dataDelegate = self
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            listingListViewModel.refresh()
        }
    }

    override func backButtonPressed() -> Bool {
        guard let navigator = navigator else { return false }
        navigator.closeSimpleProducts()
        return true
    }
}


extension SimpleListingsViewModel: ListingListViewModelDataDelegate {
    func listingListMV(_ viewModel: ListingListViewModel, didFailRetrievingListingsPage page: UInt, hasListings: Bool,
                       error: RepositoryError) {

    }
    func listingListVM(_ viewModel: ListingListViewModel, didSucceedRetrievingListingsPage page: UInt, hasListings: Bool) {

    }
    func listingListVM(_ viewModel: ListingListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard let listing = viewModel.listingAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let data = ListingDetailData.listingList(listing: listing, cellModels: cellModels,
                                                 requester: listingListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: false, index: index)
        navigator?.openListing(data, source: listingVisitSource, actionOnFirstAppear: .nonexistent)
    }

    func vmProcessReceivedProductPage(_ products: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        return products
    }
    func vmDidSelectSellBanner(_ type: String) {}
    func vmDidSelectCollection(_ type: CollectionCellType) {}
}