import LGComponents

final class LoginStandardWireframe: LoginNavigator {
    let nc: UINavigationController
    
    init(nc: UINavigationController) {
        self.nc = nc
    }
    
    func showHelp() {
        let vc = LGHelpBuilder.standard(nc).buildHelp()
        nc.pushViewController(vc, animated: true)
    }
    
    func showSignInWithEmail(source: EventParameterLoginSourceValue,
                              appearance: LoginAppearance,
                              logicAction: (() -> ())?,
                              cancelAction: (() -> ())?) {
        let vc = LoginBuilder.standard(context: nc)
            .buildSignUpWithEmail(withSource: source,
                                  appearance: appearance,
                                  loginAction: logicAction,
                                  cancelAction: cancelAction)
        nc.pushViewController(vc, animated: true)
    }
    
    func showLoginWithEmail(source: EventParameterLoginSourceValue,
                            logicAction: (() -> ())?,
                            cancelAction: (() -> ())?) {
        let vc = LoginBuilder.standard(context: nc)
            .buildLogInWithEmail(withSource: source,
                                 loginAction: logicAction,
                                 cancelAction: cancelAction)
        nc.pushViewController(vc, animated: true)
    }
    
    func showRememberPassword(source: EventParameterLoginSourceValue, email: String?) {
        let vc = RememberPasswordBuilder.standard(nc).buildRememberPassword(withSource: source, andEmail: email)
        nc.pushViewController(vc, animated: true)
    }
    
    func showAlert(withTitle title: String?,
                   andBody body: String,
                   andType type: AlertType,
                   andActions actions: [UIAction]) {
        
    }
    
    func showRecaptcha(action: LoginActionType, delegate: RecaptchaTokenDelegate) {
        let vc = RecaptchaBuilder.modal(nc).buildRecaptcha(
            action: action, delegate: delegate)
        nc.present(vc, animated: true)
    }
    
    func open(url: URL) {
        nc.openInAppWebViewWith(url: url)
    }

    func close() {
        nc.popViewController(animated: true, completion: nil)
    }
    
    func close(onFinish callback: (()->())? = nil) {
        nc.popViewController(animated: true)
        callback?()
    }
}