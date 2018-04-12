//
//  BumpUpCoordinator.swift
//  LetGo
//
//  Created by Dídac on 30/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum BumpUpPurchaseableData {
    case socialMessage(message: SocialMessage)
    case purchaseableProduct(product: PurchaseableProduct)
}

struct BumpUpProductData {
    let bumpUpPurchaseableData: BumpUpPurchaseableData
    let letgoItemId: String?
    let storeProductId: String?

    var hasPaymentId: Bool {
        return letgoItemId != nil
    }
}

class BumpUpCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager


    convenience init(listing: Listing,
                     bumpUpProductData: BumpUpProductData,
                     typePage: EventParameterTypePage?,
                     timeSinceLastBump: TimeInterval? = nil,
                     maxCountdown: TimeInterval? = nil) {
        switch bumpUpProductData.bumpUpPurchaseableData {
        case .socialMessage(let socialMessage):
            self.init(listing: listing,
                      socialMessage: socialMessage,
                      letgoItemId: bumpUpProductData.letgoItemId,
                      storeProductId: bumpUpProductData.storeProductId,
                      typePage: typePage,
                      bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                      sessionManager: Core.sessionManager)
        case .purchaseableProduct(let purchaseableProduct):
            let featureFlags = FeatureFlags.sharedInstance
            self.init(listing: listing,
                      purchaseableProduct: purchaseableProduct,
                      letgoItemId: bumpUpProductData.letgoItemId,
                      storeProductId: bumpUpProductData.storeProductId,
                      typePage: typePage,
                      bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                      sessionManager: Core.sessionManager,
                      featureFlags: featureFlags,
                      timeSinceLastBump: timeSinceLastBump,
                      maxCountdown: maxCountdown)
        }
    }

    init(listing: Listing,
         socialMessage: SocialMessage,
         letgoItemId: String?,
         storeProductId: String?,
         typePage: EventParameterTypePage?,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {

        let bumpUpVM = BumpUpFreeViewModel(listing: listing,
                                           socialMessage: socialMessage,
                                           letgoItemId: letgoItemId,
                                           storeProductId: storeProductId,
                                           typePage: typePage)
        let bumpUpVC = BumpUpFreeViewController(viewModel: bumpUpVM)
        bumpUpVC.modalPresentationStyle = .overCurrentContext
        self.viewController = bumpUpVC
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        bumpUpVM.navigator = self
    }


    init(listing: Listing,
         purchaseableProduct: PurchaseableProduct,
         letgoItemId: String?,
         storeProductId: String?,
         typePage: EventParameterTypePage?,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable,
         timeSinceLastBump: TimeInterval? = nil,
         maxCountdown: TimeInterval? = nil) {

        let bumpUpVM = BumpUpPayViewModel(listing: listing,
                                          purchaseableProduct: purchaseableProduct,
                                          letgoItemId: letgoItemId,
                                          storeProductId: storeProductId,
                                          typePage: typePage)

        let bumpUpVC: BaseViewController
        if let timeSinceLastBump = timeSinceLastBump, let maxCountdown = maxCountdown {
            bumpUpVM.isBoost = true
            bumpUpVC = BumpUpBoostViewController(viewModel: bumpUpVM,
                                                 featureFlags: featureFlags,
                                                 timeSinceLastBump: timeSinceLastBump,
                                                 maxCountdown: maxCountdown)
        } else {
            bumpUpVC = BumpUpPayViewController(viewModel: bumpUpVM)
        }

        bumpUpVC.modalPresentationStyle = .overCurrentContext
        self.viewController = bumpUpVC
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        bumpUpVM.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

extension BumpUpCoordinator : BumpUpNavigator {
    func bumpUpDidCancel() {
        closeCoordinator(animated: true, completion: nil)
    }

    func bumpUpDidFinish(completion: (() -> Void)?) {
        closeCoordinator(animated: true, completion: completion)
    }
}
