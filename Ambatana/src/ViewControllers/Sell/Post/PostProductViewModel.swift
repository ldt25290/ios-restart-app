//
//  PostProductViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol PostProductViewModelDelegate: BaseViewModelDelegate {
    func postProductviewModel(viewModel: PostProductViewModel, shouldAskLoginWithCompletion completion: () -> Void)
}

enum PostingSource {
    case TabBar
    case SellButton
    case DeepLink
    case OnboardingButton
    case OnboardingCamera
    case Notifications
}

enum PostProductState {
    case ImageSelection
    case UploadingImage
    case ErrorUpload(message: String)
    case DetailsSelection
}


class PostProductViewModel: BaseViewModel {

    weak var delegate: PostProductViewModelDelegate?
    weak var navigator: PostProductNavigator?

    var usePhotoButtonText: String {
        if Core.sessionManager.loggedIn {
            return LGLocalizedString.productPostUsePhoto
        } else {
            return LGLocalizedString.productPostUsePhotoNotLogged
        }
    }
    var confirmationOkText: String {
        if Core.sessionManager.loggedIn {
            return LGLocalizedString.productPostProductPosted
        } else {
            return LGLocalizedString.productPostProductPostedNotLogged
        }
    }

    let state = Variable<PostProductState>(.ImageSelection)

    let postDetailViewModel: PostProductDetailViewModel
    let postProductCameraViewModel: PostProductCameraViewModel
    let postingSource: PostingSource
    
    private let productRepository: ProductRepository
    private let fileRepository: FileRepository
    private let tracker: Tracker
    private let commercializerRepository: CommercializerRepository
    let galleryMultiSelectionEnabled: Bool
    private var imagesSelected: [UIImage]?
    private var pendingToUploadImages: [UIImage]?
    private var uploadedImages: [File]?
    private var uploadedImageSource: EventParameterPictureSource?
    

    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        let productRepository = Core.productRepository
        let fileRepository = Core.fileRepository
        let commercializerRepository = Core.commercializerRepository
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(source: source, productRepository: productRepository, fileRepository: fileRepository,
                  commercializerRepository: commercializerRepository, tracker: tracker,
                  galleryMultiSelectionEnabled: featureFlags.postingMultiPictureEnabled)
    }

    init(source: PostingSource, productRepository: ProductRepository, fileRepository: FileRepository,
         commercializerRepository: CommercializerRepository, tracker: Tracker, galleryMultiSelectionEnabled: Bool) {
        self.postingSource = source
        self.productRepository = productRepository
        self.fileRepository = fileRepository
        self.commercializerRepository = commercializerRepository
        self.postDetailViewModel = PostProductDetailViewModel()
        self.postProductCameraViewModel = PostProductCameraViewModel(postingSource: source)
        self.tracker = tracker
        self.galleryMultiSelectionEnabled = galleryMultiSelectionEnabled
        super.init()
        self.postDetailViewModel.delegate = self
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        guard firstTime else { return }
        trackVisit()
    }

    // MARK: - Public methods
   
    func retryButtonPressed() {
        guard let images = imagesSelected, source = uploadedImageSource else { return }
        imagesSelected(images, source: source)
    }

    func imagesSelected(images: [UIImage], source: EventParameterPictureSource) {
        uploadedImageSource = source
        imagesSelected = images
        guard Core.sessionManager.loggedIn else {
            pendingToUploadImages = images
            state.value = .DetailsSelection
            return
        }

        state.value = .UploadingImage

        fileRepository.upload(images, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let images = result.value else {
                guard let error = result.error else { return }
                let errorString: String
                switch (error) {
                case .Internal, .Unauthorized, .NotFound, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError:
                    errorString = LGLocalizedString.productPostGenericError
                case .Network:
                    errorString = LGLocalizedString.productPostNetworkError
                }
                strongSelf.state.value = .ErrorUpload(message: errorString)
                return
            }
            strongSelf.uploadedImages = images
            strongSelf.state.value = .DetailsSelection
        }
    }

    func closeButtonPressed() {
        if pendingToUploadImages != nil {
            openPostAbandonAlertNotLoggedIn()
        } else {
            guard let product = buildProduct(isFreePosting: false), images = uploadedImages else {
                navigator?.cancelPostProduct()
                return
            }
            let trackingInfo = PostProductTrackingInfo(buttonName: .Close, sellButtonPosition: postingSource.sellButtonPosition,
                                                       imageSource: uploadedImageSource, price: nil)
            navigator?.closePostProductAndPostInBackground(product, images: images, showConfirmation: false,
                                                           trackingInfo: trackingInfo)
        }
    }
}


