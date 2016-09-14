//
//  ProductViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift
import CollectionVariable


protocol ProductViewModelDelegate: class, BaseViewModelDelegate {
    func vmShowNativeShare(socialMessage: SocialMessage)

    func vmOpenMainSignUp(signUpVM: SignUpViewModel, afterLoginAction: () -> ())

    func vmOpenStickersSelector(stickers: [Sticker])

    func vmOpenPromoteProduct(promoteVM: PromoteProductViewModel)
    func vmOpenCommercialDisplay(displayVM: CommercialDisplayViewModel)
    func vmAskForRating()
    func vmShowOnboarding()
    func vmShowProductDelegateActionSheet(cancelLabel: String, actions: [UIAction])
}


enum ProductViewModelStatus {
    
    // When Mine:
    case Pending
    case PendingAndCommercializable
    case Available
    case AvailableAndCommercializable
    case Sold
    
    // Other Selling:
    case OtherAvailable
    case OtherSold
    
    // Common:
    case NotAvailable
}


class ProductViewModel: BaseViewModel {

    // Delegate
    weak var delegate: ProductViewModelDelegate?
    weak var navigator: ProductDetailNavigator?

    // Data
    let product: Variable<Product>
    private let commercializers: Variable<[Commercializer]?>
    private let isReported = Variable<Bool>(false)
    let isFavorite = Variable<Bool>(false)
    let viewsCount = Variable<Int>(0)
    let favouritesCount = Variable<Int>(0)
    let socialMessage = Variable<SocialMessage?>(nil)

    // UI - Output
    let thumbnailImage: UIImage?

    let directChatMessages = CollectionVariable<ChatViewMessage>([])

    let navBarButtons = Variable<[UIAction]>([])
    private let productIsFavoriteable = Variable<Bool>(false)
    let favoriteButtonState = Variable<ButtonState>(.Enabled)
    let productStatusBackgroundColor = Variable<UIColor>(UIColor.blackColor())
    let productStatusLabelText = Variable<String?>(nil)
    let productStatusLabelColor = Variable<UIColor>(UIColor.whiteColor())

    let productImageURLs = Variable<[NSURL]>([])

    let productTitle = Variable<String?>(nil)
    let productPrice = Variable<String>("")
    let productTitleAutogenerated = Variable<Bool>(false)
    let productTitleAutoTranslated = Variable<Bool>(false)
    let productDescription = Variable<String?>(nil)
    let productAddress = Variable<String?>(nil)
    let productLocation = Variable<LGLocationCoordinates2D?>(nil)
    let productIsReportable = Variable<Bool>(true)
    let productDistance = Variable<String?>(nil)
    let productCreationDate = Variable<NSDate?>(nil)

    let ownerId: String?
    let ownerName: String
    let ownerAvatar: NSURL?
    let ownerAvatarPlaceholder: UIImage?
    
    let status = Variable<ProductViewModelStatus>(.Pending)
    private let productHasReadyCommercials = Variable<Bool>(false)
    var commercializerAvailableTemplatesCount: Int? = nil

    let statsViewVisible = Variable<Bool>(false)

    let stickersButtonEnabled = Variable<Bool>(false)
    private var selectableStickers: [Sticker] = []

    let showInterestedBubble = Variable<Bool>(false)
    var interestedBubbleTitle: String?
    var interestedBubbleIcon: UIImage?
    var isFirstProduct: Bool = false

    // UI - Input
    let moreInfoState = Variable<MoreInfoState>(.Hidden)

    // Repository, helpers & tracker
    let trackHelper: ProductVMTrackHelper
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let commercializerRepository: CommercializerRepository
    private let chatWrapper: ChatWrapper
    private let stickersRepository: StickersRepository
    private let countryHelper: CountryHelper
    private let locationManager: LocationManager
    private let chatViewMessageAdapter: ChatViewMessageAdapter
    private let interestedBubbleManager: BubbleNotificationManager

