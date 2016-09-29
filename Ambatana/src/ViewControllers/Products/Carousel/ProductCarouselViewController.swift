//
//  ProductCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum ProductDetailButtonType {
    case MarkAsSold
    case SellItAgain
    case CreateCommercial
    case ChatWithSeller
    case ContinueChatting
    case Cancel
}

enum MoreInfoState {
    case Hidden
    case Moving
    case Shown
}

protocol AnimatableTransition {
    var animator: PushAnimator? { get }
}


class ProductCarouselViewController: BaseViewController, AnimatableTransition {

    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonBottom: UIButton!
    @IBOutlet weak var buttonBottomBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTop: UIButton!
    @IBOutlet weak var gradientShadowView: UIView!
    @IBOutlet weak var gradientShadowBottomView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var productStatusView: UIView!
    @IBOutlet weak var productStatusLabel: UILabel!
    
    @IBOutlet weak var directChatTable: UITableView!
    @IBOutlet weak var stickersButton: UIButton!

    private let userView: UserView
    private let fullScreenAvatarEffectView: UIVisualEffectView
    private let fullScreenAvatarView: UIImageView
    private var fullScreenAvatarWidth: NSLayoutConstraint?
    private var fullScreenAvatarHeight: NSLayoutConstraint?
    private var fullScreenAvatarTop: NSLayoutConstraint?
    private var fullScreenAvatarLeft: NSLayoutConstraint?
    private let viewModel: ProductCarouselViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private var currentIndex = 0
    private var userViewBottomConstraint: NSLayoutConstraint?
    private var userViewBottomMargin: CGFloat = 0 {
        didSet{
            userViewBottomConstraint?.constant = userViewBottomMargin
        }
    }

    private let pageControl: UIPageControl
    private let pageControlWidth: CGFloat = 18
    private let pageControlMargin: CGFloat = 18
    private let moreInfoDragMargin: CGFloat = 45
    private let moreInfoExtraHeight: CGFloat = 64
    private let bottomOverscrollDragMargin: CGFloat = 70
    
    private let moreInfoTooltipMargin: CGFloat = 0

    private let itemsMargin: CGFloat = 15
    private let buttonTrailingWithIcon: CGFloat = 75
    private var moreInfoTooltip: Tooltip?

    private let collectionContentOffset = Variable<CGPoint>(CGPoint.zero)
    private let cellZooming = Variable<Bool>(false)

    private var activeDisposeBag = DisposeBag()
    private var productInfoConstraintOffset: CGFloat = 0

    private var productOnboardingView: ProductDetailOnboardingView?
    private var didSetupAfterLayout = false
    
    private var moreInfoView: ProductCarouselMoreInfoView?
    private let moreInfoAlpha = Variable<CGFloat>(1)
    private let moreInfoState = Variable<MoreInfoState>(.Hidden)

    private var interestedBubble: BubbleNotification?



    let animator: PushAnimator?
    var pendingMovement: CarouselMovement?

    private let carouselImageDownloader: ImageDownloader = ImageDownloader.externalBuildImageDownloader(true)

    // MARK: - Lifecycle

