//
//  ListingDeckViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import LGCoreKit
import RxCocoa
import RxSwift

typealias DeckMovement = CarouselMovement

final class ListingDeckViewController: KeyboardViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    var cardInsets: UIEdgeInsets { return listingDeckView.cardsInsets }

    fileprivate let listingDeckView = ListingDeckView()
    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()

    fileprivate var transitioner: PhotoViewerTransitionAnimator?

    init(viewModel: ListingDeckViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        self.view = listingDeckView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listingDeckView.updateTop(wintInset: topBarHeight)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listingDeckView.resignFirstResponder()
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)
        setupPageCurrentCell()
        delay(0.5) {
            self.onboardingFlashDetails()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listingDeckView.setQuickChatViewModel(viewModel.quickChatViewModel)
        setupCollectionView()

        setupRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        listingDeckView.collectionView.clipsToBounds = false

        updateStartIndex()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listingDeckView.collectionView.clipsToBounds = true
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    func updateStartIndex() {
        let startIndexPath = IndexPath(item: viewModel.startIndex, section: 0)
        listingDeckView.scrollToIndex(startIndexPath)
    }

    func cardSystemLayoutSizeFittingSize(_ target: CGSize) -> CGSize {
        return listingDeckView.cardSystemLayoutSizeFittingSize(target)
    }

    // MARK: Rx

    private func setupRx() {
        binder.listingDeckViewController = self
        binder.bind(withViewModel: viewModel, listingDeckView: listingDeckView)
    }

    // MARK: CollectionView

    private func setupCollectionView() {
        automaticallyAdjustsScrollViewInsets = false
        listingDeckView.collectionView.dataSource = self
        listingDeckView.collectionView.register(ListingCardView.self, forCellWithReuseIdentifier: ListingCardView.reusableID)

        listingDeckView.collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.objectCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListingCardView.reusableID, for: indexPath) as? ListingCardView {
            guard let model = viewModel.snapshotModelAt(index: indexPath.row) else { return cell }
            cell.isUserInteractionEnabled = indexPath.row == listingDeckView.currentPage
            cell.populateWith(model, imageDownloader: viewModel.imageDownloader)
            cell.delegate = self

            return cell
        }
        return UICollectionViewCell()
    }

    private func updateCellContentInset(_ cell: ListingCardView, animated: Bool) {
        let inset = listingDeckView.collectionView.bounds.height * 0.8
        cell.setVerticalContentInset(inset, animated: animated)
    }

    // MARK: NavBar

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(didTapClose))

        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more_options"),
                                                                  style: .plain,
                                                                  target: self,
                                                                  action: #selector(didTapMoreActions))
    }

    // Actions

    @objc private func didTapMoreActions() {
        var toShowActions = viewModel.navBarButtons
        let title = LGLocalizedString.productOnboardingShowAgainButtonTitle
        toShowActions.append(UIAction(interface: .text(title), action: { [weak viewModel] in
            viewModel?.showOnBoarding()
        }))
        showActionSheet(LGLocalizedString.commonCancel, actions: toShowActions, barButtonItem: nil)
    }

    @objc private func didTapClose() {
        closeBumpUpBanner(animated: false)
        UIView.animate(withDuration: 0.3, animations: {
            self.listingDeckView.resignFirstResponder()
        }) { (completion) in
            self.viewModel.close()
        }
    }

    private func closeBumpUpBanner(animated: Bool) {
        guard listingDeckView.isBumpUpVisible else { return }
        listingDeckView.hideBumpUp()
        if animated {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                            self?.listingDeckView.itemActionsView.layoutIfNeeded()
                }, completion: nil)
        } else {
            listingDeckView.itemActionsView.layoutIfNeeded()
        }
    }
}

extension ListingDeckViewController {
    private func onboardingFlashDetails() {
        guard let current = listingDeckView.collectionView.cellForItem(at: IndexPath(row: viewModel.startIndex,
                                                                                     section: 0)) else { return }
        guard let cell = current as? ListingCardView else { return }
        cell.onboardingFlashDetails()
    }
}

extension ListingDeckViewController: ListingDeckViewControllerBinderType {
    var rxContentOffset: Observable<CGPoint> { return listingDeckView.rxCollectionView.contentOffset.share() }

    func turnNavigationBar(_ on: Bool) {
        if on {
            navigationItem.hidesBackButton = false
            setupNavigationBar()
        } else {
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = UIBarButtonItem()
            navigationItem.rightBarButtonItem = UIBarButtonItem()
        }
    }

    func willDisplayCell(_ cell: UICollectionViewCell) {
        guard let card = cell as? ListingCardView else { return }
        updateCellContentInset(card, animated: false)
    }
    
    func didEndDecelerating() {
        listingDeckView.blockSideInteractions()
        listingDeckView.collectionView.visibleCells.flatMap { $0 as? ListingCardView }.forEach { cell in
            guard cell != listingDeckView.currentPageCell else { return }
            updateCellContentInset(cell, animated: true)
        }
        setupPageCurrentCell()
    }

