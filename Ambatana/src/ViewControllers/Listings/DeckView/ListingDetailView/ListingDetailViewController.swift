import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa
import GoogleMobileAds

fileprivate enum Layout {
    static let buttonSize = CGSize(width: 40, height: 40)
    static let actionButtonHeight: CGFloat = 50
}
final class ListingDetailViewController: BaseViewController {
    fileprivate let detailView = ListingDetailView()

    let viewModel: ListingDetailViewModel
    fileprivate let actionButton: LetgoButton = {
        let button = LetgoButton(withStyle: .terciary)
        button.setTitle(R.Strings.productMarkAsSoldButton, for: .normal)
        return button
    }()
    fileprivate var actionBottomInset: NSLayoutConstraint?

    fileprivate let disposeBag = DisposeBag()

    private let quickChatViewController: QuickChatViewController
    fileprivate lazy var bumpUpVC = BumpUpContainerViewController()

    lazy var dfpBannerView: DFPBannerView = {
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeLargeBanner)

        dfpBanner.rootViewController = self
        dfpBanner.delegate = self

        if viewModel.multiAdRequestActive {
            dfpBanner.adSizeDelegate = self
            var validSizes: [NSValue] = []
            validSizes.append(NSValueFromGADAdSize(kGADAdSizeBanner)) // 320x50
            validSizes.append(NSValueFromGADAdSize(kGADAdSizeLargeBanner)) // 320x100
            validSizes.append(NSValueFromGADAdSize(kGADAdSizeMediumRectangle)) // 300x250
            dfpBanner.validAdSizes = validSizes
        }
        return dfpBanner
    }()

    fileprivate lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.NewItemPage.nitMore.image, for: .normal)
        button.addTarget(self, action: #selector(ListingDetailViewController.didTapMoreActions), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var actionNavButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.icPen.image, for: .normal)
        button.addTarget(viewModel, action: #selector(ListingDetailViewModel.listingAction), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.NewItemPage.nitShare.image, for: .normal)
        button.addTarget(viewModel, action: #selector(ListingDetailViewModel.share), for: .touchUpInside)
        return button
    }()

    init(viewModel: ListingDetailViewModel) {
        self.viewModel = viewModel
        self.quickChatViewController = QuickChatViewController(listingViewModel: viewModel.listingViewModel)

        super.init(viewModel: viewModel,
                   nibName: nil,
                   statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .light),
                   swipeBackGestureEnabled: true)
        self.edgesForExtendedLayout = .all
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() {
        self.view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.isMine {
            addBumpUp()
        } else {
            addQuickChat()
        }
        addBanner()
    }

    @objc private func didTapMoreActions() {
        showActionSheet(R.Strings.commonCancel, actions: viewModel.navBarButtons, barButtonItem: nil)
    }

    private func addQuickChat() {
        addChildViewController(quickChatViewController)
        detailView.addSubviewForAutoLayout(quickChatViewController.view)

        NSLayoutConstraint.activate([
            quickChatViewController.view.topAnchor.constraint(equalTo: safeTopAnchor),
            quickChatViewController.view.leadingAnchor.constraint(equalTo: detailView.leadingAnchor),
            quickChatViewController.view.trailingAnchor.constraint(equalTo: detailView.trailingAnchor),
            quickChatViewController.view.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        ])
    }

    private func addBumpUp() {
        addChildViewController(bumpUpVC)
        detailView.addSubviewsForAutoLayout([bumpUpVC.view, actionButton])
        let actionBottomInset = actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([
            actionBottomInset,
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
            actionButton.heightAnchor.constraint(equalToConstant: Layout.actionButtonHeight),

            bumpUpVC.view.leadingAnchor.constraint(equalTo: detailView.leadingAnchor),
            bumpUpVC.view.trailingAnchor.constraint(equalTo: detailView.trailingAnchor),
            bumpUpVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.actionBottomInset = actionBottomInset

        bumpUpVC.bumpDelegate = viewModel
    }

    private func addBanner() {
        detailView.addBanner(banner: dfpBannerView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if viewModel.adActive {
            if let adBannerTrackingStatus = viewModel.adBannerTrackingStatus {
                viewModel.adAlreadyRequestedWithStatus(adBannerTrackingStatus: adBannerTrackingStatus)
            } else {
                loadDFPRequest()
            }
        } else {
            detailView.hideBanner()
        }

        setupRx()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupRx() {
        let bindings = [
            viewModel.rx.media.drive(rx.media),
            viewModel.rx.title.drive(rx.title),
            viewModel.rx.price.drive(rx.price),
            viewModel.rx.detail.drive(rx.detail),
            viewModel.rx.stats.drive(rx.stats),
            viewModel.rx.user.drive(rx.userDetail),
            viewModel.rx.location.drive(rx.location),
            viewModel.rx.navAction.drive(rx.navAction),
            viewModel.rx.action.drive(rx.action),
            viewModel.rx.social.drive(rx.social),
            viewModel.rx.bumpUpBannerInfo.drive(rx.bumpUp),
            bumpUpVC.rx.bumpBannerHeight.distinctUntilChanged().drive(rx.bottomInset),
            viewModel.rx.tags.drive(rx.tags),
            viewModel.rx.attributeGrid.drive(rx.attributeGrid),
            detailView.rx.attributesTap.drive(onNext: { [weak self] _ in
                self?.viewModel.listingAttributeGridTapped()
            })
        ]
        bindings.forEach { $0.disposed(by: disposeBag) }

        detailView.rx
            .map
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
            self?.openMapView()
        }).disposed(by: disposeBag)
        detailView.rx
            .userTap
            .drive(onNext: { [weak self] _ in
                self?.viewModel.openUser()
            }).disposed(by: disposeBag)
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupTransparentNavigationBar()
    }

    private func setupTransparentNavigationBar() {
        setNavBar()
    }

    override func viewDidFirstLayoutSubviews() {
        super.viewDidFirstLayoutSubviews()
        detailView.pageControlTop?.constant = statusBarHeight
    }

    private func setNavBar() {
        let button = UIButton(type: .custom)
        detailView.addSubviewsForAutoLayout([button, moreButton, shareButton, actionNavButton])
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: detailView.topAnchor, constant: statusBarHeight + Metrics.shortMargin),
            button.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: Metrics.veryShortMargin),
            button.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            button.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),

            moreButton.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: detailView.trailingAnchor,
                                                 constant: -Metrics.shortMargin),

            shareButton.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor,
                                                  constant: -Metrics.margin),

            actionNavButton.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            actionNavButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor,
                                                   constant: -Metrics.margin)
        ])
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        button.setImage(R.Asset.IconsButtons.icCloseCarousel.image, for: .normal)
    }

    @objc private func closeView() {
        viewModel.closeDetail()
    }

    func loadDFPRequest() {
        dfpBannerView.adUnitID = viewModel.dfpAdUnitId
        let dfpRequest = DFPRequest()
        dfpRequest.contentURL = viewModel.dfpContentURL
        dfpBannerView.load(dfpRequest)
    }
}