// MARK: - PostProductDetailViewModelDelegate

extension PostProductViewModel: PostProductDetailViewModelDelegate {
    func postProductDetailDone(viewModel: PostProductDetailViewModel) {
        postProduct()
    }
}


// MARK: - Private methods

private extension PostProductViewModel {
    func openPostAbandonAlertNotLoggedIn() {
        let title = LGLocalizedString.productPostCloseAlertTitle
        let message = LGLocalizedString.productPostCloseAlertDescription
        let cancelAction = UIAction(interface: .Text(LGLocalizedString.productPostCloseAlertCloseButton), action: { [weak self] in
            self?.navigator?.cancelPostProduct()
        })
        let postAction = UIAction(interface: .Text(LGLocalizedString.productPostCloseAlertOkButton), action: { [weak self] in
            self?.postProduct()
        })
        delegate?.vmShowAlert(title, message: message, actions: [cancelAction, postAction])
    }

    func postProduct() {
        let trackingInfo = PostProductTrackingInfo(buttonName: .Done, sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource, price: postDetailViewModel.price.value)
        if Core.sessionManager.loggedIn {
            guard let product = buildProduct(isFreePosting: false), images = uploadedImages else { return }
            navigator?.closePostProductAndPostInBackground(product, images: images, showConfirmation: true,
                                                           trackingInfo: trackingInfo)
        } else if let images = pendingToUploadImages {
            delegate?.postProductviewModel(self, shouldAskLoginWithCompletion: { [weak self] in
                guard let product = self?.buildProduct(isFreePosting:false) else { return }
                self?.navigator?.closePostProductAndPostLater(product, images: images, trackingInfo: trackingInfo)
                })
        } else {
            navigator?.cancelPostProduct()
        }
    }

    func buildProduct(isFreePosting isFreePosting: Bool) -> Product? {
        let price = isFreePosting ? ProductPrice.Free : postDetailViewModel.productPrice
        let title = postDetailViewModel.productTitle
        let description = postDetailViewModel.productDescription
        return productRepository.buildNewProduct(title, description: description, price: price, category: .Unassigned)
    }
}


// MARK: - Tracking

private extension PostProductViewModel {
    func trackVisit() {
        let event = TrackerEvent.productSellStart(postingSource.typePage,buttonName: postingSource.buttonName,
                                                  sellButtonPosition: postingSource.sellButtonPosition)
        tracker.trackEvent(event)
    }
}

extension PostingSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .TabBar, .SellButton:
            return .Sell
        case .DeepLink:
            return .External
        case .OnboardingButton, .OnboardingCamera:
            return .Onboarding
        case .Notifications:
            return .Notifications
        }
    }

    var buttonName: EventParameterButtonNameType? {
        switch self {
        case .TabBar, .SellButton, .DeepLink, .Notifications:
            return nil
        case .OnboardingButton:
            return .SellYourStuff
        case .OnboardingCamera:
            return .StartMakingCash
        }
    }
    var sellButtonPosition: EventParameterSellButtonPosition {
        switch self {
        case .TabBar:
            return .TabBar
        case .SellButton:
            return .FloatingButton
        case .OnboardingButton, .OnboardingCamera, .DeepLink, .Notifications:
            return .None
        }
    }
}
