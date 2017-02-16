//
//  LogInEmailViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class LogInEmailViewController: KeyboardViewController {
    fileprivate enum TextFieldTag: Int {
        case email = 1000, password
    }

    fileprivate let viewModel: LogInEmailViewModel
    fileprivate let appearance: LoginAppearance
    fileprivate let backgroundImage: UIImage?
    fileprivate let deviceFamily: DeviceFamily

    fileprivate let backgroundImageView = UIImageView()
    fileprivate let backgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let scrollView = UIScrollView()
    fileprivate let headerGradientView = UIView()
    fileprivate let headerGradientLayer = CAGradientLayer.gradientWithColor(UIColor.white,
                                                                            alphas: [1, 0], locations: [0, 1])
    fileprivate let contentView = UIView()
    fileprivate let emailButton = UIButton()
    fileprivate let emailImageView = UIImageView()
    fileprivate let emailTextField = AutocompleteField()
    fileprivate let passwordButton = UIButton()
    fileprivate let passwordImageView = UIImageView()
    fileprivate let passwordTextField = LGTextField()
    fileprivate let showPasswordButton = UIButton()
    fileprivate let rememberPasswordButton = UIButton()
    fileprivate let loginButton = UIButton()
    fileprivate let footerButton = UIButton()

    fileprivate var lines: [CALayer] = []

    fileprivate let loginButtonVisible = Variable<Bool>(true)

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(viewModel: LogInEmailViewModel, appearance: LoginAppearance, backgroundImage: UIImage?) {
        self.init(viewModel: viewModel, appearance: appearance, backgroundImage: backgroundImage,
                  deviceFamily: DeviceFamily.current)
    }

    init(viewModel: LogInEmailViewModel, appearance: LoginAppearance, backgroundImage: UIImage?,
         deviceFamily: DeviceFamily) {
        self.viewModel = viewModel
        self.appearance = appearance
        self.backgroundImage = backgroundImage
        self.deviceFamily = deviceFamily
        super.init(viewModel: viewModel, nibName: nil,
                   statusBarStyle: appearance.statusBarStyle,
                   navBarBackgroundStyle: appearance.navBarBackgroundStyle)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupLayout()
        setupRx()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateUI()
    }
}


// MARK: - LogInEmailViewModelDelegate

extension LogInEmailViewController: LogInEmailViewModelDelegate {
    func vmGodModePasswordAlert() {
        let alertController = UIAlertController(title: "🔑", message: "Speak friend and enter", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let loginAction = UIAlertAction(title: "Login", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first else { return }
            let godPassword = textField.text ?? ""
            self?.viewModel.enableGodMode(godPassword: godPassword)
        }
        alertController.addAction(loginAction)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - UITextFieldDelegate

extension LogInEmailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        defer {
            scrollView.bounces = true  // Enable scroll bouncing so the keyboard is easy to dismiss on drag
            adjustScrollViewContentOffset()
        }

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }

        let iconImageView: UIImageView
        switch tag {
        case .email:
            iconImageView = emailImageView
        case .password:
            iconImageView = passwordImageView
        }
        iconImageView.isHighlighted = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            scrollView.bounces = false  // Disable scroll bouncing when no editing
            adjustScrollViewContentOffset()
        }

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }

        let iconImageView: UIImageView
        switch tag {
        case .email:
            iconImageView = emailImageView
            emailTextField.suggestion = nil
        case .password:
            iconImageView = passwordImageView
        }
        iconImageView.isHighlighted = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag

        if textField.returnKeyType == .next {
            guard let nextView = view.viewWithTag(tag + 1) else { return true }

            if tag == TextFieldTag.email.rawValue && viewModel.acceptSuggestedEmail() {
                emailTextField.text = viewModel.email.value
            }
            nextView.becomeFirstResponder()
            return false
        } else {
            loginButtonPressed()
            return true
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return !string.hasEmojis()
    }
}


// MARK: - Private
// MARK: > UI


