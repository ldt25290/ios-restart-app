//
//  SignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class SignUpViewController: BaseViewController, UITextFieldDelegate {
    
    // Constants & enum
    enum TextFieldTag: Int {
        case Email = 1000, Username, Password
    }
    
    // ViewModel
    var viewModel: SignUpViewModel!
    
    // UI
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var usernameIconImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameButton: UIButton!

    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: SignUpViewModel(), nibName: "SignUpViewController")
    }
    
    required init(viewModel: SignUpViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        emailTextField.becomeFirstResponder()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        usernameButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
    }
    
    // MARK: - Actions
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
    
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
            case .Username:
                iconImageView = usernameIconImageView
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
            case .Email:
                iconImageView = emailIconImageView
            case .Username:
                iconImageView = usernameIconImageView
            case .Password:
                iconImageView = passwordIconImageView
            }
            iconImageView.highlighted = false
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.text = ""
        updateSendButtonEnabledState()
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
        textField.text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        updateSendButtonEnabledState()
        return false
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    func setupUI() {
        // Navigation bar
        let backButton = UIBarButtonItem(image: UIImage(named: "navbar_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popViewController")
        navigationItem.leftBarButtonItem = backButton
//        navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        
        title = NSLocalizedString("sign_up_title", comment: "")
        
        // Appearance
        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        signUpButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        signUpButton.layer.cornerRadius = 4
        
        // i18n
        emailTextField.placeholder = NSLocalizedString("sign_up_email_field_placeholder", comment: "")
        usernameTextField.placeholder = NSLocalizedString("sign_up_username_field_placeholder", comment: "")
        passwordTextField.placeholder = NSLocalizedString("sign_up_password_field_placeholder", comment: "")
        signUpButton.setTitle(NSLocalizedString("sign_up_send_button", comment: ""), forState: .Normal)
        
        // Tags
        emailTextField.tag = TextFieldTag.Email.rawValue
        usernameTextField.tag = TextFieldTag.Username.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
    }
    
    private func updateSendButtonEnabledState() {
        signUpButton.enabled = count(emailTextField.text) > 0 && count(usernameTextField.text) > 0 && count(passwordTextField.text) > 0
    }
    
    // MARK: > Navigation
    
    func popViewController() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        navigationController?.view.layer.addAnimation(transition, forKey: nil)
        navigationController?.popViewControllerAnimated(false)
    }
}
