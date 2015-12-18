//
//  SellProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result

protocol SellProductViewModelDelegate : class {
    func sellProductViewModel(viewModel: BaseSellProductViewModel, archetype: Bool)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, didSelectCategoryWithName categoryName: String)
    func sellProductViewModelDidStartSavingProduct(viewModel: BaseSellProductViewModel)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, didUpdateProgressWithPercentage percentage: Float)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, didFinishSavingProductWithResult
        result: ProductSaveServiceResult)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, shouldUpdateDescriptionWithCount count: Int)
    func sellProductViewModeldidAddOrDeleteImage(viewModel: BaseSellProductViewModel)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, didFailWithError error: ProductSaveServiceError)
    func sellProductViewModelFieldCheckSucceeded(viewModel: BaseSellProductViewModel)
}

enum SellProductImageType {
    case Local(image: UIImage)
    case Remote(file: File)

    static func localImages(list: [SellProductImageType]) -> [UIImage] {
        return list.flatMap { (item: SellProductImageType) -> UIImage? in
            switch item {
            case .Local(let image):
                return image
            case .Remote:
                return nil
            }
        }
    }

    static func remoteImages(list: [SellProductImageType]) -> [File] {
        return list.flatMap { (item: SellProductImageType) -> File? in
            switch item {
            case .Local:
                return nil
            case .Remote(let file):
                return file
            }
        }
    }
}

public class BaseSellProductViewModel: BaseViewModel {
    
    // Input
    var title: String?
    internal var currency: Currency
    var price: String?
    internal var category: ProductCategory?
    var shouldShareInFB: Bool

    // TODO: remove this flag for image modification tracking on update, and manage it properly @ coreKit
    var imagesModified: Bool

    var descr: String? {
        didSet {
            delegate?.sellProductViewModel(self, shouldUpdateDescriptionWithCount: descriptionCharCount)
        }
    }
    
    var shouldTrack :Bool = true

    // Data
    internal var images: [SellProductImageType]
    internal var savedProduct: Product?
    
    // Managers
    private let productManager: ProductManager
    
    // Delegate
    weak var delegate: SellProductViewModelDelegate?
    weak var editDelegate: EditSellProductViewModelDelegate?

    
    // MARK: - Lifecycle
    
    public override init() {
        self.title = nil
        self.currency = CurrencyHelper.sharedInstance.currentCurrency
        self.price = nil
        self.descr = nil
        self.category = nil
        self.images = []
        self.shouldShareInFB = MyUserManager.sharedInstance.myUser()?.didLogInByFacebook ?? true
        self.imagesModified = false
        self.productManager = ProductManager()
        
        super.init()
        
        trackStart()
    }
    
    
    // MARK: - Public methods
    
    public func shouldEnableTracking() {
        shouldTrack = true
    }

    public func shouldDisableTracking() {
        shouldTrack = false
    }

    internal func trackStart() { }
    
    internal func trackValidationFailedWithError(error: ProductSaveServiceError) { }

    internal func trackSharedFB() { }
    
    internal func trackComplete(product: Product) { }

    var numberOfImages: Int {
        return images.count
    }
    
    func imageAtIndex(index: Int) -> SellProductImageType {
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
    public func categoryNameAtIndex(index: Int) -> String {
        return ProductCategory.allValues()[index].name
    }
    
    // fills category field
    public func selectCategoryAtIndex(index: Int) {
        category = ProductCategory(rawValue: index+1) //index from 0 to N and prodCat from 1 to N+1
        delegate?.sellProductViewModel(self, didSelectCategoryWithName: category?.name ?? "")
        
    }
    
    public func appendImage(image: UIImage) {
        imagesModified = true
        images.append(.Local(image: image))
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func deleteImageAtIndex(index: Int) {
        imagesModified = true
        images.removeAtIndex(index)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func checkProductFields() {
        let error = validate()
        if let actualError = error {
            delegate?.sellProductViewModel(self, didFailWithError: actualError)
            trackValidationFailedWithError(actualError)
        } else {
            delegate?.sellProductViewModelFieldCheckSucceeded(self)
        }
    }

    public func save() {
        saveProduct(nil)
    }
    
    public var fbShareContent: FBSDKShareLinkContent? {
        if let product = savedProduct {
            let title = LGLocalizedString.sellShareFbContent
            return SocialHelper.socialMessageWithTitle(title, product: product).fbShareContent
        }
        return nil
    }
    
    // MARK: - Private methods
    
    internal func saveProduct(product: Product? = nil) {

        var theProduct = product ?? productManager.newProduct()
        guard let category = category else {
            let error = ProductSaveServiceError.NoCategory
            delegate?.sellProductViewModel(self, didFailWithError: error)
            return
        }
        let priceText = price ?? "0"
        theProduct = productManager.updateProduct(theProduct, name: title, price: Double(priceText),
            description: descr, category: category, currency: currency)

        saveTheProduct(theProduct, withImages: images)
    }
    
    func validate() -> ProductSaveServiceError? {
        
        if images.count < 1 {
            return .NoImages
        } else if descriptionCharCount < 0 {
            return .LongDescription
        } else if category == nil {
            return .NoCategory
        }
        return nil
    }

    func saveTheProduct(product: Product, withImages images: [SellProductImageType]) {

        delegate?.sellProductViewModelDidStartSavingProduct(self)

        let localImages = SellProductImageType.localImages(images)
        let remoteImages = SellProductImageType.remoteImages(images)
        if localImages.isEmpty {
            saveTheProduct(product, withImages: remoteImages)
        } else {
            productManager.saveProductImages(localImages,
                progress: { [weak self] (p: Float) -> Void in
                    if let strongSelf = self {
                        strongSelf.delegate?.sellProductViewModel(strongSelf, didUpdateProgressWithPercentage: p)
                    }
                },
                completion: { [weak self] (multipleFilesUploadResult: MultipleFilesUploadServiceResult) -> Void in
                    guard let strongSelf = self else { return }
                    guard let images = multipleFilesUploadResult.value else {
                        let error = multipleFilesUploadResult.error ?? .Internal
                        switch (error) {
                        case .Internal:
                            strongSelf.delegate?.sellProductViewModel(strongSelf, didFailWithError: .Internal)
                        case .Network:
                            strongSelf.delegate?.sellProductViewModel(strongSelf, didFailWithError: .Network)
                        case .Forbidden:
                            strongSelf.delegate?.sellProductViewModel(strongSelf, didFailWithError: .Forbidden)
                        }
                        return
                    }
                    strongSelf.saveTheProduct(product, withImages: remoteImages + images)
                }
            )
        }
    }

    func saveTheProduct(product: Product, withImages images: [File]) {
        productManager.saveProduct(product, imageFiles: images) { [weak self] (r: ProductSaveServiceResult) -> Void in
            if let strongSelf = self {
                if let actualProduct = r.value {
                    strongSelf.savedProduct = actualProduct
                    strongSelf.trackComplete(actualProduct)
                    strongSelf.delegate?.sellProductViewModel(strongSelf, didFinishSavingProductWithResult: r)
                } else {
                    let error = r.error ?? ProductSaveServiceError.Internal
                    strongSelf.delegate?.sellProductViewModel(strongSelf, didFailWithError: error)
                }
            }
        }
    }
}