    private func setupPageCurrentCell() {
        guard let cell = listingDeckView.currentPageCell else { return }
        let currentPage = listingDeckView.currentPage
        binder.bind(cell: cell)
        cell.isUserInteractionEnabled = true

        guard let listing = viewModel.listingCellModelAt(index: currentPage) else { return }
        cell.populateWith(cellModel: listing, imageDownloader: viewModel.imageDownloader)
    }

    func didShowMoreInfo() {
        viewModel.didShowMoreInfo()
    }

    func didTapOnUserIcon() {
        viewModel.showUser()
    }

    func updateViewWithActions(_ actionButtons: [UIAction]) {
        guard let actionButton = actionButtons.first else {
            return
        }
        listingDeckView.configureActionWith(actionButton)
    }

    func updateWith(keyboardChange: KeyboardChange) {
        let height = listingDeckView.bounds.height - keyboardChange.origin
        listingDeckView.updateWith(bottomInset: height,
                                   animationTime: TimeInterval(keyboardChange.animationTime),
                                   animationOptions: keyboardChange.animationOptions,
                                   completion: nil)
        if keyboardChange.visible {
            listingDeckView.showFullScreenChat()
        } else {
            listingDeckView.hideFullScreenChat()
        }
    }
    
    func updateViewWith(alpha: CGFloat, chatEnabled: Bool, isMine: Bool, actionsEnabled: Bool) {
        listingDeckView.chatEnabled = chatEnabled
        let chatAlpha: CGFloat
        let actionsAlpha: CGFloat
        if isMine && actionsEnabled {
            actionsAlpha = min(1.0, alpha)
            chatAlpha = 0
        } else if !chatEnabled {
            actionsAlpha = 0
            chatAlpha = 0
        } else {
            chatAlpha = min(1.0, alpha)
            actionsAlpha = 0
        }

        listingDeckView.updatePrivateActionsWith(alpha: actionsAlpha)
        listingDeckView.updateChatWith(alpha: chatAlpha)
    }
    

    func didTapShare() {
        viewModel.currentListingViewModel?.shareProduct()
    }

    func didTapCardAction() {
        viewModel.didTapCardAction()
    }

    func showBumpUpBanner(bumpInfo: BumpUpInfo) {
        guard !listingDeckView.isBumpUpVisible else {
            // banner is already visible, but info changes
            listingDeckView.updateBumpUp(withInfo: bumpInfo)
            return
        }

        viewModel.bumpUpBannerShown(type: bumpInfo.type)
        delay(1.0) { [weak self] in
            self?.listingDeckView.updateBumpUp(withInfo: bumpInfo)
            self?.listingDeckView.showBumpUp()
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                self?.listingDeckView.itemActionsView.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func closeBumpUpBanner() {
        closeBumpUpBanner(animated: true)
    }
}

extension ListingDeckViewController: ListingDeckViewModelDelegate {

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (self, navigationItem.rightBarButtonItems?.first)
    }

    func vmResetBumpUpBannerCountdown() {
        listingDeckView.resetBumpUpCountdown()
    }
}

extension ListingDeckViewController: ListingCardDetailsViewDelegate, ListingCardViewDelegate, ListingCardDetailMapViewDelegate {
    func viewControllerToShowShareOptions() -> UIViewController { return self }

    func didTapOnMapSnapshot(_ snapshot: UIView) {
        let page = listingDeckView.currentPage
        guard let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: page, section: 0))
            as? ListingCardView else { return }

        listingDeckView.collectionView.isScrollEnabled = false
        cell.showFullMap(fromRect: snapshot.frame)
    }

    func didTapOnPreview() {
        displayPhotoViewer()
    }

    func displayPhotoViewer() {
        viewModel.openPhotoViewer()
    }

    func didTapMapView() {
        let page = listingDeckView.currentPage
        guard let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: page, section: 0))
            as? ListingCardView else { return }
        listingDeckView.collectionView.isScrollEnabled = true
        cell.hideFullMap()
    }

    func didTapOnStatusView() {
        viewModel.didTapStatusView()
    }
}

extension ListingDeckViewController {

    var animationController: UIViewControllerAnimatedTransitioning? {
            if transitioner == nil {
                let current = listingDeckView.currentPage
                let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: current, section: 0)) as! ListingCardView
                let frame = cell.convert(cell.previewImageViewFrame, to: listingDeckView)

                guard let url = viewModel.urlAtIndex(0),
                    let cached = viewModel.imageDownloader.cachedImageForUrl(url) else { return nil }
                transitioner = PhotoViewerTransitionAnimator(image: cached, initialFrame: frame)
            }
        guard let url = viewModel.urlAtIndex(0),
            let cached = viewModel.imageDownloader.cachedImageForUrl(url) else { return nil }
        transitioner?.setImage(cached)
        return transitioner
    }
}
