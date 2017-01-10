//
//  MainSignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import RxSwift

class MainSignUpViewController: BaseViewController, UITextViewDelegate, GIDSignInUIDelegate {

    // Data
    var afterLoginAction: (() -> Void)?
    
    // > ViewModel
    var viewModel: SignUpViewModel
    
    // UI
    // > Header
    @IBOutlet weak var claimLabel: UILabel!
    
    // > Main View
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var quicklyLabel: UILabel!

    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var connectGoogleButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    // Footer
    
    @IBOutlet weak var legalTextView: UITextView!
    
    // Constraints to adapt for iPhone 4/5
    @IBOutlet weak var mainViewHeightProportion: NSLayoutConstraint!
    @IBOutlet weak var loginButtonBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var orDividerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var googleButtonTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var facebookButtonTopMarginConstraint: NSLayoutConstraint!
    
    // Bar Buttons
    private var closeButton: UIBarButtonItem?
    private var helpButton: UIBarButtonItem?

    // > Helper
    var lines: [CALayer]

    private let disposeBag: DisposeBag

    
    // MARK: - Lifecycle
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        self.lines = []
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "MainSignUpViewController",
                   navBarBackgroundStyle: .transparent(substyle: .light))
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRx()
        setAccesibilityIds()

        switch DeviceFamily.current {
        case .iPhone4:
            adaptConstraintsToiPhone4()
        case .iPhone5:
            adaptConstraintsToiPhone5()
        default:
            break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(dividerView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
        lines.append(firstDividerView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }
    
    // MARK: - Actions
    
    func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    func helpButtonPressed() {
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
     
    @IBAction func connectFBButtonPressed(_ sender: AnyObject) {
        viewModel.connectFBButtonPressed()
    }
    
    @IBAction func connectGoogleButtonPressed(_ sender: AnyObject) {
        viewModel.connectGoogleButtonPressed()
    }
    
    @IBAction func signUpButtonPressed(_ sender: AnyObject) {
        viewModel.signUpButtonPressed()
    }
    
    @IBAction func logInButtonPressed(_ sender: AnyObject) {
        viewModel.logInButtonPressed()
    }
    
    @IBAction func contactUsButtonPressed() {
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {

        // View
        view.backgroundColor = UIColor.white

        // Navigation bar
        closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .plain, target: self,
            action: #selector(MainSignUpViewController.closeButtonPressed))
        navigationItem.leftBarButtonItem = closeButton
        helpButton = UIBarButtonItem(title: LGLocalizedString.mainSignUpHelpButton, style: .plain, target: self,
            action: #selector(MainSignUpViewController.helpButtonPressed))
        navigationItem.rightBarButtonItem = helpButton

        // Appearance
        connectFBButton.setStyle(.facebook)
        connectGoogleButton.setStyle(.google)

        signUpButton.setStyle(.secondary(fontSize: .medium, withBorder: true))
        logInButton.setStyle(.secondary(fontSize: .medium, withBorder: true))

        // i18n
        claimLabel.text = LGLocalizedString.mainSignUpClaimLabel
        claimLabel.font = UIFont.smallBodyFont
        claimLabel.textColor = UIColor.black
        quicklyLabel.text = LGLocalizedString.mainSignUpQuicklyLabel
        quicklyLabel.font = UIFont.smallBodyFont
        quicklyLabel.backgroundColor = view.backgroundColor

        orLabel.text = LGLocalizedString.mainSignUpOrLabel
        orLabel.font = UIFont.smallBodyFont
        orLabel.backgroundColor = view.backgroundColor
        signUpButton.setTitle(LGLocalizedString.mainSignUpSignUpButton, for: UIControlState())
        logInButton.setTitle(LGLocalizedString.mainSignUpLogInLabel, for: UIControlState())

        setupTermsAndConditions()
    }

    private func setupRx() {
        // Facebook button title
        viewModel.previousFacebookUsername.asObservable()
            .map { username in
                if let username = username {
                    return LGLocalizedString.mainSignUpFacebookConnectButtonWName(username)
                } else {
                    return LGLocalizedString.mainSignUpFacebookConnectButton
                }
            }.bindTo(connectFBButton.rx.title)
            .addDisposableTo(disposeBag)

        // Google button title
        viewModel.previousGoogleUsername.asObservable()
            .map { username in
                if let username = username {
                    return LGLocalizedString.mainSignUpGoogleConnectButtonWName(username)
                } else {
                    return LGLocalizedString.mainSignUpGoogleConnectButton
                }
            }.bindTo(connectGoogleButton.rx.title)
            .addDisposableTo(disposeBag)
    }
    
    private func adaptConstraintsToiPhone4() {
        mainViewHeightProportion.constant = 100
        loginButtonBottomMarginConstraint.constant = 0
        signUpButtonTopMarginConstraint.constant = 10
        orDividerTopMarginConstraint.constant = 15
        googleButtonTopMarginConstraint.constant = 8
        facebookButtonTopMarginConstraint.constant = 8
    }

    private func adaptConstraintsToiPhone5() {
        mainViewHeightProportion.constant = 70
    }

    private func setupTermsAndConditions() {
        legalTextView.attributedText = viewModel.attributedLegalText
        legalTextView.textContainer.maximumNumberOfLines = 3
        legalTextView.textAlignment = .center
        legalTextView.delegate = self
    }
}


// MARK: - SignUpViewModelDelegate

// This should be done on a coordinator through a navigator from viewModel
extension MainSignUpViewController: SignUpViewModelDelegate {

    func vmOpenSignup(_ viewModel: SignUpLogInViewModel) {
        let vc = SignUpLogInViewController(viewModel: viewModel)
        vc.afterLoginAction = afterLoginAction
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmFinish(completedLogin completed: Bool) {
        dismiss(animated: true, completion: completed ? afterLoginAction : nil)
    }

    func vmFinishAndShowScammerAlert(_ contactUrl: URL, network: EventParameterAccountNetwork, tracker: Tracker) {
        let parentController = presentingViewController
        let contact = UIAction(
            interface: .button(LGLocalizedString.loginScammerAlertContactButton, .primary(fontSize: .medium)),
            action: {
                tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network))
                parentController?.openInternalUrl(contactUrl)
            })
        let keepBrowsing = UIAction(
            interface: .button(LGLocalizedString.loginScammerAlertKeepBrowsingButton, .secondary(fontSize: .medium, withBorder: false)),
            action: {
                tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network))
            })
        dismiss(animated: false) {
            tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network))
            parentController?.showAlertWithTitle(LGLocalizedString.loginScammerAlertTitle,
                                                 text: LGLocalizedString.loginScammerAlertMessage,
                                                 alertType: .iconAlert(icon: UIImage(named: "ic_moderation_alert")),
                                                 buttonsLayout: .vertical, actions:  [contact, keepBrowsing])
        }
    }
}


// MARK: - Accesibility

extension MainSignUpViewController {
    func setAccesibilityIds() {
        connectFBButton.accessibilityId = .mainSignUpFacebookButton
        connectGoogleButton.accessibilityId = .mainSignUpGoogleButton
        signUpButton.accessibilityId = .mainSignUpSignupButton
        logInButton.accessibilityId = .mainSignupLogInButton
        closeButton?.accessibilityId = .mainSignupCloseButton
        helpButton?.accessibilityId = .mainSignupHelpButton
    }
}
