//
//  EditProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift

enum ProductCreateValidationError: String, ErrorType {
    case Network = "network"
    case Internal = "internal"
    case NoImages = "no images present"
    case NoTitle  = "no title"
    case NoPrice = "invalid price"
    case NoDescription = "no description"
    case LongDescription = "description too long"
    case NoCategory = "no category selected"
    
    init(repoError: RepositoryError) {
        switch repoError {
        case .Internal:
            self = .Internal
        case .Network:
            self = .Network
        case .NotFound, .Forbidden, .Unauthorized, .TooManyRequests, .UserNotVerified:
            self = .Internal
        }
    }
}

enum TitleDisclaimerStatus {
    case Completed  // title autogenerated and selected
    case Ready      // no title yet, just received an autogenerated one
    case Loading    // no title, waiting for response
    case Clean      // user edits title
}

protocol EditProductViewModelDelegate : BaseViewModelDelegate {
    func vmDidSelectCategoryWithName(categoryName: String)
    func vmDidStartSavingProduct()
    func vmDidUpdateProgressWithPercentage(percentage: Float)
    func vmDidFinishSavingProductWithResult(result: ProductResult)
    func vmShouldUpdateDescriptionWithCount(count: Int)
    func vmDidAddOrDeleteImage()
    func vmDidFailWithError(error: ProductCreateValidationError)
    func vmFieldCheckSucceeded()
    func vmShouldOpenMapWithViewModel(locationViewModel: EditLocationViewModel)
}

protocol UpdateDetailInfoDelegate : class {
    func updateDetailInfo(viewModel: EditProductViewModel, withSavedProduct: Product)
    func updateDetailInfo(viewModel: EditProductViewModel, withInitialProduct: Product)
}

enum EditProductImageType {
    case Local(image: UIImage)
    case Remote(file: File)
}

class ProductImages {
    var images: [EditProductImageType] = []
    var localImages: [UIImage] {
        return images.flatMap {
            switch $0 {
            case .Local(let image):
                return image
            case .Remote:
                return nil
            }
        }
    }
    var remoteImages: [File] {
        return images.flatMap {
            switch $0 {
            case .Local:
                return nil
            case .Remote(let file):
                return file
            }
        }
    }

    func append(image: UIImage) {
        images.append(.Local(image: image))
    }

    func append(file: File) {
        images.append(.Remote(file: file))
    }

    func removeAtIndex(index: Int) {
        images.removeAtIndex(index)
    }
}

class EditProductViewModel: BaseViewModel, EditLocationDelegate {

    // real time cloudsight
    let proposedTitle = Variable<String>("")
    let titleDisclaimerStatus = Variable<TitleDisclaimerStatus>(.Completed)
    private var userIsEditingTitle: Bool
    private var hasTitle: Bool {
        return (title != nil && title != "")
    }
    private var productIsNew: Bool {
        guard let creationDate = initialProduct.createdAt else { return true }
        return creationDate.isNewerThan(Constants.cloudsightTimeThreshold)
    }
    private var shouldAskForAutoTitle: Bool {
        // we ask for title if the product has less than 1h (or doesn't has creation date)
        // AND doesn't has one, or the user is editing the field
        return (!hasTitle || userIsEditingTitle) && productIsNew
    }
    private var requestTitleTimer: NSTimer?

    // Input
    var title: String?
    let titleAutogenerated = Variable<Bool>(false)
    let titleAutotranslated = Variable<Bool>(false)
    var currency: Currency?
    var price: String?
    var postalAddress: PostalAddress?
    var location: LGLocationCoordinates2D?
    var locationInfo = Variable<String>("")
    var category: ProductCategory?
    var shouldShareInFB: Bool

    var descr: String? {
        didSet {
            delegate?.vmShouldUpdateDescriptionWithCount(descriptionCharCount)
        }
    }
    
    var shouldTrack :Bool = true

    // Data
    var productImages: ProductImages
    var images: [EditProductImageType] {
        return productImages.images
    }
    var savedProduct: Product?
    
    // Managers
    let myUserRepository: MyUserRepository
    let productRepository: ProductRepository
    let locationManager: LocationManager
    let tracker: Tracker

