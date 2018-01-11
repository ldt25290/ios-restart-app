//
//  ChatListingView.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol ChatListingViewDelegate: class {
    func listingViewDidTapUserAvatar()
    func listingViewDidTapListingImage()
}

class ChatListingView: UIView {
    override var intrinsicContentSize: CGSize { return UILayoutFittingExpandedSize }
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var listingName: UILabel!
    @IBOutlet weak var listingPrice: UILabel!
    @IBOutlet weak var listingImage: UIImageView!
    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var listingButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    let imageHeight: CGFloat = 64
    let imageWidth: CGFloat = 64
    let margin: CGFloat = 8
    let labelHeight: CGFloat = 20
    let separatorHeight: CGFloat = 0.5
    weak var delegate: ChatListingViewDelegate?
    

    static func chatListingView() -> ChatListingView {
        guard let view = Bundle.main.loadNibNamed("ChatListingView", owner: self, options: nil)?.first as? ChatListingView
            else { return ChatListingView() }
        view.setupUI()
        view.setAccessibilityIds()
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
    }
    
    func setupUI() {
        listingImage.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        listingImage.backgroundColor = UIColor.placeholderBackgroundColor()
        userName.font = UIFont.chatListingViewUserFont
        listingName.font = UIFont.chatListingViewNameFont
        listingPrice.font = UIFont.chatListingViewPriceFont
        
        userAvatar.layer.minificationFilter = kCAFilterTrilinear
    }

    func disableListingInteraction() {
        listingName.alpha = 0.3
        listingPrice.alpha = 0.3
        listingImage.alpha = 0.3
        listingButton.isEnabled = false
    }

    func disableUserProfileInteraction() {
        userAvatar.alpha = 0.3
        userName.alpha = 0.3
        userButton.isEnabled = false
    }
    
    // MARK: - Actions

    @IBAction func listingButtonPressed(_ sender: AnyObject) {
        delegate?.listingViewDidTapListingImage()
    }
    
    @IBAction func userButtonPressed(_ sender: AnyObject) {
        delegate?.listingViewDidTapUserAvatar()
    }
}


// MARK: - Accessibility

extension ChatListingView {
    func setAccessibilityIds() {
        userName.accessibilityId = .chatListingViewUserNameLabel
        userAvatar.accessibilityId = .chatListingViewUserAvatar
        listingName.accessibilityId = .chatListingViewListingNameLabel
        listingPrice.accessibilityId = .chatListingViewListingPriceLabel
        listingButton.accessibilityId = .chatListingViewListingButton
        userButton.accessibilityId = .chatListingViewUserButton
    }
}