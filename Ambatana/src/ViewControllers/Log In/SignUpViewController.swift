//
//  SignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

class SignUpViewController: BaseViewController, SignUpViewModelDelegate, UITextFieldDelegate {
    
    // Constants & enum
    enum TextFieldTag: Int {
        case Username = 1000, Email, Password
    }
    
    // Data
    var afterLoginAction: (() -> Void)?
    
    // > ViewModel
    var viewModel: SignUpViewModel!
    
    // UI
    @IBOutlet weak var usernameIconImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailButton: UIButton!

    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    // > Helper
    var lines: [CALayer]
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: SignUpViewModel(), nibName: "SignUpViewController")
    }
    
    required init(viewModel: SignUpViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.lines = []
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel.delegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        usernameTextField.becomeFirstResponder()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(usernameButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }
    
    // MARK: - Actions
    
    @IBAction func usernameButtonPressed(sender: AnyObject) {
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        viewModel.signUp()
    }
    
    // MARK: - SignUpViewModelDelegate
    
    func viewModel(viewModel: SignUpViewModel, updateSendButtonEnabledState enabled: Bool) {
        signUpButton.enabled = enabled
    }
    
    func viewModelDidStartSigningUp(viewModel: SignUpViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: SignUpViewModel, didFinishSigningUpWithResult result: Result<Nil, UserSignUpServiceError>) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
            }
            break
        case .Failure(let error):
            
            let message: String
            switch (error.value) {
            case .InvalidEmail:
                message = NSLocalizedString("sign_up_send_error_invalid_email", comment: "")
            case .InvalidUsername:
                message = NSLocalizedString("sign_up_send_error_invalid_username", comment: "")
            case .InvalidPassword:
                message = NSLocalizedString("sign_up_send_error_invalid_password", comment: "")
            case .Network:
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .EmailTaken:
                message = NSLocalizedString("sign_up_send_error_email_taken", comment: "")
            case .Internal:
                message = NSLocalizedString("sign_up_send_error_generic", comment: "")
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion: completion)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Username:
                iconImageView = usernameIconImageView
            case .Email:
                iconImageView = emailIconImageView
            case .Password:
                iconImageView = passwordIconImageView
            }
            iconImageView.highlighted = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Username:
                iconImageView = usernameIconImageView
            case .Email:
                iconImageView = emailIconImageView
            case .Password:
                iconImageView = passwordIconImageView
            }
            iconImageView.highlighted = false
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        setText("", intoTextField: textField)
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        setText(text, intoTextField: textField)
        return false
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        // Appearance
        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        signUpButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        signUpButton.layer.cornerRadius = 4
        
        // i18n
        setLetGoNavigationBarStyle(title: NSLocalizedString("sign_up_title", comment: ""))
        usernameTextField.placeholder = NSLocalizedString("sign_up_username_field_hint", comment: "")
        emailTextField.placeholder = NSLocalizedString("sign_up_email_field_hint", comment: "")
        passwordTextField.placeholder = NSLocalizedString("sign_up_password_field_hint", comment: "")
        signUpButton.setTitle(NSLocalizedString("sign_up_send_button", comment: ""), forState: .Normal)
        
        // Tags
        usernameTextField.tag = TextFieldTag.Username.rawValue
        emailTextField.tag = TextFieldTag.Email.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
    }
    
    private func setText(text: String, intoTextField textField: UITextField) {
        textField.text = text
        
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .Username:
                viewModel.username = text
            case .Email:
                viewModel.email = text
            case .Password:
                viewModel.password = text
            }
        }
    }
}