    init(viewModel: ProductCarouselViewModel, pushAnimator: ProductCarouselPushAnimator?) {
        self.viewModel = viewModel
        self.userView = UserView.userView(.WithProductInfo)
        let blurEffect = UIBlurEffect(style: .Dark)
        self.fullScreenAvatarEffectView = UIVisualEffectView(effect: blurEffect)
        self.fullScreenAvatarView = UIImageView(frame: CGRect.zero)
        self.animator = pushAnimator
        self.pageControl = UIPageControl(frame: CGRect.zero)
        super.init(viewModel: viewModel, nibName: "ProductCarouselViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent(substyle: .Dark))
        self.viewModel.delegate = self
        hidesBottomBarWhenPushed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientShadowView.layer.sublayers?.forEach{ $0.frame = gradientShadowView.bounds }
        gradientShadowBottomView.layer.sublayers?.forEach{ $0.frame = gradientShadowBottomView.bounds }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupUI()
        setupNavigationBar()
        setupGradientView()
        setupCollectionRx()
        setupZoomRx()
        setAccessibilityIds()
    }

    /*
     We need to setup some properties after we are sure the view has the final frame, to do that
     the animator will tell us when the view has a valid frame to configure the elements.
     `viewDidLayoutSubviews` will be called multiples times, we must assure the setup is done once only.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let animator = animator where animator.toViewValidatedFrame && !didSetupAfterLayout else { return }
        didSetupAfterLayout = true
        imageBackground.image = animator.fromViewSnapshot
        flowLayout.itemSize = view.bounds.size
        setupAlphaRxBindings()
        let startIndexPath = NSIndexPath(forItem: viewModel.startIndex, inSection: 0)
        viewModel.moveToProductAtIndex(viewModel.startIndex, delegate: self, movement: .Initial)
        currentIndex = viewModel.startIndex
        collectionView.reloadData()
        collectionView.scrollToItemAtIndexPath(startIndexPath, atScrollPosition: .Right, animated: false)

        setupMoreInfoDragging()
        setupMoreInfoTooltip()
    }


    // MARK: Setup
    
    func addSubviews() {
        view.addSubview(pageControl)
        fullScreenAvatarEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarEffectView)
        userView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userView)
        fullScreenAvatarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullScreenAvatarView)
    }
    
    func setupUI() {
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(ProductCarouselCell.self,
                                     forCellWithReuseIdentifier: ProductCarouselCell.identifier)
        collectionView.directionalLockEnabled = true
        collectionView.alwaysBounceVertical = false
        automaticallyAdjustsScrollViewInsets = false
        
        pageControl.autoresizingMask = [.FlexibleRightMargin, .FlexibleBottomMargin]
        pageControl.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        pageControl.frame.origin = CGPoint(x: pageControlMargin, y: topBarHeight + pageControlMargin)
        pageControl.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.hidesForSinglePage = true
        pageControl.layer.cornerRadius = pageControlWidth/2
        pageControl.clipsToBounds = true

        let views = ["ev": fullScreenAvatarEffectView]
        let blurHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[ev]|", options: [], metrics: nil,
                                                                             views: views)
        view.addConstraints(blurHConstraints)
        let blurVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[ev]|", options: [], metrics: nil,
                                                                              views: views)
        view.addConstraints(blurVConstraints)

        userView.delegate = self
        let leftMargin = NSLayoutConstraint(item: userView, attribute: .Leading, relatedBy: .Equal, toItem: view,
                                            attribute: .Leading, multiplier: 1, constant: itemsMargin)
        let bottomMargin = NSLayoutConstraint(item: userView, attribute: .Bottom, relatedBy: .Equal, toItem: view,
                                              attribute: .Bottom, multiplier: 1, constant: -itemsMargin)
        let rightMargin = NSLayoutConstraint(item: userView, attribute: .Trailing, relatedBy: .LessThanOrEqual,
                                             toItem: view, attribute: .Trailing, multiplier: 1,
                                             constant: -itemsMargin)
        let height = NSLayoutConstraint(item: userView, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                         attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        view.addConstraints([leftMargin, rightMargin, bottomMargin, height])
        userViewBottomConstraint = bottomMargin
        
        // UserView effect
        fullScreenAvatarEffectView.alpha = 0
        fullScreenAvatarView.clipsToBounds = true
        fullScreenAvatarView.contentMode = .ScaleAspectFill
        fullScreenAvatarView.alpha = 0
        let fullAvatarWidth = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .Width, relatedBy: .Equal, toItem: nil,
                                              attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        fullScreenAvatarWidth = fullAvatarWidth
        let fullAvatarHeight = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                               attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        fullScreenAvatarHeight = fullAvatarHeight
        fullScreenAvatarView.addConstraints([fullAvatarWidth, fullAvatarHeight])
        let fullAvatarTop = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .Top, relatedBy: .Equal,
                                              toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        fullScreenAvatarTop = fullAvatarTop
        let fullAvatarLeft = NSLayoutConstraint(item: fullScreenAvatarView, attribute: .Left, relatedBy: .Equal,
                                               toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        fullScreenAvatarLeft = fullAvatarLeft
        view.addConstraints([fullAvatarTop, fullAvatarLeft])
        userView.showShadow(false)
        
        productStatusView.layer.cornerRadius = productStatusView.height/2
        productStatusLabel.textColor = UIColor.soldColor
        productStatusLabel.font = UIFont.productStatusSoldFont

        editButton.layer.cornerRadius = editButton.height / 2

        setupDirectMessagesAndStickers()
    }
    
    private func setupNavigationBar() {
        let backIconImage = UIImage(named: "ic_close_carousel")
        let backButton = UIBarButtonItem(image: backIconImage, style: UIBarButtonItemStyle.Plain,
                                         target: self, action: #selector(backButtonClose))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    dynamic private func backButtonClose() {
        close()
    }

    private func close() {
        if moreInfoView?.frame.origin.y < 0 {
            viewModel.close()
        } else {
            if let moreInfoView = moreInfoView where moreInfoView.bigMapVisible {
                hideBigMap()
            } else {
                hideMoreInfo()
            }
        }
    }
    
    private func setupGradientView() {
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4, 0], locations: [0, 1])
        shadowLayer.frame = gradientShadowView.bounds
        gradientShadowView.layer.insertSublayer(shadowLayer, atIndex: 0)
        
        let shadowLayer2 = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0, 0.4], locations: [0, 1])
        shadowLayer.frame = gradientShadowBottomView.bounds
        gradientShadowBottomView.layer.insertSublayer(shadowLayer2, atIndex: 0)
    }

    private func setupCollectionRx() {
        viewModel.objectChanges.bindNext { [weak self] change in
            self?.collectionView.handleCollectionChange(change)
        }.addDisposableTo(disposeBag)
    }

    private func setupZoomRx() {
        cellZooming.asObservable().distinctUntilChanged().bindNext { [weak self] zooming in
            UIApplication.sharedApplication().setStatusBarHidden(zooming, withAnimation: .Fade)
            UIView.animateWithDuration(0.3) {
                self?.navigationController?.navigationBar.alpha = zooming ? 0 : 1
                self?.buttonBottom.alpha = zooming ? 0 : 1
                self?.buttonTop.alpha = zooming ? 0 : 1
                self?.userView.alpha = zooming ? 0 : 1
                self?.pageControl.alpha = zooming ? 0 : 1
                self?.moreInfoTooltip?.alpha = zooming ? 0 : 1
                self?.moreInfoView?.dragView.alpha = zooming ? 0 : 1
                self?.favoriteButton.alpha = zooming ? 0 : 1
                self?.stickersButton.alpha = zooming ? 0 : 1
            }
        }.addDisposableTo(disposeBag)
    }
    
    private func setupAlphaRxBindings() {
        let width = view.bounds.width
        let midPoint = width/2
        let minMargin = midPoint * 0.15

        let alphaSignal: Observable<CGFloat> = collectionContentOffset.asObservable()
            .map {
                let midValue = fabs($0.x % width - midPoint)
                if midValue <= minMargin { return 0 }
                if midValue >= (midPoint-minMargin) { return 1}
                let newValue = (midValue - minMargin) / (midPoint - minMargin*2)
                return newValue
        }
        
        alphaSignal.bindTo(buttonBottom.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(userView.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(pageControl.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(buttonTop.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(productStatusView.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(moreInfoAlpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(stickersButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(editButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(directChatTable.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(favoriteButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindNext{ [weak self] alpha in
            self?.moreInfoTooltip?.alpha = alpha
        }.addDisposableTo(disposeBag)
        
        if let navBar = navigationController?.navigationBar {
            alphaSignal.bindTo(navBar.rx_alpha).addDisposableTo(disposeBag)
        }
        
        var indexSignal: Observable<Int> = collectionContentOffset.asObservable().map { Int(($0.x + midPoint) / width) }
        
        if viewModel.startIndex != 0 {
            indexSignal = indexSignal.skip(1)
        }
        indexSignal
            .distinctUntilChanged()
            .bindNext { [weak self] index in
                guard let strongSelf = self else { return }
                let movement: CarouselMovement
                if let pendingMovement = strongSelf.pendingMovement {
                    movement = pendingMovement
                    strongSelf.pendingMovement = nil
                } else if index > strongSelf.currentIndex {
                    movement = .SwipeRight
                } else if index < strongSelf.currentIndex {
                    movement = .SwipeLeft
                } else {
                    movement = .Initial
                }
                if movement != .Initial {
                    self?.viewModel.moveToProductAtIndex(index, delegate: strongSelf, movement: movement)
                }
                self?.refreshOverlayElements()
                strongSelf.currentIndex = index
            }
            .addDisposableTo(disposeBag)
    }
    
    private func configureButton(button: UIButton, type: ProductDetailButtonType, viewModel: ProductViewModel) {
        button.hidden = false
        var action: (() -> ())?
        switch type {
        case .MarkAsSold:
            button.setTitle(LGLocalizedString.productMarkAsSoldButton, forState: .Normal)
            button.setStyle(.Terciary)
            action = viewModel.markSold
        case .SellItAgain:
            button.setTitle(LGLocalizedString.productSellAgainButton, forState: .Normal)
            button.setStyle(.Secondary(fontSize: .Big, withBorder: false))
            action = viewModel.resell
        case .CreateCommercial:
            button.setTitle(LGLocalizedString.productCreateCommercialButton, forState: .Normal)
            button.setStyle(.Primary(fontSize: .Big))
            action = viewModel.promoteProduct
        case .ChatWithSeller:
            let userName: String = viewModel.product.value.user.name?
                .toNameReduced(maxChars: Constants.maxCharactersOnUserNameChatButton) ?? ""
            let string = LGLocalizedString.productChatWithSellerNameButton(userName)
            button.setTitle(string, forState: .Normal)
            button.setStyle(.Primary(fontSize: .Big))
            action =  { [weak self] in
                let source: EventParameterTypePage = (self?.moreInfoState.value == .Shown) ? .ProductDetailMoreInfo : .ProductDetail
                viewModel.chatWithSeller(source)
            }
        case .ContinueChatting:
            button.setTitle(LGLocalizedString.productContinueChattingButton, forState: .Normal)
            button.setStyle(.Secondary(fontSize: .Big, withBorder: false))
        case .Cancel:
            button.setTitle(LGLocalizedString.commonCancel, forState: .Normal)
            button.setStyle(.Secondary(fontSize: .Big, withBorder: false))
        }
        
        button.rx_tap.takeUntil(viewModel.status.asObservable().skip(1)).bindNext {
            action?()
        }.addDisposableTo(activeDisposeBag)
    }
}


// MARK: > Configure Carousel With ProductViewModel

extension ProductCarouselViewController {

    private func refreshOverlayElements() {
        guard let viewModel = viewModel.currentProductViewModel else { return }
        activeDisposeBag = DisposeBag()
        setupUserView(viewModel)
        setupFullScreenAvatarView(viewModel)
        setupRxNavbarBindings(viewModel)
        setupRxProductUpdate(viewModel)
        refreshPageControl(viewModel)
        refreshProductOnboarding(viewModel)
        refreshBottomButtons(viewModel)
        refreshProductStatusLabel(viewModel)
        refreshDirectChatElements(viewModel)
        refreshFavoriteButton(viewModel)
        setupMoreInfo(viewModel)
        refreshInterestedBubble(viewModel)
    }
    
    private func setupMoreInfo(viewModel: ProductViewModel) {
        if moreInfoView == nil {
            moreInfoView = ProductCarouselMoreInfoView.moreInfoView(viewModel)
            if let moreInfoView = moreInfoView {
                view.addSubview(moreInfoView)
                moreInfoAlpha.asObservable().bindTo(moreInfoView.rx_alpha).addDisposableTo(disposeBag)
                moreInfoAlpha.asObservable().bindTo(moreInfoView.dragView.rx_alpha).addDisposableTo(disposeBag)
            }
            view.bringSubviewToFront(buttonBottom)
            view.bringSubviewToFront(stickersButton)
            view.bringSubviewToFront(editButton)
            view.bringSubviewToFront(fullScreenAvatarEffectView)
            view.bringSubviewToFront(fullScreenAvatarView)
            view.bringSubviewToFront(directChatTable)
        }
        moreInfoView?.update(viewModel)
        moreInfoView?.frame = view.bounds
        moreInfoView?.height = view.height + moreInfoExtraHeight
        moreInfoView?.frame.origin.y = -view.bounds.height

        moreInfoState.asObservable().bindTo(viewModel.moreInfoState).addDisposableTo(activeDisposeBag)
    }

    private func setupUserView(viewModel: ProductViewModel) {
        userView.setupWith(userAvatar: viewModel.ownerAvatar,
                           userName: viewModel.ownerName,
                           productTitle: viewModel.productTitle.value,
                           productPrice: viewModel.productPrice.value,
                           userId: viewModel.ownerId)
    }

    private func setupFullScreenAvatarView(viewModel: ProductViewModel) {
        fullScreenAvatarView.alpha = 0
        fullScreenAvatarView.image = viewModel.ownerAvatarPlaceholder
        if let avatar = viewModel.ownerAvatar {
            ImageDownloader.sharedInstance.downloadImageWithURL(avatar) { [weak self] result, url in
                guard let imageWithSource = result.value where url == self?.viewModel.currentProductViewModel?.ownerAvatar else { return }
                self?.fullScreenAvatarView.image = imageWithSource.image
            }
        }
    }

    private func setupRxNavbarBindings(viewModel: ProductViewModel) {
        setNavigationBarRightButtons([])
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }

            if navBarButtons.count == 1 {
                strongSelf.setLetGoRightButtonWith(navBarButtons[0], disposeBag: strongSelf.disposeBag,
                    buttonTintColor: UIColor.white)
            } else if navBarButtons.count > 1 {
                var buttons = [UIButton]()
                navBarButtons.forEach { navBarButton in
                    let button = UIButton(type: .System)
                    button.setImage(navBarButton.image, forState: .Normal)
                    button.rx_tap.bindNext { _ in
                        navBarButton.action()
                        }.addDisposableTo(strongSelf.disposeBag)
                    buttons.append(button)
                }
                strongSelf.setNavigationBarRightButtons(buttons)
            }
        }.addDisposableTo(activeDisposeBag)
    }

    private func setupRxProductUpdate(viewModel: ProductViewModel) {
        viewModel.product.asObservable().bindNext { [weak self] _ in
            guard let strongSelf = self else { return }
            let visibleIndexPaths = strongSelf.collectionView.indexPathsForVisibleItems()
            //hiding fake list background to avoid showing it while the cell reloads
            self?.imageBackground.hidden = true
            strongSelf.collectionView.performBatchUpdates({ [weak self] in
                 self?.collectionView.reloadItemsAtIndexPaths(visibleIndexPaths)
            }, completion: { [weak self] _ in
                self?.imageBackground.hidden = false
            })
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshPageControl(viewModel: ProductViewModel) {
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.product.value.images.count
        pageControl.frame.size = CGSize(width: pageControlWidth, height:
        pageControl.sizeForNumberOfPages(pageControl.numberOfPages).width + pageControlWidth)
    }
    
    private func refreshBottomButtons(viewModel: ProductViewModel) {
        
        let userViewMarginAboveBottomButton = view.frame.height - buttonBottom.frame.origin.y + itemsMargin
        let userViewMarginAboveTopButton = view.frame.height - buttonTop.frame.origin.y + itemsMargin
        let userViewMarginWithoutButtons = itemsMargin
        
        guard buttonBottom.frame.origin.y > 0 else { return }
        
        viewModel.status.asObservable().subscribeNext { [weak self] status in
            
            guard let strongSelf = self else { return }
            
            self?.buttonTop.hidden = true
            self?.buttonBottom.hidden = true
            self?.userViewBottomMargin = -(userViewMarginAboveBottomButton)
            
            switch status {
            case .Pending, .NotAvailable, .OtherSold:
                self?.userViewBottomMargin = -userViewMarginWithoutButtons
            case .PendingAndCommercializable:
                self?.configureButton(strongSelf.buttonBottom, type: .CreateCommercial, viewModel: viewModel)
            case .Available:
                self?.configureButton(strongSelf.buttonBottom, type: .MarkAsSold, viewModel: viewModel)
            case .AvailableAndCommercializable:
                self?.configureButton(strongSelf.buttonBottom, type: .MarkAsSold, viewModel: viewModel)
                self?.configureButton(strongSelf.buttonTop, type: .CreateCommercial, viewModel: viewModel)
                self?.userViewBottomMargin = -(userViewMarginAboveTopButton)
            case .Sold:
                self?.configureButton(strongSelf.buttonBottom, type: .SellItAgain, viewModel: viewModel)
            case .OtherAvailable:
                self?.configureButton(strongSelf.buttonBottom, type: .ChatWithSeller, viewModel: viewModel)
            }
        }.addDisposableTo(activeDisposeBag)

        viewModel.editButtonState.asObservable().bindTo(editButton.rx_state).addDisposableTo(disposeBag)
        editButton.rx_tap.bindNext { [weak self, weak viewModel] in
            self?.hideMoreInfo()
            viewModel?.editProduct()
        }.addDisposableTo(disposeBag)

        let editButtonEnabled = viewModel.editButtonState.asObservable().map { return $0 != .Hidden }
        let bottomButtonCollapsed = Observable.combineLatest(viewModel.stickersButtonEnabled.asObservable(),
                                    editButtonEnabled, resultSelector: { (stickers, edit) in return stickers || edit })
        bottomButtonCollapsed.bindNext { [weak self] collapsed in
            self?.buttonBottomTrailingConstraint.constant = (collapsed ? self?.buttonTrailingWithIcon : self?.itemsMargin) ?? 0
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshProductOnboarding(viewModel: ProductViewModel) {
        guard  let navigationCtrlView = navigationController?.view ?? view else { return }
        guard self.viewModel.shouldShowOnboarding else { return }
        // if state is nil, means there's no need to show the onboarding
        productOnboardingView = ProductDetailOnboardingView.instanceFromNibWithState()

        guard let onboarding = productOnboardingView else { return }
        onboarding.delegate = self
        navigationCtrlView.addSubview(onboarding)
        onboarding.setupUI()
        onboarding.frame = navigationCtrlView.frame
        onboarding.layoutIfNeeded()
    }
    
    private func refreshProductStatusLabel(viewModel: ProductViewModel) {
        viewModel.productStatusLabelText
            .asObservable()
            .map{ $0?.isEmpty ?? true}
            .bindTo(productStatusView.rx_hidden)
            .addDisposableTo(activeDisposeBag)
        
        viewModel.productStatusLabelText
            .asObservable()
            .map{$0 ?? ""}
            .bindTo(productStatusLabel.rx_text)
            .addDisposableTo(activeDisposeBag)
    }

    private func refreshDirectChatElements(viewModel: ProductViewModel) {
        viewModel.stickersButtonEnabled.asObservable().bindNext { [weak self] enabled in
            guard let strongSelf = self else { return }
            strongSelf.stickersButton.hidden = !enabled
        }.addDisposableTo(activeDisposeBag)

        viewModel.directChatMessages.changesObservable.bindNext { [weak self] change in
            self?.directChatTable.handleCollectionChange(change, animation: .Top)
        }.addDisposableTo(activeDisposeBag)
        directChatTable.reloadData()
    }

    private func refreshFavoriteButton(viewModel: ProductViewModel) {
        viewModel.favoriteButtonState.asObservable()
            .bindTo(favoriteButton.rx_state)
            .addDisposableTo(activeDisposeBag)

        viewModel.isFavorite.asObservable()
            .bindNext { [weak self] favorite in
                self?.favoriteButton.setImage(UIImage(named: favorite ? "ic_favorite_big_on" : "ic_favorite_big_off"), forState: .Normal)
            }.addDisposableTo(activeDisposeBag)

        favoriteButton.rx_tap.bindNext { [weak viewModel] in
            viewModel?.switchFavorite()
        }.addDisposableTo(activeDisposeBag)
    }

    private func refreshInterestedBubble(viewModel: ProductViewModel) {
        hideInterestedBubble()
        viewModel.showInterestedBubble.asObservable().filter{$0}.bindNext{ [weak self, weak viewModel] _ in
            let productId = viewModel?.product.value.objectId
            let text = viewModel?.interestedBubbleTitle
            let icon = viewModel?.interestedBubbleIcon
            self?.showInterestedBubbleForProduct(productId, text: text, icon: icon)
        }.addDisposableTo(activeDisposeBag)
    }
}


extension ProductCarouselViewController: UserViewDelegate {
    func userViewAvatarPressed(userView: UserView) {
        viewModel.openProductOwnerProfile()
    }

    func userViewAvatarLongPressStarted(userView: UserView) {
        view.bringSubviewToFront(fullScreenAvatarView)
        fullScreenAvatarLeft?.constant = userView.frame.left + userView.userAvatarImageView.frame.left
        fullScreenAvatarTop?.constant = userView.frame.top + userView.userAvatarImageView.frame.top
        fullScreenAvatarWidth?.constant = userView.userAvatarImageView.frame.size.width
        fullScreenAvatarHeight?.constant = userView.userAvatarImageView.frame.size.height
        view.layoutIfNeeded()

        let viewSide = min(view.frame.width, view.frame.height)
        fullScreenAvatarLeft?.constant = view.frame.centerX - viewSide/2
        fullScreenAvatarTop?.constant = view.frame.centerY - viewSide/2
        fullScreenAvatarWidth?.constant = viewSide
        fullScreenAvatarHeight?.constant = viewSide
        UIView.animateWithDuration(0.25) { [weak self] in
            self?.navigationController?.navigationBar.alpha = 0
            self?.fullScreenAvatarEffectView.alpha = 1
            self?.fullScreenAvatarView.alpha = 1
            self?.view.layoutIfNeeded()
        }
    }

    func userViewAvatarLongPressEnded(userView: UserView) {
        fullScreenAvatarLeft?.constant = userView.frame.left + userView.userAvatarImageView.frame.left
        fullScreenAvatarTop?.constant = userView.frame.top + userView.userAvatarImageView.frame.top
        fullScreenAvatarWidth?.constant = userView.userAvatarImageView.frame.size.width
        fullScreenAvatarHeight?.constant = userView.userAvatarImageView.frame.size.height
        UIView.animateWithDuration(0.25) { [weak self] in
            self?.navigationController?.navigationBar.alpha = 1
            self?.fullScreenAvatarEffectView.alpha = 0
            self?.fullScreenAvatarView.alpha = 0
            self?.view.layoutIfNeeded()
        }
    }
}


// MARK: > ProductCarouselViewModelDelegate

extension ProductCarouselViewController: ProductCarouselViewModelDelegate {
    func vmRefreshCurrent() {
        refreshOverlayElements()
    }

    func vmRemoveMoreInfoTooltip() {
        removeMoreInfoTooltip()
    }
}


// MARK: > ProductCarousel Cell Delegate

extension ProductCarouselViewController: ProductCarouselCellDelegate {
    func didTapOnCarouselCell(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPathForCell(cell) else { return }
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItemsInSection(0) {
            pendingMovement = .Tap
            let nextIndexPath = NSIndexPath(forItem: newIndexRow, inSection: 0)
            collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .Right, animated: false)
        } else {
            collectionView.showRubberBandEffect(.Right)
        }
    }

    func isZooming(zooming: Bool) {
        cellZooming.value = zooming
    }

    func didScrollToPage(page: Int) {
        pageControl.currentPage = page
    }
    
    func didPullFromCellWith(offset: CGFloat, bottomLimit: CGFloat) {
        guard let moreInfoView = moreInfoView where moreInfoState.value != .Shown && !cellZooming.value else { return }
        if moreInfoView.frame.origin.y-offset > -view.frame.height {
            moreInfoState.value = .Moving
            moreInfoView.frame.origin.y = moreInfoView.frame.origin.y-offset
        } else {
            moreInfoState.value = .Hidden
        }

        let bottomOverScroll = max(offset-bottomLimit, 0)
        buttonBottomBottomConstraint.constant = itemsMargin + bottomOverScroll
        userViewBottomConstraint?.constant = userViewBottomMargin - bottomOverScroll
    }
    
    func didEndDraggingCell() {
        if moreInfoView?.frame.bottom > moreInfoDragMargin*2 {
            showMoreInfo()
        } else {
            hideMoreInfo()
        }
    }
    
    func canScrollToNextPage() -> Bool {
        return moreInfoState.value == .Hidden
    }
}


// MARK: > More Info

extension ProductCarouselViewController {
    
    func setupMoreInfoDragging() {
        guard let button = moreInfoView?.dragView else { return }
        self.navigationController?.navigationBar.ignoreTouchesFor(button)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragMoreInfoButton))
        button.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dragViewTapped))
        button.addGestureRecognizer(tap)
        moreInfoView?.delegate = self
    }
    
    func dragMoreInfoButton(pan: UIPanGestureRecognizer) {
        let point = pan.locationInView(view)
        
        if point.y >= moreInfoExtraHeight { // start dragging when point is below the navbar
            moreInfoView?.frame.bottom = point.y
        }
        
        switch pan.state {
        case .Ended:
            if point.y > moreInfoDragMargin {
                showMoreInfo()
            } else {
                hideMoreInfo()
            }
        default:
            break
        }
    }
    
    func dragViewTapped(tap: UITapGestureRecognizer) {
        showMoreInfo()
    }
    
    @IBAction func showMoreInfo() {
        guard moreInfoState.value == .Hidden || moreInfoState.value == .Moving else { return }

        moreInfoState.value = .Shown
        viewModel.didOpenMoreInfo()

        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [],
                                   animations: { [weak self] in
                                    self?.moreInfoView?.frame.origin.y = 0
                                    }, completion: nil)
    }

    func hideMoreInfo() {
        guard moreInfoState.value == .Shown || moreInfoState.value == .Moving else { return }

        moreInfoState.value = .Hidden
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [],
                                   animations: { [weak self] in
            guard let `self` = self else { return }
            self.moreInfoView?.frame.origin.y = -self.view.bounds.height
        }, completion: { [weak self] _ in
            self?.moreInfoView?.dismissed()
        })
    }

    func hideBigMap() {
        guard let moreInfoView = moreInfoView where moreInfoView.bigMapVisible else { return }
        moreInfoView.hideBigMap()
    }
}


// MARK: More Info Delegate

extension ProductCarouselViewController: ProductCarouselMoreInfoDelegate {
    
    func didEndScrolling(topOverScroll: CGFloat, bottomOverScroll: CGFloat) {
        if topOverScroll > moreInfoDragMargin || bottomOverScroll > moreInfoDragMargin {
            hideMoreInfo()
        }
    }
    
    func shareDidFailedWith(error: String) {
        showAutoFadingOutMessageAlert(error)
    }
    
    func viewControllerToShowShareOptions() -> UIViewController {
        return self
    }
}


// MARK: > ToolTip

extension ProductCarouselViewController {
    
    private func setupMoreInfoTooltip() {
        guard viewModel.shouldShowMoreInfoTooltip else { return }
        guard let moreInfoView = moreInfoView else { return }
        
        let tapTextAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.white,
                                                       NSFontAttributeName : UIFont.systemBoldFont(size: 17)]
        let infoTextAttributes: [String : AnyObject] = [ NSForegroundColorAttributeName : UIColor.grayLighter,
                                                         NSFontAttributeName : UIFont.systemSemiBoldFont(size: 17)]
        let plainText = LGLocalizedString.productMoreInfoTooltipPart2(LGLocalizedString.productMoreInfoTooltipPart1)
        let resultText = NSMutableAttributedString(string: plainText, attributes: infoTextAttributes)
        let boldRange = NSString(string: plainText).rangeOfString(LGLocalizedString.productMoreInfoTooltipPart1,
                                                                  options: .CaseInsensitiveSearch)
        resultText.addAttributes(tapTextAttributes, range: boldRange)
        
        let moreInfoTooltip = Tooltip(targetView: moreInfoView, superView: view, title: resultText,
                                      style: .Blue(closeEnabled: false), peakOnTop: true,
                                      actionBlock: { [weak self] in self?.showMoreInfo() }, closeBlock: nil)
        view.addSubview(moreInfoTooltip)
        setupExternalConstraintsForTooltip(moreInfoTooltip, targetView: moreInfoView, containerView: view,
                                           margin: moreInfoTooltipMargin)
        self.moreInfoTooltip = moreInfoTooltip
    }
    
    private func removeMoreInfoTooltip() {
        moreInfoTooltip?.removeFromSuperview()
        moreInfoTooltip = nil
    }
}


// MARK: > CollectionView delegates

extension ProductCarouselViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard didSetupAfterLayout else { return 0 }
        return viewModel.objectCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProductCarouselCell.identifier,
                                                                             forIndexPath: indexPath)
            guard let carouselCell = cell as? ProductCarouselCell else { return UICollectionViewCell() }
            guard let product = viewModel.productAtIndex(indexPath.row) else { return carouselCell }
            carouselCell.configureCellWithProduct(product, placeholderImage: viewModel.thumbnailAtIndex(indexPath.row),
                                                  indexPath: indexPath, imageDownloader: carouselImageDownloader)
            carouselCell.delegate = self
            return carouselCell
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.viewModel.setCurrentIndex(indexPath.row)
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        collectionContentOffset.value = scrollView.contentOffset
    }
}


// MARK: > Direct messages and stickers

extension ProductCarouselViewController: UITableViewDataSource, UITableViewDelegate {

    func setupDirectMessagesAndStickers() {
        ChatCellDrawerFactory.registerCells(directChatTable)
        directChatTable.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        directChatTable.rowHeight = UITableViewAutomaticDimension
        directChatTable.estimatedRowHeight = 140

        stickersButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.currentProductViewModel?.stickersButton()
        }.addDisposableTo(disposeBag)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentProductViewModel?.directChatMessages.value.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let messages = viewModel.currentProductViewModel?.directChatMessages.value else { return UITableViewCell() }
        guard 0..<messages.count ~= indexPath.row else { return UITableViewCell() }
        let message = messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message, autoHide: true)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message, delegate: self)
        cell.transform = tableView.transform

        return cell
    }
}


// MARK: > Interested bubble

extension ProductCarouselViewController {
    func showInterestedBubbleForProduct(productId: String?, text: String?, icon: UIImage?){
        guard let navView = navigationController?.view else { return }
        interestedBubble = BubbleNotification(text: text, icon: icon)
        guard let interestedBubble = interestedBubble else { return }
        interestedBubble.translatesAutoresizingMaskIntoConstraints = false

        navView.addSubview(interestedBubble)
        interestedBubble.setupOnView(navView)

        navView.bringSubviewToFront(interestedBubble)
        interestedBubble.showBubble()
    }

    func hideInterestedBubble() {
        guard let interestedBubble = interestedBubble else { return }
        interestedBubble.removeBubble()
        self.interestedBubble = nil
    }
}

// MARK: > Product View Model Delegate

extension ProductCarouselViewController: ProductViewModelDelegate {
    func vmShowNativeShare(socialMessage: SocialMessage) {
        let barButtonItem = navigationItem.rightBarButtonItems?.first
        presentNativeShare(socialMessage: socialMessage, delegate: viewModel, barButtonItem: barButtonItem)
    }
    
    func vmOpenMainSignUp(signUpVM: SignUpViewModel, afterLoginAction: () -> ()) {
        let mainSignUpVC = MainSignUpViewController(viewModel: signUpVM)
        mainSignUpVC.afterLoginAction = afterLoginAction
        
        let navCtl = UINavigationController(rootViewController: mainSignUpVC)
        navCtl.view.backgroundColor = UIColor.whiteColor()
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    func vmOpenPromoteProduct(promoteVM: PromoteProductViewModel) {
        let promoteProductVC = PromoteProductViewController(viewModel: promoteVM)
        navigationController?.presentViewController(promoteProductVC, animated: true, completion: nil)
    }
    
    func vmOpenCommercialDisplay(displayVM: CommercialDisplayViewModel) {
        let commercialDisplayVC = CommercialDisplayViewController(viewModel: displayVM)
        navigationController?.presentViewController(commercialDisplayVC, animated: true, completion: nil)
    }

    func vmAskForRating() {
        guard let tabBarCtrl = self.tabBarController as? TabBarController else { return }
        tabBarCtrl.showAppRatingViewIfNeeded(.MarkedSold)
    }
    
    func vmShowOnboarding() {
        guard let productVM = viewModel.currentProductViewModel else { return }
        refreshProductOnboarding(productVM)
    }
    
    func vmShowProductDelegateActionSheet(cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }

    func vmOpenStickersSelector(stickers: [Sticker]) {
        let interlocutorName = viewModel.currentProductViewModel?.ownerName
        let vc = StickersSelectorViewController(stickers: stickers, interlocutorName: interlocutorName)
        vc.delegate = self
        navigationController?.presentViewController(vc, animated: false, completion: nil)
    }
}


// MARK: - ProductDetailOnboardingViewDelegate

extension ProductCarouselViewController: ProductDetailOnboardingViewDelegate {
    func productDetailOnboardingDidAppear() {
        // nav bar behaves weird when is hidden in mainproducts list and the onboarding is shown
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func productDetailOnboardingDidDisappear() {
        // nav bar shown again, but under the onboarding
        navigationController?.setNavigationBarHidden(false, animated: false)
        productOnboardingView = nil
    }
}


// MARK: - StickersSelectorDelegate

extension ProductCarouselViewController: StickersSelectorDelegate {
    func stickersSelectorDidSelectSticker(sticker: Sticker) {
        viewModel.currentProductViewModel?.sendSticker(sticker)
    }

    func stickersSelectorDidCancel() {}
}


// MARK: - Accessibility ids

extension ProductCarouselViewController {
    private func setAccessibilityIds() {
        collectionView.accessibilityId = .ProductCarouselCollectionView
        buttonBottom.accessibilityId = .ProductCarouselButtonBottom
        buttonTop.accessibilityId = .ProductCarouselButtonTop
        favoriteButton.accessibilityId = .ProductCarouselFavoriteButton
        moreInfoView?.accessibilityId = .ProductCarouselMoreInfoView
        productStatusLabel.accessibilityId = .ProductCarouselProductStatusLabel
        directChatTable.accessibilityId = .ProductCarouselDirectChatTable
        stickersButton.accessibilityId = .ProductCarouselStickersButton
        editButton.accessibilityId = .ProductCarouselEditButton
        fullScreenAvatarView.accessibilityId = .ProductCarouselFullScreenAvatarView
        pageControl.accessibilityId = .ProductCarouselPageControl
    }
}
