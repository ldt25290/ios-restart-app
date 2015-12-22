//
//  ProductPostedViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class ProductPostedViewController: BaseViewController, SellProductViewController, ProductPostedViewModelDelegate {

    weak var delegate: SellProductViewControllerDelegate?

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var mainIconImage: UIImageView!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var secondaryTextLabel: UILabel!

    // Share container: hidden on this version //TODO: Remove if not used in further versions
    @IBOutlet weak var shareContainer: UIView!
    @IBOutlet weak var shareContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var socialShareView: SocialShareView!
    @IBOutlet weak var shareItLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!

    // Edit Container
    @IBOutlet weak var editContainer: UIView!
    @IBOutlet weak var editContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var editOrLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var mainButton: UIButton!

    // ViewModel
    private var viewModel: ProductPostedViewModel!


    // MARK: - View lifecycle

    convenience init(viewModel: ProductPostedViewModel) {
        self.init(viewModel: viewModel, nibName: "ProductPostedViewController")
    }

    required init(viewModel: ProductPostedViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        viewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.onViewLoaded()
        setupView()
    }


    // MARK: - IBActions

    @IBAction func onCloseButton(sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @IBAction func onMainButton(sender: AnyObject) {
        viewModel.mainActionPressed()
    }

    @IBAction func onSharebutton(sender: AnyObject) {
        shareButtonPressed()
    }
    
    @IBAction func onEditButton(sender: AnyObject) {
        //TODO: LAUNCH EDIT
    }

    // MARK: - ProductPostedViewModelDelegate

    func productPostedViewModelDidFinishPosting(viewModel: ProductPostedViewModel, correctly: Bool) {
        dismissViewControllerAnimated(true) { [weak self] in
            self?.delegate?.sellProductViewController(self, didCompleteSell: correctly)
        }
    }

    func productPostedViewModelDidRestartPosting(viewModel: ProductPostedViewModel) {
        dismissViewControllerAnimated(true) { [weak self] in
            self?.delegate?.sellProductViewControllerDidTapPostAgain(self)
        }
    }


    // MARK: - Private methods

    private func setupView() {

        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        mainButton.setPrimaryStyle()
        editButton.setSecondaryStyle()

        shareItLabel.text = LGLocalizedString.productPostConfirmationShare.uppercaseString
        orLabel.text = LGLocalizedString.productPostConfirmationAnother.uppercaseString
        editOrLabel.text = LGLocalizedString.productPostConfirmationAnother.uppercaseString
        editButton.setTitle(LGLocalizedString.productPostConfirmationEdit, forState: UIControlState.Normal)

        mainTextLabel.text = viewModel.mainText
        secondaryTextLabel.text = viewModel.secondaryText
        mainButton.setTitle(viewModel.mainButtonText, forState: UIControlState.Normal)

        if !viewModel.success {
            editContainer.hidden = true
            editContainerHeight.constant = 0
            shareButton.hidden = true
        }
    }

    private func shareButtonPressed() {
        guard let shareInfo = viewModel.shareInfo else { return }

        let activityItems: [AnyObject] = [shareInfo.shareText]
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
        // src: http://stackoverflow.com/questions/25759380/launchservices-invalidationhandler-called-ios-8-share-sheet
        if vc.respondsToSelector("popoverPresentationController") {
            let presentationController = vc.popoverPresentationController
            presentationController?.sourceView = self.view
        }

        vc.completionWithItemsHandler = {
            (activity, success, items, error) in


            guard success else {
                //In case of cancellation just do nothing -> success == false && error == nil
                guard error != nil else { return }

                self.showAutoFadingOutMessageAlert(LGLocalizedString.productShareGenericError)
                return
            }

            if activity == UIActivityTypePostToFacebook {
                self.viewModel.shareInFacebook()
                self.viewModel.shareInFacebookFinished(.Completed)
            } else if activity == UIActivityTypePostToTwitter {
                self.viewModel.shareInTwitter()
            } else if activity == UIActivityTypeMail {
                self.viewModel.shareInEmail()
            } else if activity != nil && activity!.rangeOfString("whatsapp") != nil {
                self.viewModel.shareInWhatsApp()
            }

            self.showAutoFadingOutMessageAlert(LGLocalizedString.productShareGenericOk)
        }

        presentViewController(vc, animated: true, completion: nil)
    }
}


// MARK: - SocialShareViewDelegate

extension ProductPostedViewController: SocialShareViewDelegate {

    func shareInEmail(){
        viewModel.shareInEmail()
    }

    func shareInFacebook() {
        viewModel.shareInFacebook()
    }

    func shareInFacebookFinished(state: SocialShareState) {
        viewModel.shareInFacebookFinished(state)
    }

    func shareInFBMessenger() {
        viewModel.shareInFBMessenger()
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
        viewModel.shareInFBMessengerFinished(state)
    }

    func shareInWhatsApp() {
        viewModel.shareInWhatsApp()
    }

    func viewController() -> UIViewController? {
        return self
    }
}