    // Product info
    private var initialProduct: Product
    private var editedProduct: Product
    weak var updateDetailDelegate : UpdateDetailInfoDelegate?
    var promoteProductVM: PromoteProductViewModel?

    // Delegate
    weak var delegate: EditProductViewModelDelegate?

    // Rx
    let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle
    
    convenience init(product: Product) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let locationManager = Core.locationManager
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
                  locationManager: locationManager, tracker: tracker, product: product)
    }
    
    init(myUserRepository: MyUserRepository, productRepository: ProductRepository, locationManager: LocationManager,
         tracker: Tracker, product: Product) {
        self.myUserRepository = myUserRepository
        self.productRepository = productRepository
        self.locationManager = locationManager
        self.tracker = tracker
        
        self.initialProduct = product
        self.editedProduct = product

        self.title = product.title
        
        self.titleAutotranslated.value = product.isTitleAutoTranslated(Core.countryHelper)
        self.titleAutogenerated.value = product.isTitleAutoGenerated

        self.proposedTitle.value = product.nameAuto ?? product.title ?? ""
        self.userIsEditingTitle = false

        if let price = product.price {
            self.price = String.fromPriceDouble(price)
        }
        currency = product.currency
        if let descr = product.description {
            self.descr = descr
        }

        self.postalAddress = product.postalAddress
        self.location = product.location

        self.locationInfo.value = product.postalAddress.zipCodeCityString ?? ""

        category = product.category

        self.productImages = ProductImages()
        for file in product.images { productImages.append(file) }

        self.shouldShareInFB = myUserRepository.myUser?.facebookAccount != nil

        super.init()

        startTimer()
        trackStart()
    }
    
    
    // MARK: - methods

    func save() {
        updateProduct()
    }

    func updateProduct() {
        guard let category = category else {
            delegate?.vmDidFailWithError(.NoCategory)
            return
        }
        let name = title ?? ""
        let description = (descr ?? "").stringByRemovingEmoji()
        let priceAmount = (price ?? "0").toPriceDouble()
        let currency = editedProduct.currency

        editedProduct = productRepository.updateProduct(editedProduct, name: name, description: description,
                                                        price: priceAmount, currency: currency, location: location,
                                                        postalAddress: postalAddress, category: category)
        saveTheProduct(editedProduct, withImages: productImages)
    }


    // MARK: - Tracking methods

    func shouldEnableTracking() {
        shouldTrack = true
    }

    func shouldDisableTracking() {
        shouldTrack = false
    }

    internal func trackStart() {
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditStart(myUser, product: editedProduct)
        trackEvent(event)
    }
    
    internal func trackValidationFailedWithError(error: ProductCreateValidationError) {
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditFormValidationFailed(myUser, product: editedProduct, description: error.rawValue)
        trackEvent(event)
    }

    internal func trackSharedFB() {
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditSharedFB(myUser, product: savedProduct)
        trackEvent(event)
    }

    internal func trackComplete(product: Product) {
        self.editedProduct = product

        // if nothing is changed, we don't track the edition
        guard editedFields().count > 0  else { return }

        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditComplete(myUser, product: product, category: category,
                                                     editedFields: editedFields())
        trackEvent(event)
    }

    // MARK: - Tracking Private methods

    private func trackEvent(event: TrackerEvent) {
        if shouldTrack {
            tracker.trackEvent(event)
        }
    }

    private func editedFields() -> [EventParameterEditedFields] {

        var editedFields : [EventParameterEditedFields] = []

        if productImages.localImages.count > 0 || initialProduct.images.count != productImages.remoteImages.count  {
            editedFields.append(.Picture)
        }
        if initialProduct.name != editedProduct.name {
            editedFields.append(.Title)
        }
        if initialProduct.priceString() != editedProduct.priceString() {
            editedFields.append(.Price)
        }
        if initialProduct.descr != editedProduct.descr {
            editedFields.append(.Description)
        }
        if initialProduct.category != editedProduct.category {
            editedFields.append(.Category)
        }
        if shareInFbChanged() {
            editedFields.append(.Share)
        }

        return editedFields
    }

    private func shareInFbChanged() -> Bool {
        let fbLogin = myUserRepository.myUser?.facebookAccount != nil
        return fbLogin != shouldShareInFB
    }

    var numberOfImages: Int {
        return images.count
    }
    
    func imageAtIndex(index: Int) -> EditProductImageType {
        return images[index]
    }
    
    var numberOfCategories: Int {
        return ProductCategory.allValues().count
    }
    
    var categoryName: String? {
        return category?.name
    }
    
    var descriptionCharCount: Int {
        guard let descr = descr else { return Constants.productDescriptionMaxLength }
        return Constants.productDescriptionMaxLength-descr.characters.count
    }
    
    // fills action sheet
    func categoryNameAtIndex(index: Int) -> String {
        return ProductCategory.allValues()[index].name
    }
    
    // fills category field
    func selectCategoryAtIndex(index: Int) {
        category = ProductCategory(rawValue: index+1) //index from 0 to N and prodCat from 1 to N+1
        delegate?.vmDidSelectCategoryWithName(category?.name ?? "")
        
    }
    
    func appendImage(image: UIImage) {
        productImages.append(image)
        delegate?.vmDidAddOrDeleteImage()
    }

    func deleteImageAtIndex(index: Int) {
        productImages.removeAtIndex(index)
        delegate?.vmDidAddOrDeleteImage()
    }

    func checkProductFields() {
        let error = validate()
        if let actualError = error {
            delegate?.vmDidFailWithError(actualError)
            trackValidationFailedWithError(actualError)
        } else {
            delegate?.vmFieldCheckSucceeded()
        }
    }

    var fbShareContent: FBSDKShareLinkContent? {
        if let product = savedProduct {
            let title = LGLocalizedString.sellShareFbContent
            return SocialHelper.socialMessageWithTitle(title, product: product).fbShareContent
        }
        return nil
    }

    func openMap() {
        var shouldAskForPermission = true
        var permissionsActionBlock: ()->() = {}
        // check location enabled
        switch locationManager.locationServiceStatus {
        case let .Enabled(authStatus):
            switch authStatus {
            case .NotDetermined:
                shouldAskForPermission = true
                permissionsActionBlock = {  [weak self] in self?.locationManager.startSensorLocationUpdates() }
            case .Restricted, .Denied:
                shouldAskForPermission = true
                permissionsActionBlock = { [weak self] in self?.openLocationAppSettings() }
            case .Authorized:
                shouldAskForPermission = false
            }
        case .Disabled:
            shouldAskForPermission = true
            permissionsActionBlock = { [weak self] in self?.openLocationAppSettings() }
        }

        if shouldAskForPermission {
            // not enabled
            let okAction = UIAction(interface: UIActionInterface.Button(LGLocalizedString.commonOk,
                .Default), action: permissionsActionBlock)
            let alertIcon = UIImage(named: "ic_location_alert")
            delegate?.vmShowAlertWithTitle(LGLocalizedString.editProductLocationAlertTitle,
                                           text: LGLocalizedString.editProductLocationAlertText,
                                           alertType: .IconAlert(icon: alertIcon), actions: [okAction])
        } else {
            // enabled
            let initialPlace = Place(postalAddress: nil, location: locationManager.currentAutoLocation?.location)
            let locationVM = EditLocationViewModel(mode: .EditProductLocation, initialPlace: initialPlace)
            locationVM.locationDelegate = self
            delegate?.vmShouldOpenMapWithViewModel(locationVM)
        }
    }


    // MARK: - Private methods

    private func startTimer() {
        guard shouldAskForAutoTitle else { return }
        requestTitleTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.cloudsightRequestRepeatInterval, target: self,
                                                                   selector: #selector(getAutoGeneratedTitle),
                                                                   userInfo: nil, repeats: true)
        requestTitleTimer?.fire()
    }

    private func stopTimer() {
        requestTitleTimer?.invalidate()
    }

    private func rxBindings() {
        proposedTitle.asObservable().bindNext { [weak self] proposedTitle in
            guard let strongSelf = self else { return }
            if strongSelf.hasTitle {
                strongSelf.titleDisclaimerStatus.value =  .Completed
            } else if proposedTitle != "" {
                strongSelf.titleDisclaimerStatus.value =  .Ready
            } else if strongSelf.shouldAskForAutoTitle {
                strongSelf.titleDisclaimerStatus.value =  .Loading
            }
            strongSelf.titleDisclaimerStatus.value =  .Clean
        }.addDisposableTo(disposeBag)
    }

    private func validate() -> ProductCreateValidationError? {
        
        if images.count < 1 {
            return .NoImages
        } else if descriptionCharCount < 0 {
            return .LongDescription
        } else if category == nil {
            return .NoCategory
        }
        return nil
    }
    
    private func saveTheProduct(product: Product, withImages images: ProductImages) {
        
        delegate?.vmDidStartSavingProduct()
        
        let localImages = images.localImages
        let remoteImages = images.remoteImages
        
        let commonCompletion: ProductCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            if let actualProduct = result.value {
                strongSelf.savedProduct = actualProduct
                strongSelf.trackComplete(actualProduct)
                strongSelf.delegate?.vmDidFinishSavingProductWithResult(result)
            } else if let error = result.error {
                let newError = ProductCreateValidationError(repoError: error)
                strongSelf.delegate?.vmDidFailWithError(newError)
            }
        }
        
        if let _ = product.objectId {
            productRepository.update(product, oldImages: remoteImages, newImages: localImages, progress: nil, completion: commonCompletion)
        } else {
            if localImages.isEmpty {
                productRepository.create(product, images: remoteImages, completion: commonCompletion)
            } else {
                productRepository.create(product, images: localImages, progress: nil, completion: commonCompletion)
            }
        }
    }

    private func openLocationAppSettings() {
        guard let settingsURL = NSURL(string:UIApplicationOpenSettingsURLString) else { return }
        UIApplication.sharedApplication().openURL(settingsURL)
    }

    // MARK: - Update info of previous VC

    func updateInfoOfPreviousVCWithProduct(savedProduct: Product) {
        updateDetailDelegate?.updateDetailInfo(self, withSavedProduct: savedProduct)
    }

    func notifyPreviousVCEditCompleted() {
        updateDetailDelegate?.updateDetailInfo(self, withInitialProduct: initialProduct)
    }
}