    // Rx
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    convenience init(product: ChatProduct, user: ChatInterlocutor, thumbnailImage: UIImage?, navigator: ProductDetailNavigator?) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let commercializerRepository = Core.commercializerRepository
        let countryHelper = Core.countryHelper
        let chatWrapper = ChatWrapper()
        let stickersRepository = Core.stickersRepository
        let locationManager = Core.locationManager
        
        let product = productRepository.build(fromChatproduct: product, chatInterlocutor: user)
        
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  commercializerRepository: commercializerRepository, chatWrapper: chatWrapper,
                  stickersRepository: stickersRepository, locationManager: locationManager, countryHelper: countryHelper,
                  product: product, thumbnailImage: thumbnailImage, navigator: navigator,
                  interestedBubbleManager: BubbleNotificationManager.sharedInstance)
        syncProduct(nil)
    }
    
    convenience init(product: Product, thumbnailImage: UIImage?, navigator: ProductDetailNavigator?) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let commercializerRepository = Core.commercializerRepository
        let countryHelper = Core.countryHelper
        let chatWrapper = ChatWrapper()
        let stickersRepository = Core.stickersRepository
        let locationManager = Core.locationManager
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  commercializerRepository: commercializerRepository, chatWrapper: chatWrapper,
                  stickersRepository: stickersRepository, locationManager: locationManager, countryHelper: countryHelper,
                  product: product, thumbnailImage: thumbnailImage, navigator: navigator,
                  interestedBubbleManager: BubbleNotificationManager.sharedInstance)
    }

    init(myUserRepository: MyUserRepository, productRepository: ProductRepository,
         commercializerRepository: CommercializerRepository, chatWrapper: ChatWrapper,
         stickersRepository: StickersRepository, locationManager: LocationManager, countryHelper: CountryHelper,
         product: Product, thumbnailImage: UIImage?, navigator: ProductDetailNavigator?,
         interestedBubbleManager: BubbleNotificationManager) {
        self.product = Variable<Product>(product)
        self.thumbnailImage = thumbnailImage
        self.myUserRepository = myUserRepository
        self.productRepository = productRepository
        self.countryHelper = countryHelper
        self.trackHelper = ProductVMTrackHelper(product: product)
        self.commercializerRepository = commercializerRepository
        self.commercializers = Variable<[Commercializer]?>(nil)
        self.chatWrapper = chatWrapper
        self.stickersRepository = stickersRepository
        self.locationManager = locationManager
        self.navigator = navigator
        self.chatViewMessageAdapter = ChatViewMessageAdapter()
        self.interestedBubbleManager = interestedBubbleManager

        let ownerId = product.user.objectId
        self.ownerId = ownerId
        let myUser = myUserRepository.myUser
        let ownerIsMyUser: Bool
        if let productUserId = product.user.objectId, myUser = myUser, myUserId = myUser.objectId {
            ownerIsMyUser = ( productUserId == myUserId )
        } else {
            ownerIsMyUser = false
        }
        let myUsername = myUser?.shortName
        let ownerUsername = product.user.shortName
        self.ownerName = ownerIsMyUser ? (myUsername ?? ownerUsername ?? "") : (ownerUsername ?? "")
        let myAvatarURL = myUser?.avatar?.fileURL
        let ownerAvatarURL = product.user.avatar?.fileURL
        self.ownerAvatar = ownerIsMyUser ? (myAvatarURL ?? ownerAvatarURL) : ownerAvatarURL

        if ownerIsMyUser {
            self.ownerAvatarPlaceholder = LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor,
                                                                      name: ownerUsername)
        } else {
            self.ownerAvatarPlaceholder = LetgoAvatar.avatarWithID(ownerId, name: ownerUsername)
        }

        self.disposeBag = DisposeBag()

        super.init()

        setupRxBindings()
    }
    
    internal override func didBecomeActive(firstTime: Bool) {

        guard let productId = product.value.objectId else { return }

        productRepository.retrieveUserProductRelation(productId) { [weak self] result in
            guard let strongSelf = self else { return }
            if let favorited = result.value?.isFavorited, let reported = result.value?.isReported {
                strongSelf.isFavorite.value = favorited
                strongSelf.isReported.value = reported
            }
        }

        productRepository.incrementViews(product.value, completion: nil)

        productRepository.retrieveStats(product.value) { [weak self] result in
            guard let strongSelf = self else { return }
            if let stats = result.value {
                strongSelf.viewsCount.value = stats.viewsCount
                strongSelf.favouritesCount.value = stats.favouritesCount
                if strongSelf.isFirstProduct {
                    strongSelf.refreshInterestedBubble(false)
                }
            }
        }

        if commercializerIsAvailable {
            commercializerRepository.index(productId) { [weak self] result in
                guard let value = result.value, let strongSelf = self else { return }

                if let code = strongSelf.product.value.postalAddress.countryCode {
                    let availableTemplates = strongSelf.commercializerRepository.availableTemplatesFor(value,
                                                                                                       countryCode: code)
                    strongSelf.commercializerAvailableTemplatesCount = availableTemplates.count
                    strongSelf.refreshStatus()
                }

                let readyCommercials = value.filter {$0.status == .Ready }
                self?.productHasReadyCommercials.value = !readyCommercials.isEmpty
                self?.commercializers.value = value
            }
        }
    }
    
    func syncProduct(completion: (() -> ())?) {
        guard let productId = product.value.objectId else { return }
        productRepository.retrieve(productId) { [weak self] result in
            if let value = result.value {
                self?.product.value = value
            }
            completion?()
        }
    }

    private func setupRxBindings() {
        
        status.asObservable().subscribeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.productStatusBackgroundColor.value = status.bgColor
            strongSelf.productStatusLabelText.value = status.string
            strongSelf.productStatusLabelColor.value = status.labelColor
            }.addDisposableTo(disposeBag)

        isFavorite.asObservable().subscribeNext { [weak self] _ in
            self?.refreshNavBarButtons()
        }.addDisposableTo(disposeBag)

        product.asObservable().subscribeNext { [weak self] product in
            guard let strongSelf = self else { return }
            strongSelf.trackHelper.product = product

            strongSelf.refreshStatus()

            strongSelf.productIsFavoriteable.value = !product.isMine
            strongSelf.isFavorite.value = product.favorite
            strongSelf.socialMessage.value = SocialHelper.socialMessageWithProduct(product)
            strongSelf.productImageURLs.value = product.images.flatMap { return $0.fileURL }

            strongSelf.productTitle.value = product.title
            strongSelf.productTitleAutogenerated.value = product.isTitleAutoGenerated
            strongSelf.productTitleAutoTranslated.value = product.isTitleAutoTranslated(strongSelf.countryHelper)
            strongSelf.productDescription.value = product.description?.trim
            strongSelf.productPrice.value = product.priceString()
            strongSelf.productAddress.value = product.postalAddress.zipCodeCityString
            strongSelf.productLocation.value = product.location
            strongSelf.productIsReportable.value = !product.isMine
            strongSelf.productDistance.value = strongSelf.distanceString(product)
            strongSelf.productCreationDate.value = product.createdAt
            }.addDisposableTo(disposeBag)

        Observable.combineLatest(viewsCount.asObservable(), favouritesCount.asObservable(), productCreationDate.asObservable()) {
                $0.0 > Constants.minimumStatsCountToShow || $0.1 > Constants.minimumStatsCountToShow || $0.2 != nil
            }.subscribeNext { [weak self] visible in
                self?.statsViewVisible.value = visible
        }.addDisposableTo(disposeBag)

        myUserRepository.rx_myUser.asObservable().bindNext { [weak self] _ in
            self?.refreshStatus()
        }.addDisposableTo(disposeBag)

        status.asObservable().filter{ $0 == .OtherAvailable }.bindNext { [weak self] _ in
            self?.refreshDirectChats()
        }.addDisposableTo(disposeBag)

        productIsFavoriteable.asObservable().bindNext { [weak self] favoriteable in
            self?.favoriteButtonState.value = favoriteable ? .Enabled : .Hidden
        }.addDisposableTo(disposeBag)

        moreInfoState.asObservable().map { (state: MoreInfoState) in
            return state == .Shown
        }.distinctUntilChanged().bindNext { [weak self] shown in
            self?.refreshNavBarButtons()
        }.addDisposableTo(disposeBag)
    }
    
    private func distanceString(product: Product) -> String? {
        guard let userLocation = locationManager.currentLocation?.location else { return nil }
        let distance = product.location.distanceTo(userLocation)
        let distanceString = String(format: "%0.1f %@", arguments: [distance, DistanceType.systemDistanceType().string])
        return LGLocalizedString.productDistanceXFromYou(distanceString)
    }

    private func refreshStatus() {
        let productStatus = product.value.viewModelStatus
        if let templates = commercializerAvailableTemplatesCount {
            status.value = productStatus.setCommercializable(templates > 0 && commercializerIsAvailable)
        } else {
            status.value = productStatus
        }
    }

    private func refreshDirectChats() {
        guard FeatureFlags.directStickersOnProduct else { return }
        stickersRepository.show(typeFilter: .Product) { [weak self] result in
            guard let stickers = result.value else { return }
            self?.selectableStickers = stickers
            self?.stickersButtonEnabled.value = !stickers.isEmpty && FeatureFlags.directStickersOnProduct
        }
    }
}


