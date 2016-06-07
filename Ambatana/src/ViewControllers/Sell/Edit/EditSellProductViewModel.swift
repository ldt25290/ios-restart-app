//
//  EditSellProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol EditSellProductViewModelDelegate : class {
}

protocol UpdateDetailInfoDelegate : class {
    func updateDetailInfo(viewModel: EditSellProductViewModel, withSavedProduct: Product)
    func updateDetailInfo(viewModel: EditSellProductViewModel, withInitialProduct: Product)
}

class EditSellProductViewModel: BaseSellProductViewModel {

    private var initialProduct: Product
    private var editedProduct: Product
    weak var updateDetailDelegate : UpdateDetailInfoDelegate?
    var promoteProductVM: PromoteProductViewModel?
    
    init(myUserRepository: MyUserRepository, productRepository: ProductRepository, tracker: Tracker, product: Product) {
        self.initialProduct = product
        self.editedProduct = product
        super.init(myUserRepository: myUserRepository, productRepository: productRepository, tracker: tracker)

        self.title = product.title
        self.titleAutotranslated.value = product.isTitleAutoTranslated(Core.countryHelper)
        self.titleAutogenerated.value = product.isTitleAutoGenerated
        if let price = product.price {
            self.price = String.fromPriceDouble(price)
        }
        currency = product.currency
        if let descr = product.descr {
            self.descr = descr
        }
        category = product.category
        for file in product.images { productImages.append(file) }
    }

    convenience init(product: Product) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productRepository: productRepository, tracker: tracker,
            product: product)
    }
    
    
    // MARK: - methods

    override func save() {
        updateProduct()
    }

    func updateProduct() {
        guard let category = category else {
            delegate?.sellProductViewModel(self, didFailWithError: .NoCategory)
            return
        }
        let name = title ?? ""
        let description = (descr ?? "").stringByRemovingEmoji()
        let priceAmount = (price ?? "0").toPriceDouble()
        let currency = editedProduct.currency

        editedProduct = productRepository.updateProduct(editedProduct, name: name, description: description,
                    price: priceAmount, currency: currency, location: nil, postalAddress: nil, category: category)
        saveTheProduct(editedProduct, withImages: productImages)
    }


    // MARK: - Tracking methods

    override func trackStart() {
        super.trackStart()
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditStart(myUser, product: editedProduct)
        trackEvent(event)
    }

    override func trackValidationFailedWithError(error: ProductCreateValidationError) {
        super.trackValidationFailedWithError(error)

        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditFormValidationFailed(myUser, product: editedProduct, description: error.rawValue)
        trackEvent(event)
    }

    override func trackSharedFB() {
        super.trackSharedFB()
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditSharedFB(myUser, product: savedProduct)
        trackEvent(event)
    }

    override func trackComplete(product: Product) {
        self.editedProduct = product

        super.trackComplete(product)

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


    // MARK: - Update info of previous VC

    func updateInfoOfPreviousVCWithProduct(savedProduct: Product) {
        updateDetailDelegate?.updateDetailInfo(self, withSavedProduct: savedProduct)
    }

    func notifyPreviousVCEditCompleted() {
        updateDetailDelegate?.updateDetailInfo(self, withInitialProduct: initialProduct)
    }
}
