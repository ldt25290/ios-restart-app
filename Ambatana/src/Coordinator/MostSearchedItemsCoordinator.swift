//
//  MostSearchedItemsCoordinator.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 18/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

protocol MostSearchedItemsCoordinatorDelegate: class {
    //func cancelMostSearchedItems()
    func openSell(source: PostingSource, mostSearchedItem: LocalMostSearchedItem)
}

class MostSearchedItemsCoordinator: Coordinator {
    
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager
    
    var featureFlags: FeatureFlaggeable
    weak var delegate: MostSearchedItemsCoordinatorDelegate?
    
    convenience init(source: MostSearchedItemsSource) {
        self.init(source: source,
                  featureFlags: FeatureFlags.sharedInstance,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }
    
    init(source: MostSearchedItemsSource,
         featureFlags: FeatureFlags,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        self.featureFlags = featureFlags
        
        let mostSearchedItemsVM = MostSearchedItemsListViewModel(isSearchEnabled: true)
        let mostSearchedItemsVC = MostSearchedItemsListViewController(viewModel: mostSearchedItemsVM)
        mostSearchedItemsVC.modalPresentationStyle = .overCurrentContext
        self.viewController = mostSearchedItemsVC
        mostSearchedItemsVM.navigator = self
        
    }
    
    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }
    
    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

extension MostSearchedItemsCoordinator: MostSearchedItemsNavigator {
    func cancel() {
        dismissViewController(animated: true, completion: nil)
        //delegate?.cancelMostSearchedItems()
    }
    
    func openSell(mostSearchedItem: LocalMostSearchedItem) {
        dismissViewController(animated: true) { [weak self] in
            self?.delegate?.openSell(source: .mostSearchedItems, mostSearchedItem: mostSearchedItem)
        }
    }
}