// MARK: - Public actions

extension ProductViewModel {

    func openProductOwnerProfile() {
        let data = UserDetailData.UserAPI(user: product.value.user, source: .ProductDetail)
        navigator?.openUser(data)
    }

    func markSold() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in

            var alertActions: [UIAction] = []
            let markAsSoldAction = UIAction(interface: .Text(LGLocalizedString.productMarkAsSoldConfirmOkButton),
                action: { [weak self] in
                    self?.markSold(.MarkAsSold)
                })
            alertActions.append(markAsSoldAction)
            self?.delegate?.vmShowAlert( LGLocalizedString.productMarkAsSoldConfirmTitle,
                message: LGLocalizedString.productMarkAsSoldConfirmMessage,
                cancelLabel: LGLocalizedString.productMarkAsSoldConfirmCancelButton,
                actions: alertActions)

            }, source: .MarkAsSold)
    }

    func resell() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in

            var alertActions: [UIAction] = []
            let sellAgainAction = UIAction(interface: .Text(LGLocalizedString.productSellAgainConfirmOkButton),
                action: { [weak self] in
                    self?.markUnsold()
                })
            alertActions.append(sellAgainAction)
            self?.delegate?.vmShowAlert(LGLocalizedString.productSellAgainConfirmTitle,
                message: LGLocalizedString.productSellAgainConfirmMessage,
                cancelLabel: LGLocalizedString.productSellAgainConfirmCancelButton,
                actions: alertActions)

            }, source: .MarkAsUnsold)
    }

    func chatWithSeller(source: EventParameterTypePage) {
        trackHelper.trackChatWithSeller(source)
        openChat()
    }

    func sendDirectMessage(message: String?) {
        delegate?.vmShowLoading(LGLocalizedString.productChatDirectMessageSending)

        let text = message ?? LGLocalizedString.productChatDirectMessage(product.value.user.name ?? "")
        chatWrapper.sendMessageForProduct(product.value, text: text, sticker: nil, type: .Text) { [weak self] result in
            if let _ = result.value {
                self?.trackHelper.trackDirectMessageSent()
                self?.delegate?.vmHideLoading(LGLocalizedString.productChatWithSellerSendOk, afterMessageCompletion: nil)
            } else if let error = result.error {
                switch error {
                case .Forbidden:
                    self?.delegate?.vmHideLoading(LGLocalizedString.productChatDirectErrorBlockedUserMessage, afterMessageCompletion: nil)
                case .Network, .Internal, .NotFound, .Unauthorized, .TooManyRequests, .UserNotVerified:
                    self?.delegate?.vmHideLoading(LGLocalizedString.chatSendErrorGeneric, afterMessageCompletion: nil)
                }
            }
        }
    }

    func openVideo() {
        guard let commercializers = commercializers.value else { return }

        let readyCommercializers = commercializers.filter {$0.status == .Ready }

        guard let commercialDisplayVM = CommercialDisplayViewModel(commercializers: readyCommercializers,
                                                                   productId: product.value.objectId,
                                                                   source: .ProductDetail,
                                                                   isMyVideo: product.value.isMine) else { return }
        delegate?.vmOpenCommercialDisplay(commercialDisplayVM)
    }

    func promoteProduct() {
        promoteProduct(.ProductDetail)
    }
    
    func reportProduct() {
        guard !product.value.isMine else { return }
        reportAction()
    }

    func stickersButton() {
        guard !selectableStickers.isEmpty else { return }
        delegate?.vmOpenStickersSelector(selectableStickers)
    }

    func sendSticker(sticker: Sticker) {
        ifLoggedInRunActionElseOpenChatSignup { [weak self] in
            self?.sendStickerToSeller(sticker)
        }
    }

    func switchFavorite() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
            self?.switchFavoriteAction()
        }, source: .Favourite)
    }

    func refreshInterestedBubble(fromFavoriteAction: Bool) {
        // check that the bubble hasn't been shown yet for this product
        guard let productId = product.value.objectId where shouldShowInterestedBubbleForProduct(productId) else { return }
        guard product.value.viewModelStatus == .OtherAvailable else { return }
        // we need at least 1 favorited without counting ours but when coming from favorite action,
        // favourites count is not updated, so no need to substract 1)
        let othersFavCount = min(isFavorite.value && !fromFavoriteAction ? favouritesCount.value - 1 : favouritesCount.value, 5)
        guard othersFavCount > 0 else { return }
        let othersFavText = othersFavCount == 1 ? LGLocalizedString.productBubbleOneUserInterested :
            String(format: LGLocalizedString.productBubbleSeveralUsersInterested, Int(othersFavCount))
        interestedBubbleTitle = othersFavText
        interestedBubbleIcon = UIImage(named: "ic_user_interested")
        showInterestedBubble.value = true
        // save that the bubble has just been shown for this product
        showInterestedBubbleForProduct(productId)
        trackHelper.trackInterestedUsersBubble(othersFavCount, productId: productId)
        showInterestedBubble.value = false
    }
}