fileprivate extension LogInEmailViewController {
    func setupNavigationBar() {
        title = LGLocalizedString.logInEmailTitle

        if isRootViewController() {
            let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .plain, target: self,
                                              action: #selector(closeButtonPressed))
            navigationItem.leftBarButtonItem = closeButton
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LGLocalizedString.logInEmailHelpButton, style: .plain,
                                                            target: self, action: #selector(openHelp))
    }

    func setupUI() {
        view.backgroundColor = UIColor.white

        if appearance.hasBackgroundImage {
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageView.image = backgroundImage
            view.addSubview(backgroundImageView)

            backgroundEffectView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backgroundEffectView)
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)

        headerGradientView.translatesAutoresizingMaskIntoConstraints = false
        headerGradientView.backgroundColor = UIColor.clear
        headerGradientView.isOpaque = true
        headerGradientView.layer.addSublayer(headerGradientLayer)
        headerGradientView.layer.sublayers?.removeAll()
        headerGradientView.layer.insertSublayer(headerGradientLayer, at: 0)
        headerGradientView.isHidden = appearance.headerGradientIsHidden
        view.addSubview(headerGradientView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let textfieldTextColor = appearance.textFieldTextColor
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = appearance.textFieldPlaceholderColor

        emailButton.translatesAutoresizingMaskIntoConstraints = false
        emailButton.setStyle(appearance.textFieldButtonStyle)
        emailButton.addTarget(self, action: #selector(makeEmailTextFieldFirstResponder), for: .touchUpInside)
        contentView.addSubview(emailButton)

        emailImageView.translatesAutoresizingMaskIntoConstraints = false
        emailImageView.image = appearance.emailIcon(highlighted: false)
        emailImageView.highlightedImage = appearance.emailIcon(highlighted: true)
        emailImageView.contentMode = .center
        contentView.addSubview(emailImageView)

        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.text = viewModel.email.value
        emailTextField.tag = TextFieldTag.email.rawValue
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .next
        emailTextField.textColor = textfieldTextColor
        emailTextField.completionColor = appearance.textFieldPlaceholderColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.logInEmailEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.clearButtonOffset = 0
        emailTextField.pixelCorrection = -1
        emailTextField.delegate = self
        contentView.addSubview(emailTextField)

        passwordButton.translatesAutoresizingMaskIntoConstraints = false
        passwordButton.setStyle(appearance.textFieldButtonStyle)
        passwordButton.addTarget(self, action: #selector(makePasswordTextFieldFirstResponder), for: .touchUpInside)
        contentView.addSubview(passwordButton)

        passwordImageView.translatesAutoresizingMaskIntoConstraints = false
        passwordImageView.image = appearance.passwordIcon(highlighted: false)
        passwordImageView.highlightedImage = appearance.passwordIcon(highlighted: true)
        passwordImageView.contentMode = .center
        contentView.addSubview(passwordImageView)

        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.text = viewModel.password.value
        passwordTextField.tag = TextFieldTag.password.rawValue
        passwordTextField.keyboardType = .default
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .send
        passwordTextField.textColor = textfieldTextColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.logInEmailPasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonOffset = 0
        passwordTextField.delegate = self
        contentView.addSubview(passwordTextField)

        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.setImage(appearance.showPasswordIcon(highlighted: false), for: .normal)
        showPasswordButton.setImage(appearance.showPasswordIcon(highlighted: true), for: .highlighted)
        showPasswordButton.setImage(appearance.showPasswordIcon(highlighted: true), for: .selected)
        contentView.addSubview(showPasswordButton)

        rememberPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        rememberPasswordButton.setTitle(LGLocalizedString.logInEmailForgotPasswordButton, for: .normal)
        rememberPasswordButton.setTitleColor(appearance.rememberPasswordTextColor, for: .normal)
        contentView.addSubview(rememberPasswordButton)

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setStyle(.primary(fontSize: .medium))
        loginButton.setTitle(LGLocalizedString.logInEmailLogInButton, for: .normal)
        contentView.addSubview(loginButton)

        let footerString = (LGLocalizedString.logInEmailFooter as NSString)
        let footerAttrString = NSMutableAttributedString(string: LGLocalizedString.logInEmailFooter)

        let footerStringRange = NSRange(location: 0, length: footerString.length)
        let signUpKwRange = footerString.range(of: LGLocalizedString.logInEmailFooterSignUpKw)

        if signUpKwRange.location != NSNotFound {
            let prefix = footerString.substring(to: signUpKwRange.location)
            let prefixRange = footerString.range(of: prefix)
            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: appearance.footerMainTextColor,
                                          range: prefixRange)

            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.primaryColor,
                                          range: signUpKwRange)
        } else {
            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: appearance.footerMainTextColor,
                                          range: footerStringRange)
        }

        footerButton.translatesAutoresizingMaskIntoConstraints = false
        footerButton.setTitleColor(UIColor.darkGrayText, for: .normal)
        footerButton.setAttributedTitle(footerAttrString, for: .normal)
        footerButton.titleLabel?.numberOfLines = 2
        footerButton.contentHorizontalAlignment = .center
        view.addSubview(footerButton)
    }

    func setupLayout() {
        if appearance.hasBackgroundImage {
            backgroundImageView.layout(with: view).fill()
            backgroundEffectView.layout(with: view).fill()
        }

        scrollView.layout(with: topLayoutGuide).vertically()
        scrollView.layout(with: bottomLayoutGuide).vertically(invert: true)
        scrollView.layout(with: view).leading().trailing()

        headerGradientView.layout(with: topLayoutGuide).vertically()
        headerGradientView.layout(with: view).leading().trailing()
        headerGradientView.layout().height(20)

        contentView.layout(with: scrollView).top().leading().proportionalWidth()

        emailButton.layout(with: contentView).top(by: 30).leading(by: 15).trailing(by: -15)
        emailButton.layout().height(50)
        emailImageView.layout().width(20)
        emailImageView.layout(with: emailButton).top().bottom().leading(by: 15)
        emailTextField.layout(with: emailButton).top().bottom().leading(by: 30).trailing(by: -8)

        passwordButton.layout(with: contentView).leading(by: 15).trailing(by: -15)
        passwordButton.layout(with: emailButton).vertically()
        passwordButton.layout().height(50)
        passwordImageView.layout().width(20)
        passwordImageView.layout(with: passwordButton).top().bottom().leading(by: 15)
        passwordTextField.layout(with: passwordButton).top().bottom().leading(by: 30)
        passwordTextField.layout(with: showPasswordButton).horizontally(by: -5)
        passwordTextField.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        showPasswordButton.layout().width(30).widthProportionalToHeight()
        showPasswordButton.layout(with: passwordButton).trailing(by: -10).centerY()

        rememberPasswordButton.layout(with: passwordButton).vertically(by: 5)
        rememberPasswordButton.layout(with: contentView).leading(by: 15).trailing(by: -15)
        rememberPasswordButton.layout().height(45, relatedBy: .greaterThanOrEqual)

        loginButton.layout(with: rememberPasswordButton).vertically(by: 5)
        loginButton.layout(with: contentView).leading(by: 15).trailing(by: -15).bottom(by: 15)
        loginButton.layout().height(50)

        if deviceFamily.isWiderOrEqualThan(.iPhone6) {
            footerButton.layout(with: keyboardView).bottom(to: .top)
        } else {
            footerButton.layout(with: view).bottom()
        }
        footerButton.layout(with: view).leading(by: 15).trailing(by: -15)
        footerButton.layout().height(55, relatedBy: .greaterThanOrEqual)
    }

    func updateUI() {
        // Update gradient frame
        headerGradientLayer.frame = headerGradientView.bounds

        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(passwordButton.addTopBorderWithWidth(1, color: appearance.lineColor))

        // Redraw masked rounded corners & corner radius
        emailButton.setRoundedCorners([.topLeft, .topRight], cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        passwordButton.setRoundedCorners([.bottomLeft, .bottomRight], cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        loginButton.rounded = true
    }

    func adjustScrollViewContentOffset() {
        let focusedTextFields = [emailTextField, passwordTextField].flatMap { $0 }.filter { $0.isFirstResponder }
        if let focusedTextField = focusedTextFields.first, !loginButtonVisible.value {
            let y = focusedTextField.frame.origin.y
            let offset = CGPoint(x: 0, y: y - emailTextField.frame.origin.y)
            scrollView.setContentOffset(offset, animated: true)
        } else {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }

    dynamic func closeButtonPressed() {
        viewModel.cancel()
    }

    dynamic func openHelp() {
        viewModel.openHelp()
    }

    dynamic func makeEmailTextFieldFirstResponder() {
        emailTextField.becomeFirstResponder()
    }

    dynamic func makePasswordTextFieldFirstResponder() {
        passwordTextField.becomeFirstResponder()
    }

    func showPasswordPressed() {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        showPasswordButton.isSelected = !passwordTextField.isSecureTextEntry

        // workaround to avoid weird font type
        passwordTextField.font = UIFont(name: "systemFont", size: 17)
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.blackTextHighAlpha
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailStep1PasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
    }

    func loginButtonPressed() {
        let errors = viewModel.logIn()
        openAlertWithFormErrors(errors: errors)
    }

    func openAlertWithFormErrors(errors: LogInEmailFormErrors) {
        guard !errors.isEmpty else { return }

        if errors.contains(.invalidEmail) {
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorInvalidEmail)
        } else if errors.contains(.shortPassword) || errors.contains(.longPassword) {
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword)
        }
    }
}


// MARK: > Rx

fileprivate extension LogInEmailViewController {
    func setupRx() {
        emailTextField.rx.text.bindTo(viewModel.email).addDisposableTo(disposeBag)
        viewModel.suggestedEmail.asObservable().subscribeNext { [weak self] suggestedEmail in
            self?.emailTextField.suggestion = suggestedEmail
        }.addDisposableTo(disposeBag)
        passwordTextField.rx.text.bindTo(viewModel.password).addDisposableTo(disposeBag)
        viewModel.password.asObservable().map { password -> Bool in
            guard let password = password else { return true }
            return password.isEmpty
        }.bindTo(showPasswordButton.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.logInEnabled.bindTo(loginButton.rx.isEnabled).addDisposableTo(disposeBag)
        rememberPasswordButton.rx.tap.subscribeNext {
            [weak self] _ in self?.viewModel.openRememberPassword()
        }.addDisposableTo(disposeBag)
        showPasswordButton.rx.tap.subscribeNext { [weak self] _ in self?.showPasswordPressed() }.addDisposableTo(disposeBag)
        loginButton.rx.tap.subscribeNext { [weak self] _ in self?.loginButtonPressed() }.addDisposableTo(disposeBag)
        footerButton.rx.tap.subscribeNext { [weak self] _ in
            self?.viewModel.openSignUp()
        }.addDisposableTo(disposeBag)

        // Login button is visible depending on current content offset & keyboard visibility
        Observable.combineLatest(scrollView.rx.contentOffset.asObservable(), keyboardChanges.asObservable()) { ($0, $1) }
            .map { [weak self] (offset, keyboardChanges) -> Bool in
                guard let strongSelf = self else { return false }
                let scrollY = offset.y
                let scrollHeight = strongSelf.scrollView.frame.height
                let scrollMaxY = scrollY + scrollHeight

                let scrollVisibleMaxY: CGFloat
                if keyboardChanges.visible {
                    scrollVisibleMaxY = scrollMaxY - keyboardChanges.height
                } else {
                    scrollVisibleMaxY = scrollMaxY
                }
                let buttonMaxY = strongSelf.loginButton.frame.maxY
                return scrollVisibleMaxY > buttonMaxY
        }.bindTo(loginButtonVisible).addDisposableTo(disposeBag)
    }
}
