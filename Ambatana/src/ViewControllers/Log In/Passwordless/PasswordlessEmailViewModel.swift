//
//  PasswordlessEmailViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 27/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import LGComponents
import RxSwift

final class PasswordlessEmailViewModel: BaseViewModel {

    weak var navigator: PasswordlessNavigator?
    weak var delegate: BaseViewModelDelegate?

    private let sessionManager: SessionManager
    private let tracker: Tracker

    init(sessionManager: SessionManager = Core.sessionManager,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.sessionManager = sessionManager
        self.tracker = tracker
    }

    let isContinueActionEnabled = Variable<Bool>(false)

    func didChange(email: String?) {
        isContinueActionEnabled.value = email?.isEmail() ?? false
    }

    func didTapContinueWith(email: String) {
        sessionManager.requestPasswordlessWith(email: email) { [weak self] result in
            switch result {
            case .success:
                self?.navigator?.openPasswordlessEmailSentTo(email: email)
            case .failure:
                let message = R.Strings.commonErrorGenericBody // FIXME: change when product specs are available
                self?.delegate?.vmShowAutoFadingMessage(message, completion: nil)
                break
            }
        }
        tracker.trackEvent(.loginEmailSubmit())
    }

    func didTapHelp() {
        navigator?.openHelpFromPasswordless()
    }
}