// MARK: - Private
// MARK: - Chat button Actions

extension ProductViewModel {
    private func openChat() {
        navigator?.openProductChat(product.value)
    }
}


// MARK: - Commercializer

extension ProductViewModel {
    private func numberOfCommercializerTemplates() -> Int {
        guard let countryCode = product.value.postalAddress.countryCode else { return 0 }
        return commercializerRepository.templatesForCountryCode(countryCode).count
    }

    private var commercializerIsAvailable: Bool {
        return numberOfCommercializerTemplates() > 0
    }

    private func promoteProduct(source: PromotionSource) {
        let theProduct = product.value
        if let countryCode = theProduct.postalAddress.countryCode, let productId = theProduct.objectId {
            let themes = commercializerRepository.templatesForCountryCode(countryCode) ?? []
            let commercializersArr = commercializers.value ?? []
            guard let promoteProductVM = PromoteProductViewModel(productId: productId,
                                                                 themes: themes, commercializers: commercializersArr, promotionSource: .ProductDetail) else { return }
            trackHelper.trackCommercializerStart()
            delegate?.vmOpenPromoteProduct(promoteProductVM)
        }
    }
}


// MARK: - Helper Navbar

extension ProductViewModel {

    private func refreshNavBarButtons() {
        navBarButtons.value = buildNavBarButtons()
    }

