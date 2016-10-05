//
//  BubbleNotification.swift
//  LetGo
//
//  Created by Dídac on 18/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class BubbleNotification: UIView {

    static let buttonHeight: CGFloat = 30
    static let buttonMaxWidth: CGFloat = 150
    static let bubbleContentMargin: CGFloat = 14
    static let statusBarHeight: CGFloat = 20

    private var containerView = UIView()
    private var textlabel = UILabel()
    private var infoTextLabel = UILabel()
    private var actionButton = UIButton(type: .Custom)

    var bottomConstraint = NSLayoutConstraint()

    private var text: String?
    private var action: UIAction?


    // - Lifecycle

    convenience init(text: String?, action: UIAction?) {
        self.init()
        self.text = text
        self.action = action
        setupConstraints()
        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupOnView(parentView: UIView) {
        // bubble constraints
        let bubbleLeftConstraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal,
                                                      toItem: parentView, attribute: .Left, multiplier: 1, constant: 0)
        let bubbleRightConstraint = NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal,
                                                       toItem: parentView, attribute: .Right, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal,
                                                     toItem: parentView, attribute: .Top, multiplier: 1, constant: 0)
        parentView.addConstraints([bubbleLeftConstraint, bubbleRightConstraint, bottomConstraint])
    }

    func showBubble() {
        // delay to let the setup build the view properly
        delay(0.1) { [weak self] in
            self?.bottomConstraint.constant = self?.height ?? 0
            UIView.animateWithDuration(0.3) { self?.layoutIfNeeded() }
        }
    }

    func removeBubble() {
        self.removeFromSuperview()
    }

    func closeBubble() {
        self.bottomConstraint.constant = 0
        UIView.animateWithDuration(0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self ] _ in
            self?.removeBubble()
        }
    }


    // MARK : - Private methods

    private func setupUI() {
        backgroundColor = UIColor.white
        textlabel.numberOfLines = 0
        textlabel.textColor = UIColor.blackText
        textlabel.font = UIFont.mediumBodyFont
        textlabel.text = text
        if let action = action {
            actionButton.setStyle(.Secondary(fontSize: .Small, withBorder: true))
            actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
            actionButton.titleLabel?.minimumScaleFactor = 0.8
            actionButton.setTitle(action.text, forState: .Normal)
            actionButton.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
            actionButton.accessibilityId =  action.accessibilityId
        }
    }

    dynamic private func buttonTapped() {
        guard let action = action else { return }
        action.action()
        closeBubble()
    }

    private func setupConstraints() {

        containerView.translatesAutoresizingMaskIntoConstraints = false
        textlabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(textlabel)
        containerView.addSubview(actionButton)

        var views = [String: AnyObject]()
        views["container"] = containerView
        views["label"] = textlabel
        views["infoLabel"] = infoTextLabel
        views["button"] = actionButton

        var metrics = [String: AnyObject]()
        metrics["margin"] = BubbleNotification.bubbleContentMargin
        metrics["marginWStatus"] = BubbleNotification.bubbleContentMargin + BubbleNotification.statusBarHeight
        metrics["buttonWidth"] = CGFloat(action != nil ? BubbleNotification.buttonMaxWidth : 0)

        // container view
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginWStatus-[container]-margin-|",
            options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[container]-margin-|",
            options: [], metrics: metrics, views: views))

        // text label and button
        actionButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|",
            options: [], metrics: metrics, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]-[button(<=buttonWidth)]-|",
            options: [.AlignAllCenterY], metrics: metrics, views: views))
        actionButton.addConstraint(NSLayoutConstraint(item: actionButton, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BubbleNotification.buttonHeight))

        layoutIfNeeded()
    }
}
