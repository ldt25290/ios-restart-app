//
//  VerifyAccountsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 30/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

protocol VerifyAccountsViewModelDelegate: BaseViewModelDelegate {

}


enum VerifyButtonState {
    case Hidden
    case Enabled
    case Disabled
    case Loading
}

enum VerifyAccountsSource {
    case Chat
}

class VerifyAccountsViewModel: BaseViewModel {
    weak var delegate: VerifyAccountsViewModelDelegate?

    let fbButtonState = Variable<VerifyButtonState>(.Hidden)
    let googleButtonState = Variable<VerifyButtonState>(.Hidden)
    let emailButtonState = Variable<VerifyButtonState>(.Hidden)
    private(set) var emailRequiresInput = false
    let typedEmail = Variable<String?>(nil)

    private let googleHelper: GoogleLoginHelper
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    private let source: VerifyAccountsSource
    private let types: [VerificationType]

    private let disposeBag = DisposeBag()

    convenience init(verificationTypes: [VerificationType], source: VerifyAccountsSource) {
        let myUserRepository = Core.myUserRepository
        let googleHelper = GoogleLoginHelper(loginSource: source.loginSource)
        let tracker = TrackerProxy.sharedInstance
        self.init(verificationTypes: verificationTypes, source: source, myUserRepository: myUserRepository,
                  googleHelper: googleHelper, tracker: tracker)
    }

    init(verificationTypes: [VerificationType], source: VerifyAccountsSource, myUserRepository: MyUserRepository,
         googleHelper: GoogleLoginHelper, tracker: Tracker) {
        self.types = verificationTypes
        self.source = source
        self.myUserRepository = myUserRepository
        self.googleHelper = googleHelper
        self.tracker = tracker
        super.init()

        setupState()
        setupRx()
    }


    // MARK: - Public

    func closeButtonPressed() {
        delegate?.vmDismiss(nil)
    }

    func googleButtonPressed() {
        connectWithGoogle()
    }

    func fbButtonPressed() {
        connectWithFacebook()
    }

    func emailButtonPressed() {
        guard let email = typedEmail.value else { return }
        emailVerification(email)
    }


    // MARK: - Setup

    private func setupState() {
        types.forEach {
            switch $0 {
            case .Google:
                googleButtonState.value = .Enabled
            case .Facebook:
                fbButtonState.value = .Enabled
            case let .Email(email):
                if let email = email where !email.isEmpty {
                    emailRequiresInput = false
                }
                typedEmail.value = email
                emailButtonState.value = .Enabled
            }
        }
    }

    private func setupRx() {
        guard emailRequiresInput && emailButtonState.value == .Enabled else { return }
        typedEmail.asObservable().bindNext { [weak self] email in
            guard let actionState = self?.emailButtonState where actionState.value != .Loading else { return }
            let isEmail = email?.isEmail() ?? false
            actionState.value = isEmail ? .Enabled : .Disabled
        }.addDisposableTo(disposeBag)
    }
}



// MARK: - Private actions

private extension VerifyAccountsViewModel {
    func connectWithFacebook() {
        fbButtonState.value = .Loading
        FBLoginHelper.connectWithFacebook { [weak self] result in
            self?.fbButtonState.value = .Enabled
            switch result {
            case let .Success(token):
                self?.myUserRepository.linkAccountFacebook(token) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.Facebook)
                        self?.delegate?.vmDismiss(nil)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
                    }
                }
            case .Cancelled:
                break
            case .Error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
            }
        }
    }

    func connectWithGoogle() {
        googleButtonState.value = .Loading
        googleHelper.googleSignIn { [weak self] result in
            self?.googleButtonState.value = .Enabled
            switch result {
            case let .Success(serverAuthToken):
                self?.myUserRepository.linkAccountGoogle(serverAuthToken) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.Google)
                        self?.delegate?.vmDismiss(nil)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
                    }
                }
            case .Cancelled:
                break
            case .Error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
            }
        }
    }

    func emailVerification(email: String) {
        emailButtonState.value = .Loading
        myUserRepository.linkAccount(email) { [weak self] result in
            self?.emailButtonState.value = .Enabled
            if let error = result.error {
                switch error {
                case .TooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests, completion: nil)
                case .Network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody, completion: nil)
                case .Forbidden, .Internal, .NotFound, .Unauthorized, .UserNotVerified:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: nil)
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess) {
                    self?.delegate?.vmDismiss(nil)
                }
            }
        }
    }

    func verificationSuccess(verificationType: VerificationType) {
        delegate?.vmDismiss(nil)
    }
}


// MARK: - Trackings

private extension VerifyAccountsViewModel {
    func trackStart() {
        let event = TrackerEvent.verifyAccountStart(source.typePage)
        tracker.trackEvent(event)
    }

    func trackComplete(verificationType: VerificationType) {
        let event = TrackerEvent.verifyAccountComplete(source.typePage, network: verificationType.accountNetwork)
        tracker.trackEvent(event)
    }
}

private extension VerifyAccountsSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .Chat:
            return .Chat
        }
    }

    var loginSource: EventParameterLoginSourceValue {
        switch self {
        case .Chat:
            return .Chats
        }
    }
}

private extension VerificationType {
    var accountNetwork: EventParameterAccountNetwork {
        switch self {
        case .Facebook:
            return .Facebook
        case .Google:
            return .Google
        case .Email:
            return .Email
        }
    }
}