extension ListingDetailViewController: DeckMapViewDelegate {
    func openMapView() {
        guard let data = viewModel.deckMapData else { return }
        let vc = DeckMapViewController(with: data)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func close(_ vc: DeckMapViewController) {
        dismiss(animated: true, completion: nil)
    }
}

private extension Reactive where Base: ListingDetailViewController {
    var bottomInset: Binder<CGFloat?> {
        return Binder(self.base) { controller, inset in
            guard let inset = inset else { return }
            controller.actionBottomInset?.constant = -(inset + Metrics.shortMargin)
            controller.detailView.updateBottomInset(inset + Metrics.shortMargin + Layout.actionButtonHeight)
        }
    }
    var bumpUp: Binder<BumpUpInfo?> { return base.bumpUpVC.rx.bumpInfo }
    var navAction: Binder<ListingAction> {
        return Binder(self.base) { controller, action in
            if action.isFavoritable {
                if action.isFavorite {
                    controller.actionNavButton.setImage(R.Asset.IconsButtons.NewItemPage.nitFavouriteOn.image,
                                                     for: .normal)
                } else {
                    controller.actionNavButton.setImage(R.Asset.IconsButtons.NewItemPage.nitFavourite.image,
                                                     for: .normal)
                }
            } else if action.isEditable {
                controller.actionNavButton.setImage(R.Asset.IconsButtons.icPen.image, for: .normal)
            } else {
                controller.actionNavButton.alpha = 0
            }
            controller.actionNavButton.setNeedsLayout()
        }
    }

