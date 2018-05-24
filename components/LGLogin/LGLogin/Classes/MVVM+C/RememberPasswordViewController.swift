//
//  RememberPasswordViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import UIKit

class RememberPasswordViewController: BaseViewController, RememberPasswordViewModelDelegate, UITextFieldDelegate {

    // Constants & enum
    enum TextFieldTag: Int {
        case email = 1000
    }
    
    // ViewModel
    var viewModel: RememberPasswordViewModel


    @IBOutlet weak var darkAppereanceBgView: UIView!
    @IBOutlet weak var kenBurnsView: KenBurnsView!
    
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailButton: LetgoButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var resetPasswordButton: LetgoButton!
    
    @IBOutlet weak var instructionsLabel : UILabel!
    
    // > Helper
    private let appearance: LoginAppearance

    
    // MARK: - Lifecycle

    init(viewModel: RememberPasswordViewModel, appearance: LoginAppearance = .light) {
        self.viewModel = viewModel
        self.appearance = appearance

        let statusBarStyle: UIStatusBarStyle
        let navBarBackgroundStyle: NavBarBackgroundStyle
        switch appearance {
        case .dark:
            statusBarStyle = .lightContent
            navBarBackgroundStyle = .transparent(substyle: .dark)
        case .light:
            statusBarStyle = .default
            navBarBackgroundStyle = .transparent(substyle: .light)
        }
        super.init(viewModel: viewModel, nibName: "RememberPasswordViewController",
                   statusBarStyle: statusBarStyle, navBarBackgroundStyle: navBarBackgroundStyle)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        emailTextField.becomeFirstResponder()
        emailTextField.tintColor = UIColor.primaryColor
        
        // update the textfield with the e-mail from previous view
        emailTextField.text = viewModel.email
        updateViewModelText(viewModel.email, fromTextFieldTag: emailTextField.tag)
        
    }

    override func viewWillFirstAppear(_ animated: Bool) {
        super.viewWillFirstAppear(animated)
        switch appearance {
        case .light:
            break
        case .dark:
            setupKenBurns()
        }
    }


    // MARK: - Actions
    
    @IBAction func resetPasswordButtonPressed(_ sender: AnyObject) {
        viewModel.resetPassword()
    }
    

    // MARK: - RememberPasswordViewModelDelegate
    
    func viewModel(_ viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool) {
        resetPasswordButton.isEnabled = enabled
    }
    

    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .email:
                iconImageView = emailIconImageView
            }
            iconImageView.isHighlighted = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .email:
                iconImageView = emailIconImageView
            }
            iconImageView.isHighlighted = false
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        updateViewModelText("", fromTextFieldTag: textField.tag)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            viewModel.resetPassword()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
            updateViewModelText(text, fromTextFieldTag: textField.tag)
        }
        return true
    }


    // MARK: - Private methods
    // MARK: > UI
    
    private func setupUI() {
        // Appearance
        emailButton.cornerRadius = LGUIKitConstants.mediumCornerRadius
        resetPasswordButton.setStyle(.primary(fontSize: .medium))
        
        // i18n
        setNavBarTitle(R.Strings.resetPasswordTitle)
        emailTextField.placeholder = R.Strings.resetPasswordEmailFieldHint
        resetPasswordButton.setTitle(R.Strings.resetPasswordSendButton, for: .normal)
        instructionsLabel.text = R.Strings.resetPasswordInstructions
        
        // Tags
        emailTextField.tag = TextFieldTag.email.rawValue

        switch appearance {
        case .light:
            setupLightAppearance()
        case .dark:
            setupDarkAppearance()
        }
    }

    private func setupLightAppearance() {
        darkAppereanceBgView.isHidden = true

        let textfieldTextColor = UIColor.lgBlack
        let textfieldTextPlaceholderColor = UIColor.lgBlack.withAlphaComponent(0.5)
        var textfieldPlaceholderAttrs = [NSAttributedStringKey: Any]()
        textfieldPlaceholderAttrs[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSAttributedStringKey.foregroundColor] = textfieldTextPlaceholderColor

        emailButton.setStyle(.lightField)
        emailIconImageView.image = UIImage(named: "ic_email")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
    }

    private func setupDarkAppearance() {
        darkAppereanceBgView.isHidden = false

        let textfieldTextColor = UIColor.white
        let textfieldTextPlaceholderColor = textfieldTextColor.withAlphaComponent(0.7)
        var textfieldPlaceholderAttrs = [NSAttributedStringKey: Any]()
        textfieldPlaceholderAttrs[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSAttributedStringKey.foregroundColor] = textfieldTextPlaceholderColor

        emailButton.setStyle(.darkField)
        emailIconImageView.image = UIImage(named: "ic_email_dark")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active_dark")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
    }

    func setupKenBurns() {
        view.layoutIfNeeded()
        kenBurnsView.startAnimation(with: [#imageLiteral(resourceName: "bg_1_new"), #imageLiteral(resourceName: "bg_2_new"), #imageLiteral(resourceName: "bg_3_new"), #imageLiteral(resourceName: "bg_4_new")])
    }
    
    private func updateSendButtonEnabledState() {
        if let email = emailTextField.text {
            resetPasswordButton.isEnabled = email.count > 0
        } else {
            resetPasswordButton.isEnabled = false
        }
    }
    
    // MARK: > Helper
    
    private func updateViewModelText(_ text: String, fromTextFieldTag tag: Int) {
        if let tag = TextFieldTag(rawValue: tag) {
            switch (tag) {
            case .email:
                viewModel.email = text
            }
        }
    }
}