    private func buildNavBarButtons() -> [UIAction] {
        var navBarButtons = [UIAction]()

        let isEditable: Bool
        switch status.value {
        case .Pending, .PendingAndCommercializable, .Available, .AvailableAndCommercializable, .OtherAvailable:
            isEditable = product.value.isMine
        case .NotAvailable, .Sold, .OtherSold:
            isEditable = false
        }

        if productIsFavoriteable.value && moreInfoState.value == .Shown {
            navBarButtons.append(buildFavoriteNavBarAction())
        }
        if isEditable {
            navBarButtons.append(buildEditNavBarAction())
        }

        navBarButtons.append(buildMoreNavBarAction())
        return navBarButtons
    }

    private func buildFavoriteNavBarAction() -> UIAction {
        let icon = UIImage(named: isFavorite.value ? "navbar_fav_on" : "navbar_fav_off")?
            .imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            self?.ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
                self?.switchFavoriteAction()
                }, source: .Favourite)
            }, accessibilityId: .ProductCarouselNavBarFavoriteButton)
    }

    private func buildEditNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_edit")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigator?.editProduct(strongSelf.product.value) { [weak self] product in
                self?.product.value = product
            }
        }, accessibilityId: .ProductCarouselNavBarEditButton)
    }

    private func buildMoreNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_more")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in self?.showOptionsMenu() },
                        accessibilityId: .ProductCarouselNavBarActionsButton)
    }

    private func showOptionsMenu() {
        var actions = [UIAction]()
        let isMine = product.value.isMine
        let isDeletable = status.value == .NotAvailable ? false : isMine

        actions.append(buildShareAction())
        if productHasReadyCommercials.value {
            actions.append(buildCommercialAction())
        }
        actions.append(buildOnboardingButton())
        if !isMine {
            actions.append(buildReportButton())
        }
        if isDeletable {
            actions.append(buildDeleteButton())
        }
        delegate?.vmShowProductDelegateActionSheet(LGLocalizedString.commonCancel, actions: actions)
    }

    private func buildShareAction() -> UIAction {
        return UIAction(interface: .Text(LGLocalizedString.productOptionShare), action: { [weak self] in
            guard let strongSelf = self, socialMessage = strongSelf.socialMessage.value else { return }
            strongSelf.delegate?.vmShowNativeShare(socialMessage)
            }, accessibilityId: .ProductCarouselNavBarShareButton)
    }

    private func buildCommercialAction() -> UIAction {
        return UIAction(interface: .Text(LGLocalizedString.productOptionShowCommercial), action: { [weak self] in
            self?.openVideo()
        })
    }

    private func buildReportButton() -> UIAction {
        let title = LGLocalizedString.productReportProductButton
        return UIAction(interface: .Text(title), action: reportAction)
    }
    
    private func reportAction() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] () -> () in
            guard let strongSelf = self else { return }
            
            let alertOKAction = UIAction(interface: .Text(LGLocalizedString.commonYes),
                action: { [weak self] in
                    self?.ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
                        self?.report()
                        }, source: .ReportFraud)
                    
                })
            strongSelf.delegate?.vmShowAlert(LGLocalizedString.productReportConfirmTitle,
                message: LGLocalizedString.productReportConfirmMessage,
                cancelLabel: LGLocalizedString.commonNo,
                actions: [alertOKAction])
            }, source: .ReportFraud)
    }
    
    private func buildDeleteButton() -> UIAction {
        let title = LGLocalizedString.productDeleteConfirmTitle
        return UIAction(interface: .Text(title), action: { [weak self] in
            guard let strongSelf = self else { return }

            let message: String
            var alertActions = [UIAction]()
            if strongSelf.suggestMarkSoldWhenDeleting {
                message = LGLocalizedString.productDeleteConfirmMessage

                let soldAction = UIAction(interface: .Text(LGLocalizedString.productDeleteConfirmSoldButton),
                    action: { [weak self] in
                        self?.markSold(.Delete)
                    })
                alertActions.append(soldAction)

                let deleteAction = UIAction(interface: .Text(LGLocalizedString.productDeleteConfirmOkButton),
                    action: { [weak self] in
                        self?.delete()
                    })
                alertActions.append(deleteAction)
            } else {
                message = LGLocalizedString.productDeleteSoldConfirmMessage

                let deleteAction = UIAction(interface: .Text(LGLocalizedString.commonOk),
                    action: { [weak self] in
                        self?.delete()
                    })
                alertActions.append(deleteAction)
            }

            strongSelf.delegate?.vmShowAlert(LGLocalizedString.productDeleteConfirmTitle, message: message,
                cancelLabel: LGLocalizedString.productDeleteConfirmCancelButton,
                actions: alertActions)
            })
    }
    
    private func buildOnboardingButton() -> UIAction {
        let title = LGLocalizedString.productOnboardingShowAgainButtonTitle
        return UIAction(interface: .Text(title), action: { [weak self] in
            KeyValueStorage.sharedInstance[.didShowProductDetailOnboarding] = false
            self?.delegate?.vmShowOnboarding()
        })
    }

    private var socialShareMessage: SocialMessage {
        return SocialHelper.socialMessageWithProduct(product.value)
    }

    private var suggestMarkSoldWhenDeleting: Bool {
        switch product.value.status {
        case .Pending, .Discarded, .Sold, .SoldOld, .Deleted:
            return false
        case .Approved:
            return true
        }
    }
}