    var action: Binder<UIAction?> {
        return Binder(self.base) { controller, actionable in
            if let actionable = actionable {
                controller.actionButton.configureWith(uiAction: actionable)
                controller.actionButton.isHidden = false
            } else {
                controller.actionButton.isHidden = true
            }

            controller.actionButton.rx
                .tap
                .takeUntil(controller.viewModel.rx.action.asObservable().skip(1))
                .bind {
                    actionable?.action()
                }.disposed(by: controller.disposeBag)
        }
    }

    var media: Binder<[Media]> {
        return Binder(self.base) { controller, media in
            controller.detailView.populateWith(media: media, currentIndex: 0)
        }
    }

    var title: Binder<String?> {
        return Binder(self.base) { controller, title in
            controller.detailView.populateWith(title: title)
        }
    }

    var price: Binder<String?> {
        return Binder(self.base) { controller, price in
            controller.detailView.populateWith(price: price)
        }
    }

    var detail: Binder<String?> {
        return Binder(self.base) { controller, detail in
            controller.detailView.populateWith(detail: detail)
        }
    }

    var stats: Binder<ListingDetailStats?> {
        return Binder(self.base) { controller, stats in
            controller.detailView.populateWith(stats: stats)
        }
    }

    var userDetail: Binder<UserDetail?> {
        return Binder(self.base) { controller, userDetail in
            guard let userDetail = userDetail else { return }
            controller.detailView.populateWith(userDetail: userDetail)
        }
    }

    var location: Binder<ListingDetailLocation?> {
        return Binder(self.base) { controller, location in
            controller.detailView.populateWith(location: location)
        }
    }
    
    var social: Binder<(SocialSharer, SocialMessage?)> {
        return Binder(self.base) { controller, social in
            controller.detailView.set(socialSharer: social.0, socialMessage: social.1, socialDelegate: controller)
        }
    }

    var tags: Binder<[String]?> {
        return Binder(self.base) { controller, tags in
            controller.detailView.populateWith(tags: tags)
        }
    }

    var attributeGrid: Binder<AttributeGrid> {
        return Binder(self.base) { controller, grid in
            controller.detailView.setupAttributeGridView(withTitle: grid.0, items: grid.1)
        }
    }
}

extension ListingDetailViewController: SocialShareViewDelegate {
    var viewControllerToShareOver: UIViewController? { return self }
}

// MARK: - GADAdSizeDelegate, GADBannerViewDelegate

extension ListingDetailViewController: GADAdSizeDelegate, GADBannerViewDelegate {
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        let sizeFromAdSize = CGSizeFromGADAdSize(size)
        detailView.updateBannerContainerWith(height: sizeFromAdSize.height,
                                             leftMargin: viewModel.sideMargin,
                                             rightMargin: -viewModel.sideMargin)
        
        let newFrame = CGRect(x: bannerView.frame.origin.x,
                              y: bannerView.frame.origin.y,
                              width: sizeFromAdSize.width,
                              height: sizeFromAdSize.height)
        bannerView.frame = newFrame
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if bannerView.frame.size.height > 0 {
            let absolutePosition = detailView.bannerAbsolutePosition()
            let bannerTop = absolutePosition.y
            let bannerBottom = bannerTop + bannerView.frame.size.height
            viewModel.didReceiveAd(bannerTopPosition: bannerTop,
                                   bannerBottomPosition: bannerBottom,
                                   screenHeight: UIScreen.main.bounds.height,
                                   bannerSize: bannerView.adSize.size)
        }
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.info, type: .monetization, message: "MoreInfo banner failed with error: \(error.localizedDescription)")
        detailView.hideBanner()
        viewModel.didFailToReceiveAd(withErrorCode: GADErrorCode(rawValue: error.code) ?? .internalError,
                                      bannerSize: bannerView.adSize.size)
    }

    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        viewModel.adTapped(typePage: EventParameterTypePage.listingDetailMoreInfo, willLeaveApp: false,
                            bannerSize: bannerView.adSize.size)
    }

    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        viewModel.adTapped(typePage: EventParameterTypePage.listingDetailMoreInfo, willLeaveApp: true,
                            bannerSize: bannerView.adSize.size)
    }
}
