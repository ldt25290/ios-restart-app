//
//  NotificationsTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

final class NotificationsTabCoordinator: TabCoordinator {

    convenience init() {
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let sessionManager = Core.sessionManager
        let viewModel = NotificationsViewModel()
        let rootViewController = NotificationsViewController(viewModel: viewModel)
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository, keyValueStorage: keyValueStorage, tracker: tracker,
                  sessionManager: sessionManager, rootViewController: rootViewController)

        viewModel.tabNavigator = self
    }

    override func shouldHideSellButtonAtViewController(viewController: UIViewController) -> Bool {
        return true
    }
}

extension NotificationsTabCoordinator: NotificationsTabNavigator {

}