// MARK: EditLocationDelegate

extension EditProductViewModel {
    func editLocationDidSelectPlace(place: Place) {
        location = place.location
        postalAddress = place.postalAddress
        locationInfo.value = place.postalAddress?.zipCodeCityString ?? ""
    }
}


// MARK: Cloudsight in real time


extension EditProductViewModel {
    dynamic func getAutoGeneratedTitle() {
        guard let productId = initialProduct.objectId where shouldAskForAutoTitle else {
            stopTimer()
            return
        }
        titleDisclaimerStatus.value = .Loading
        productRepository.retrieve(productId) { [weak self] result in
            if let value = result.value {
                guard let proposedTitle = value.nameAuto else { return }
                self?.stopTimer()
                self?.titleDisclaimerStatus.value = .Ready
                self?.proposedTitle.value = proposedTitle
            }
        }
    }

    /**
     Method called when the title textfield gets the focus
     */
    func userWritesTitle(text: String?) {
        guard productIsNew else { return }
        userIsEditingTitle = true
        titleAutotranslated.value = false
        titleAutogenerated.value = false
        titleDisclaimerStatus.value = proposedTitle.value.isEmpty ? .Loading : .Ready
    }

    func userFinishedEditingTitle(text: String) {
        guard productIsNew else { return }
        if text.isEmpty {
            titleLeftBlank()
        } else if text == proposedTitle.value {
            titleAutotranslated.value = true
            titleAutogenerated.value = true
            titleDisclaimerStatus.value = .Completed
        } else {
            titleAutotranslated.value = false
            titleAutogenerated.value = false
            titleDisclaimerStatus.value = proposedTitle.value.isEmpty ? .Loading : .Ready
        }
    }

    /**
     Method called when the title textfield loses the focus, and is empty
     */
    func titleLeftBlank() {
        guard productIsNew else { return }
        userIsEditingTitle = false
        titleDisclaimerStatus.value = proposedTitle.value.isEmpty ? .Loading : .Ready
    }

    /**
     Method called when the user presses the suggested title button
     */
    func userSelectedSuggestedTitle() {
        titleAutotranslated.value = true
        titleAutogenerated.value = true
        titleDisclaimerStatus.value = .Completed
    }
}
