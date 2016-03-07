//
//  SocialShareView.swift
//  LetGo
//
//  Created by Eli Kohen on 15/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FBSDKShareKit
import MessageUI

public enum SocialShareState {
    case Completed
    case Cancelled
    case Failed
}

protocol SocialShareViewDelegate: class {
    func shareInEmail()
    func shareInFacebook()
    func shareInFacebookFinished(state: SocialShareState)
    func shareInFBMessenger()
    func shareInFBMessengerFinished(state: SocialShareState)
    func shareInWhatsApp()
    func viewController() -> UIViewController?
}

@IBDesignable
class SocialShareView: UIView {

    private static let buttonsSide: CGFloat = 56

    var view: UIView!
    @IBOutlet weak var fbMessengerButton: UIButton!
    @IBOutlet weak var fbMessengerWidth: NSLayoutConstraint!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var facebookWidth: NSLayoutConstraint!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailWidth: NSLayoutConstraint!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var whatsappWidth: NSLayoutConstraint!

    weak var delegate: SocialShareViewDelegate?

    var socialMessage: SocialMessage? {
        didSet {
            checkAllowedButtons()
        }
    }


    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    override func intrinsicContentSize() -> CGSize {
        let width = fbMessengerWidth.constant + whatsappWidth.constant + facebookWidth.constant + emailWidth.constant
        let height = SocialShareView.buttonsSide
        return CGSize(width: width, height: height)
    }


    // MARK: - IBActions

    @IBAction func onShareFbMessenger(sender: AnyObject) {
        guard let socialMessage = socialMessage else { return }

        delegate?.shareInFBMessenger()
        SocialHelper.shareOnFbMessenger(socialMessage, delegate: self)
    }

    @IBAction func onShareFacebook(sender: AnyObject) {
        guard let socialMessage = socialMessage else { return }
        guard let viewController = delegate?.viewController() else { return }
        delegate?.shareInFacebook()
        SocialHelper.shareOnFacebook(socialMessage, viewController: viewController, delegate: self)
    }

    @IBAction func onShareEmail(sender: AnyObject) {
        guard let viewController = delegate?.viewController() else { return }
        guard let socialMessage = socialMessage else { return }
        delegate?.shareInEmail()
        SocialHelper.shareOnEmail(socialMessage, viewController: viewController, delegate: self)
    }

    @IBAction func onShareWhatsapp(sender: AnyObject) {
        guard let socialMessage = socialMessage else { return }
        guard let viewController = delegate?.viewController() else { return }
        delegate?.shareInWhatsApp()
        SocialHelper.shareOnWhatsapp(socialMessage, viewController: viewController)
    }


    // MARK: - Private methods

    private func xibSetup() {

        if view != nil {
            //Alrady initialized
            return
        }

        backgroundColor = UIColor.clearColor()
        view = loadViewFromNib()

        // Adding custom subview on top of our view
        addSubview(view)

        let views = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil,
            views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil,
            views: views))

        checkAllowedButtons()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: SocialShareView.self)
        return bundle.loadNibNamed("SocialShareView", owner: self, options: nil).first as! UIView
    }

    private func checkAllowedButtons() {
        fbMessengerWidth.constant = canShareInFBMessenger() ? SocialShareView.buttonsSide : 0
        whatsappWidth.constant = canShareInWhatsapp() ? SocialShareView.buttonsSide : 0
    }

    func generateWhatsappURL() -> NSURL? {
        guard let socialMessage = socialMessage else { return nil }
        return SocialHelper.generateWhatsappURL(socialMessage)
    }

    private func canShareInWhatsapp() -> Bool {
        return SocialHelper.canShareInWhatsapp()
    }

    private func canShareInFBMessenger() -> Bool {
        return SocialHelper.canShareInFBMessenger()
    }
}


// MARK: - FBSDKSharingDelegate

extension SocialShareView: FBSDKSharingDelegate {

    public func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {

        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFacebookFinished(.Completed)
        case .FBMessenger:
            // Messenger always calls didCompleteWithResults, if it works,
            // will include the key "completionGesture" in the results dict
            if let _ = results["completionGesture"] {
                delegate?.shareInFBMessengerFinished(.Completed)
            }
            else {
                delegate?.shareInFBMessengerFinished(.Cancelled)
            }
        case .Unknown:
            break
        }
    }

    public func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFBMessengerFinished(.Failed)
        case .FBMessenger:
            delegate?.shareInFBMessengerFinished(.Failed)
        case .Unknown:
            break
        }
    }

    public func sharerDidCancel(sharer: FBSDKSharing!) {
        switch (sharer.type) {
        case .Facebook:
            delegate?.shareInFBMessengerFinished(.Cancelled)
        case .FBMessenger:
            delegate?.shareInFBMessengerFinished(.Cancelled)
        case .Unknown:
            break
        }
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension SocialShareView: MFMailComposeViewControllerDelegate {
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult
        result: MFMailComposeResult, error: NSError?) {
            var message: String? = nil
            if result.rawValue == MFMailComposeResultFailed.rawValue {
                message = LGLocalizedString.productShareEmailError
            } else if result.rawValue == MFMailComposeResultSent.rawValue {
                message = LGLocalizedString.productShareGenericOk
            }

            controller.dismissViewControllerAnimated(true, completion: { [weak self] in
                guard let message = message else { return }
                self?.delegate?.viewController()?.showAutoFadingOutMessageAlert(message)
            })
    }
}