// MARK: - Private actions

extension ProductViewModel {
    private func switchFavoriteAction() {
        favoriteButtonState.value = .Disabled
        if isFavorite.value {
            productRepository.deleteFavorite(product.value) { [weak self] result in
                guard let strongSelf = self else { return }
                if let product = result.value {
                    strongSelf.isFavorite.value = product.favorite
                }
                strongSelf.favoriteButtonState.value = .Enabled
            }
        } else {
            productRepository.saveFavorite(product.value) { [weak self] result in
                guard let strongSelf = self else { return }
                if let product = result.value {
                    strongSelf.isFavorite.value = product.favorite
                    self?.trackHelper.trackSaveFavoriteCompleted()

                    if RatingManager.sharedInstance.shouldShowRating {
                        strongSelf.delegate?.vmAskForRating()
                    }
                }
                strongSelf.favoriteButtonState.value = .Enabled
                strongSelf.refreshInterestedBubble(true)
            }
        }
    }

    private func report() {
        if isReported.value {
            delegate?.vmHideLoading(LGLocalizedString.productReportedSuccessMessage, afterMessageCompletion: nil)
            return
        }
        delegate?.vmShowLoading(LGLocalizedString.productReportingLoadingMessage)

        productRepository.saveReport(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            var message: String? = nil
            if let _ = result.value {
                strongSelf.isReported.value = true
                message = LGLocalizedString.productReportedSuccessMessage
                self?.trackHelper.trackReportCompleted()
            } else if let _ = result.error {
                message = LGLocalizedString.productReportedErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    private func delete() {
        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        trackHelper.trackDeleteStarted()

        productRepository.delete(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            var message: String? = nil
            if let value = result.value {
                strongSelf.product.value = value
                message = LGLocalizedString.productDeleteSuccessMessage
                self?.trackHelper.trackDeleteCompleted()
            } else if let _ = result.error {
                message = LGLocalizedString.productDeleteSendErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: { () -> () in
                strongSelf.delegate?.vmPop()
            })
        }
    }

    private func markSold(source: EventParameterSellSourceValue) {
        delegate?.vmShowLoading(nil)

        productRepository.markProductAsSold(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            var markAsSoldCompletion: (()->())? = nil

            let message: String
            if let value = result.value {
                strongSelf.product.value = value
                message = LGLocalizedString.productMarkAsSoldSuccessMessage
                self?.trackHelper.trackMarkSoldCompleted(source)
                markAsSoldCompletion = {
                    if RatingManager.sharedInstance.shouldShowRating {
                        strongSelf.delegate?.vmAskForRating()
                    }
                }

            } else {
                message = LGLocalizedString.productMarkAsSoldErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: markAsSoldCompletion)
        }
    }

    private func markUnsold() {
        delegate?.vmShowLoading(nil)

        productRepository.markProductAsUnsold(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            let message: String
            if let value = result.value {
                strongSelf.product.value = value
                message = LGLocalizedString.productSellAgainSuccessMessage
                self?.trackHelper.trackMarkUnsoldCompleted()
            } else {
                message = LGLocalizedString.productSellAgainErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    private func sendStickerToSeller(sticker: Sticker) {
        // Optimistic behavior
        let message = LocalMessage(sticker: sticker, userId: myUserRepository.myUser?.objectId)
        let messageView = chatViewMessageAdapter.adapt(message)
        directChatMessages.insert(messageView, atIndex: 0)

        chatWrapper.sendMessageForProduct(product.value, text: sticker.name, sticker: sticker, type: .Sticker) {
            [weak self] result in
            if let _ = result.value {
                self?.trackHelper.trackDirectStickerSent()
            } else if let error = result.error {
                switch error {
                case .Forbidden:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.productChatDirectErrorBlockedUserMessage, completion: nil)
                case .Network, .Internal, .NotFound, .Unauthorized, .TooManyRequests, .UserNotVerified:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.chatSendErrorGeneric, completion: nil)
                }

                //Removing in case of failure
                if let indexToRemove = self?.directChatMessages.value.indexOf({ $0.objectId == messageView.objectId }) {
                    self?.directChatMessages.removeAtIndex(indexToRemove)
                }
            }
        }
    }
}


// MARK: - UpdateDetailInfoDelegate

extension ProductViewModel {
    private func ifLoggedInRunActionElseOpenMainSignUp(action: () -> (), source: EventParameterLoginSourceValue) {
        if Core.sessionManager.loggedIn {
            action()
        } else {
            let signUpVM = SignUpViewModel(source: source)
            delegate?.vmOpenMainSignUp(signUpVM, afterLoginAction: { action() })
        }
    }

    private func ifLoggedInRunActionElseOpenChatSignup(action: () -> ()) {
        delegate?.ifLoggedInThen(.DirectSticker, loginStyle: .Popup(LGLocalizedString.chatLoginPopupText),
                                 loggedInAction: action, elsePresentSignUpWithSuccessAction: action)
    }
}


// MARK : - Product

extension Product {
    private var viewModelStatus: ProductViewModelStatus {
        switch status {
        case .Pending:
            return isMine ? .Pending : .NotAvailable
        case .Discarded, .Deleted:
            return .NotAvailable
        case .Approved:
            return isMine ? .Available : .OtherAvailable
        case .Sold, .SoldOld:
            return isMine ? .Sold : .OtherSold
        }
    }

    var isMine: Bool {
        let myUserId = Core.myUserRepository.myUser?.objectId
        let ownerId = user.objectId
        guard user.objectId != nil && myUserId != nil else { return false }
        return ownerId == myUserId
    }
}

// MARK: - Interested Bubble logic

extension ProductViewModel {
    func showInterestedBubbleForProduct(id: String) {
        interestedBubbleManager.showInterestedBubbleForProduct(id)
    }

    func shouldShowInterestedBubbleForProduct(id: String) -> Bool {
        return interestedBubbleManager.shouldShowInterestedBubbleForProduct(id)
    }
}

private extension ProductViewModelStatus {
    var string: String? {
        switch self {
        case .Sold, .OtherSold:
            return LGLocalizedString.productListItemSoldStatusLabel
        case .Pending, .PendingAndCommercializable, .Available, .AvailableAndCommercializable, .OtherAvailable,
             .NotAvailable:
            return nil
        }
    }

    var labelColor: UIColor {
        switch self {
        case .Sold, .OtherSold:
            return UIColor.whiteColor()
        case .Pending, .PendingAndCommercializable, .Available, .AvailableAndCommercializable, .OtherAvailable,
             .NotAvailable:
            return UIColor.clearColor()
        }
    }

    var bgColor: UIColor {
        switch self {
        case .Sold, .OtherSold:
            return UIColor.soldColor
        case .Pending, .PendingAndCommercializable, .Available, .AvailableAndCommercializable, .OtherAvailable,
             .NotAvailable:
            return UIColor.clearColor()
        }
    }

    func setCommercializable(active: Bool) -> ProductViewModelStatus {
        switch self {
        case .Pending, .PendingAndCommercializable:
            return active ? .PendingAndCommercializable : .Pending
        case .Available, .AvailableAndCommercializable:
            return active ? .AvailableAndCommercializable : .Available
        case .Sold, .OtherSold, .NotAvailable, .OtherAvailable:
            return self
        }
    }
}
