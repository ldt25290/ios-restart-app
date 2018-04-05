//
//  SMSPhoneInputViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 03/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import RxCocoa

final class UserPhoneVerificationNumberInputViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?

    var country: Driver<String> { return .just("") }
    var isContinueActionEnabled: Driver<Bool> { return .just(false) }

    init(fake: String? = "") {
        super.init()
    }

    func didTapCountryButton() {
        navigator?.openCountrySelector()
    }

    func didTapContinueButton() {
        navigator?.openCodeInput()
    }
}
