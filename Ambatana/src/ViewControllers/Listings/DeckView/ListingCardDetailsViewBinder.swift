//
//  ListingCardDetailsViewBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 21/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

final class ListingCardDetailsViewBinder {

    weak var detailsView: ListingCardDetailsView?
    var disposeBag: DisposeBag?

    func bindTo(_ viewModel: ListingCardDetailsViewModel) {
        disposeBag = DisposeBag()
        guard let vmDisposeBag = disposeBag else { return }

        bindProducInfoTo(viewModel, disposeBag: vmDisposeBag)
        bindStatsTo(viewModel, disposeBag: vmDisposeBag)
        bindSocialTo(viewModel, disposeBag: vmDisposeBag)
    }

    private func bindProducInfoTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        viewModel.cardProductInfo.unwrap().bindNext { [weak self] info in
            self?.detailsView?.populateWith(productInfo: info)
        }.addDisposableTo(disposeBag)
    }

    private func bindStatsTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        let productCreation = viewModel.cardProductInfo.map { $0?.creationDate }
        let statsAndCreation = Observable.combineLatest(viewModel.cardProductStats.unwrap(),
                                                        productCreation) { $0 }
        let statsViewVisible = statsAndCreation.map { (stats, creation) in
            return stats.viewsCount >= Constants.minimumStatsCountToShow
                || stats.favouritesCount >= Constants.minimumStatsCountToShow
                || creation != nil
        }
        statsViewVisible.asObservable().distinctUntilChanged().bindNext { [weak self] visible in
            print("Should show stats view\(visible)")
        }.addDisposableTo(disposeBag)

        statsAndCreation.bindNext { [weak self] (stats, creation) in
            self?.detailsView?.populateWith(listingStats: stats, postedDate: creation)
        }.addDisposableTo(disposeBag)
    }

    func bindSocialTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        detailsView?.populateWith(socialSharer: viewModel.cardSocialSharer)
        viewModel.cardSocialMessage.bindNext { [weak self] socialMessage in
            self?.detailsView?.populateWith(socialMessage: socialMessage)
        }.addDisposableTo(disposeBag)
    }

}
