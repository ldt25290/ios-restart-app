//
//  PostProductViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol PostProductViewModelDelegate: class {
    func postProductViewModelDidStartUploadingImage(viewModel: PostProductViewModel)
    func postProductViewModelDidFinishUploadingImage(viewModel: PostProductViewModel, error: String?)
    func postProductviewModelshouldClose(viewModel: PostProductViewModel, animated: Bool, completion: (() -> Void)?)
    func postProductviewModel(viewModel: PostProductViewModel, shouldAskLoginWithCompletion completion: () -> Void)
}

enum PostingSource {
    case AppStart, SellButton, DeepLink

    var forceCamera: Bool {
        switch self {
        case .AppStart:
            return true
        case .SellButton, .DeepLink:
            return false
        }
    }
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
    var currency: Currency? {
        guard let countryCode = locationManager.currentPostalAddress?.countryCode else { return nil }
        return currencyHelper.currencyWithCountryCode(countryCode)
    }

    private let postingSource: PostingSource
    private let productRepository: ProductRepository
    private let fileRepository: FileRepository
    private let commercializerRepository: CommercializerRepository
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper
    private var imageSelected: UIImage?
    private var pendingToUploadImage: UIImage?
    private var uploadedImage: File?
    private var uploadedImageSource: EventParameterPictureSource?


    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        let productRepository = Core.productRepository
        let fileRepository = Core.fileRepository
        let commercializerRepository = Core.commercializerRepository
        let locationManager = Core.locationManager
        let currencyHelper = Core.currencyHelper
        self.init(source: source, productRepository: productRepository, fileRepository: fileRepository,
            commercializerRepository: commercializerRepository, locationManager: locationManager,
            currencyHelper: currencyHelper)
    }

    init(source: PostingSource, productRepository: ProductRepository, fileRepository: FileRepository,
         commercializerRepository: CommercializerRepository, locationManager: LocationManager,
         currencyHelper: CurrencyHelper) {
        self.postingSource = source
        self.productRepository = productRepository
        self.fileRepository = fileRepository
        self.commercializerRepository = commercializerRepository
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        super.init()
    }


    // MARK: - Public methods

    func onViewLoaded() {
        let event = TrackerEvent.productSellStart(postingSource.typePage)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func retryButtonPressed() {
        guard let image = imageSelected, source = uploadedImageSource else { return }
        imageSelected(image, source: source)
    }

    func imageSelected(image: UIImage, source: EventParameterPictureSource) {
        uploadedImageSource = source
        imageSelected = image
        guard Core.sessionManager.loggedIn else {
            pendingToUploadImage = image
            self.delegate?.postProductViewModelDidFinishUploadingImage(self, error: nil)
            return
        }

        delegate?.postProductViewModelDidStartUploadingImage(self)

        fileRepository.upload(image, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let image = result.value else {
                guard let error = result.error else { return }
                let errorString: String
                switch (error) {
                case .Internal, .Unauthorized, .NotFound, .Forbidden, .TooManyRequests, .UserNotVerified:
                    errorString = LGLocalizedString.productPostGenericError
                case .Network:
                    errorString = LGLocalizedString.productPostNetworkError
                }
                strongSelf.delegate?.postProductViewModelDidFinishUploadingImage(strongSelf, error: errorString)
                return
            }
            strongSelf.uploadedImage = image

            strongSelf.delegate?.postProductViewModelDidFinishUploadingImage(strongSelf, error: nil)
        }
    }

    func shouldShowCloseAlert() -> Bool {
        return pendingToUploadImage != nil
    }

    func doneButtonPressed(priceText priceText: String?) {
        let trackingInfo = PostProductTrackingInfo(buttonName: .Done, imageSource: uploadedImageSource,
                                                   price: priceText)
        if Core.sessionManager.loggedIn {
            guard let product = buildProduct(priceText: priceText), image = uploadedImage else { return }
            navigator?.closeAndPost(product, images: [image], showConfirmation: true, trackingInfo: trackingInfo)
        } else if let image = pendingToUploadImage {
            navigator?.closeAndPost(priceText: priceText, image: image, trackingInfo: trackingInfo)
        }
    }

    func closeButtonPressed() {
        let priceText: String? = nil
        guard let product = buildProduct(priceText: priceText), image = uploadedImage else {
            navigator?.cancel()
            return
        }

        let trackingInfo = PostProductTrackingInfo(buttonName: .Close, imageSource: uploadedImageSource,
                                                   price: priceText)
        navigator?.closeAndPost(product, images: [image], showConfirmation: false, trackingInfo: trackingInfo)
    }


    // MARK: - Private methods

    private func buildProduct(priceText priceText: String?) -> Product? {
        let priceText = priceText ?? "0"
        let price = priceText.toPriceDouble()
        return productRepository.buildNewProduct(price: price)
    }
}

extension PostingSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .AppStart:
            return .OpenApp
        case .SellButton:
            return .Sell
        case .DeepLink:
            return .External
        }
    }
}
