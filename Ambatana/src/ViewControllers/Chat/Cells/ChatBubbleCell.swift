//
//  ChatBubbleCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

class ChatBubbleCell: UITableViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatBubbleCell.menuControllerWillHide(_:)),
            name: UIMenuControllerWillHideMenuNotification, object: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    func setupUI() {
        bubbleView.layer.cornerRadius = StyleHelper.defaultCornerRadius
        messageLabel.font = StyleHelper.chatCellMessageFont
        dateLabel.font = StyleHelper.chatCellTimeFont
        
        messageLabel.textColor = StyleHelper.chatCellMessageColor
        dateLabel.textColor = StyleHelper.chatCellTimeColor
        
        StyleHelper.applyDefaultShadow(bubbleView.layer)
        bubbleView.layer.shouldRasterize = true
        bubbleView.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    func menuControllerWillHide(notification: NSNotification) {
        setSelected(false, animated: true)
    }
    
    func resetUI() {}
}
