//
//  UserViewHeader.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

protocol UserViewHeaderDelegate: class {
    func headerAvatarAction()
    func ratingsAvatarAction()
    func buildTrustAction()
}

enum UserViewHeaderMode {
    case MyUser, OtherUser
}

enum UserViewHeaderTab: Int {
    case Selling, Sold, Favorites
}

class UserViewHeader: UIView {
    private static let bgViewMaxHeight: CGFloat = 165

    private static let simpleButtonWidth: CGFloat = 22
    private static let simpleContainerHeight: CGFloat = 28
    private static let simpleContainerEmptyHeight: CGFloat = 20
    private static var halfWidthScreen: CGFloat {
        return UIScreen.mainScreen().bounds.width / 2
    }

    private static let ratingCountContainerLeadingVisible: CGFloat = 15
    private static let ratingCountContainerTrailingVisible: CGFloat = 20

    private static let buildTrustButtonSmallHeight: CGFloat = 30
    private static let buildTrustButtonBigHeight: CGFloat = 44
    private static let buildTrustSeparatorSpace: CGFloat = 30
    private static let buildTrustButtonInsetSmall: CGFloat = 10
    private static let buildTrustButtonInsetBig: CGFloat = 15
    private static let buildTrustButtonTitleInset: CGFloat = 10

    @IBOutlet weak var avatarRatingsContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    var avatarBorderLayer: CAShapeLayer?
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var avatarRatingsEffectView: UIVisualEffectView!
    @IBOutlet weak var ratingCountContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var ratingCountContainerTrailing: NSLayoutConstraint!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var ratingsButton: UIButton!

    @IBOutlet weak var infoView: UIView!

    @IBOutlet weak var userRelationView: UIView!
    @IBOutlet weak var userRelationLabel: UILabel!

    @IBOutlet weak var verifiedSimpleContainer: UIView!
    @IBOutlet weak var verifiedSimpleContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var verifiedSimpleContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var verifiedSimpleTitle: UILabel!

    @IBOutlet weak var simpleFacebookButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var simpleGoogleButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var simpleEmailButtonWidth: NSLayoutConstraint!

    @IBOutlet weak var buildTrustSeparator: UIView!
    @IBOutlet weak var buildTrustButton: UIButton!
    @IBOutlet weak var buildTrustButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var buildTrustContainerButtonWidth: NSLayoutConstraint!

    @IBOutlet weak var sellingButton: UIButton!
    @IBOutlet weak var sellingButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorViewLeadingConstraint: NSLayoutConstraint!

    weak var delegate: UserViewHeaderDelegate?

    let tab = Variable<UserViewHeaderTab>(.Selling)

    var mode: UserViewHeaderMode = .MyUser {
        didSet {
            modeUpdated()
        }
    }

    var buildTrustButtonVisible: Bool {
        guard mode.buildTrustMode else { return false }
        guard let accounts = accounts else { return true }
        return !(accounts.emailVerified && accounts.facebookVerified && accounts.googleVerified)
    }

    var accounts: UserViewHeaderAccounts? {
        didSet {
            updateInfoAndAccountsVisibility()
        }
    }

    var selectedColor: UIColor = UIColor.redColor() {
        didSet {
            indicatorView.backgroundColor = selectedColor
            setupButtonsSelectedState()
        }
    }

    var collapsed: Bool = false {
        didSet {
            guard oldValue != collapsed else { return }
            let alpha: CGFloat = collapsed ? 0 : 1
            UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState],
                                       animations: { [weak self] in
                self?.avatarRatingsContainerView.alpha = alpha
                self?.userRelationView.alpha = alpha
                self?.verifiedSimpleContainer.alpha = alpha
            }, completion: nil)

            avatarButton.enabled = !collapsed
            ratingsButton.enabled = !collapsed
        }
    }

    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    static func userViewHeader() -> UserViewHeader? {
        guard let view = NSBundle.mainBundle().loadNibNamed("UserViewHeader", owner: self,
            options: nil).first as? UserViewHeader else { return nil }
        view.setupUI()
        view.setupRxBindings()
        return view
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if mode.showSelling {
            let currentWidth = sellingButtonWidthConstraint.multiplier * frame.width
            let halfWidth = 0.5 * frame.width
            sellingButtonWidthConstraint.constant = halfWidth - currentWidth
        } else {
            sellingButtonWidthConstraint.constant = 0
        }

        updateUI()
    }
}


// MARK: - Public methods

extension UserViewHeader {

    func setAvatar(url: NSURL?, placeholderImage: UIImage?) {
        if let url = url {
            avatarImageView.lg_setImageWithURL(url, placeholderImage: placeholderImage)
        } else {
            avatarImageView.image = placeholderImage
        }
    }

    func setRatingCount(ratingCount: Int?) {
        let hidden = (ratingCount ?? 0) <= 0
        ratingCountLabel.text = hidden ? nil : String(ratingCount ?? 0)
        ratingsLabel.text = hidden ? nil : LGLocalizedString.profileReviewsCount
        avatarRatingsEffectView.hidden = hidden
        ratingCountContainerLeading.constant = hidden ? 0 : UserViewHeader.ratingCountContainerLeadingVisible
        ratingCountContainerTrailing.constant = hidden ? 0 : UserViewHeader.ratingCountContainerTrailingVisible
    }

    func setUserRelationText(userRelationText: String?) {
        userRelationLabel.text = userRelationText
        updateInfoAndAccountsVisibility()
    }

    private func modeUpdated() {
        verifiedSimpleContainer.hidden = false
        if mode.showSelling {
            let currentWidth = sellingButtonWidthConstraint.multiplier * frame.width
            let halfWidth = 0.5 * frame.width
            sellingButtonWidthConstraint.constant = halfWidth - currentWidth
        } else {
            sellingButtonWidthConstraint.constant = 0
        }
        updateInfoAndAccountsVisibility()
    }

    private func updateInfoAndAccountsVisibility() {
        let fbL = accounts?.facebookLinked ?? false
        let fbV = accounts?.facebookVerified ?? false
        setFacebookAccount(fbL, isVerified: fbV)
        let gL = accounts?.googleLinked ?? false
        let gV = accounts?.googleVerified ?? false
        setGoogleAccount(gL, isVerified: gV)
        let eL = accounts?.emailLinked ?? false
        let eV = accounts?.emailVerified ?? false
        setEmailAccount(eL, isVerified: eV)

        var infoViewHidden: Bool
        var verifiedViewHidden: Bool
        if let userRelationText = userRelationLabel.text {
            infoViewHidden = userRelationText.isEmpty
            verifiedViewHidden = !userRelationText.isEmpty
        } else if let _ = accounts {
            infoViewHidden = true
            verifiedViewHidden = false
        } else {
            infoViewHidden = true
            verifiedViewHidden = false
        }
        userRelationView.hidden = infoViewHidden
        verifiedSimpleContainer.hidden = verifiedViewHidden
        let anyAccountVerified = fbV || gV || eV
        verifiedSimpleTitle.text = anyAccountVerified ? LGLocalizedString.profileVerifiedAccountsOtherUser : ""
        verifiedSimpleContainerHeight.constant = anyAccountVerified ? UserViewHeader.simpleContainerHeight : UserViewHeader.simpleContainerEmptyHeight
    

        if buildTrustButtonVisible {
            buildTrustSeparator.hidden = !anyAccountVerified
            buildTrustContainerButtonWidth.constant = anyAccountVerified ? 0 : UserViewHeader.halfWidthScreen
            verifiedSimpleContainerWidth.constant = anyAccountVerified ? 0 : -UserViewHeader.halfWidthScreen
            updateBuildTrustButton(big: !anyAccountVerified)
        } else {
            buildTrustSeparator.hidden = true
            buildTrustContainerButtonWidth.constant = -UserViewHeader.halfWidthScreen
            verifiedSimpleContainerWidth.constant = UserViewHeader.halfWidthScreen
            buildTrustButtonHeight.constant = 0
        }
    }

    private func setFacebookAccount(isLinked: Bool, isVerified: Bool) {
        let on = isLinked && isVerified
        simpleFacebookButtonWidth.constant = on ? UserViewHeader.simpleButtonWidth : 0
        
    }

    private func setGoogleAccount(isLinked: Bool, isVerified: Bool) {
        let on = isLinked && isVerified
        simpleGoogleButtonWidth.constant = on ? UserViewHeader.simpleButtonWidth : 0
       
    }

    private func setEmailAccount(isLinked: Bool, isVerified: Bool) {
        let on = isLinked && isVerified
        simpleEmailButtonWidth.constant = on ? UserViewHeader.simpleButtonWidth : 0
    }
}


// MARK: - Private methods
// MARK: > UI

extension UserViewHeader {
    private func setupUI() {
        setupInfoView()
        setupAvatarRatingsContainerView()
        setupVerifiedViews()
        setupButtons()
    }

    private func updateUI() {
        updateAvatarRatingsContainerView()
        updateUserAvatarView()
    }

    private func setupInfoView() {
        userRelationView.hidden = true
        userRelationLabel.font = UIFont.smallBodyFont
        userRelationLabel.textColor = UIColor.primaryColor
    }

    private func setupAvatarRatingsContainerView() {
        let gradient = CAGradientLayer.gradientWithColor(UIColor.whiteColor(), alphas:[0.0,1.0],
                                                         locations: [0.0,1.0])
        gradient.frame = avatarRatingsEffectView.bounds
        avatarRatingsEffectView.layer.addSublayer(gradient)

        ratingCountLabel.font = UIFont.systemLightFont(size: 24)
        ratingCountLabel.textColor = UIColor.black
        ratingsLabel.font = UIFont.systemRegularFont(size: 13)
        ratingsLabel.textColor = UIColor.grayDark
    }

    private func setupVerifiedViews() {

        verifiedSimpleContainer.hidden = true
        verifiedSimpleTitle.text = nil
        verifiedSimpleTitle.textColor = UIColor.grayDark
        verifiedSimpleTitle.font = UIFont.mediumBodyFontLight

        buildTrustButton.setTitle(LGLocalizedString.profileBuildTrustButton, forState: .Normal)
    }

    private func setupButtons() {
        var attributes = [String : AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont.inactiveTabFont

        let sellingTitle = NSAttributedString(string: LGLocalizedString.profileSellingProductsTab.uppercase,
            attributes: attributes)
        sellingButton.setAttributedTitle(sellingTitle, forState: .Normal)


        let soldTitle = NSAttributedString(string: LGLocalizedString.profileSoldProductsTab.uppercase,
            attributes: attributes)
        soldButton.setAttributedTitle(soldTitle, forState: .Normal)

        let favsTitle = NSAttributedString(string: LGLocalizedString.profileFavouritesProductsTab.uppercase,
            attributes: attributes)
        favoritesButton.setAttributedTitle(favsTitle, forState: .Normal)

        setupButtonsSelectedState()
    }

    private func updateAvatarRatingsContainerView() {
        let height = avatarRatingsContainerView.bounds.height
        avatarRatingsContainerView.layer.cornerRadius = height / 2
    }

    private func updateUserAvatarView() {
        let width = min(avatarImageView.bounds.width, avatarImageView.bounds.height)
        let path = UIBezierPath(arcCenter: CGPointMake(avatarImageView.bounds.midX, avatarImageView.bounds.midY),
                                radius: width / 2, startAngle: CGFloat(0.0), endAngle: CGFloat(M_PI * 2.0),
                                clockwise: true)
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        avatarImageView.layer.mask = mask

        let borderLayer = CAShapeLayer()
        borderLayer.path = path.CGPath
        borderLayer.lineWidth = 2 * UIScreen.mainScreen().scale
        borderLayer.strokeColor = UIColor.whiteColor().CGColor
        borderLayer.fillColor = nil

        avatarBorderLayer?.removeFromSuperlayer()
        avatarImageView.layer.addSublayer(borderLayer)
        avatarBorderLayer = borderLayer
    }

    private func setupButtonsSelectedState() {
        var attributes = [String : AnyObject]()
        attributes[NSForegroundColorAttributeName] = selectedColor
        attributes[NSFontAttributeName] = UIFont.activeTabFont

        let sellingTitle = NSAttributedString(string: LGLocalizedString.profileSellingProductsTab.uppercase,
            attributes: attributes)
        sellingButton.setAttributedTitle(sellingTitle, forState: .Selected)


        let soldTitle = NSAttributedString(string: LGLocalizedString.profileSoldProductsTab.uppercase,
            attributes: attributes)
        soldButton.setAttributedTitle(soldTitle, forState: .Selected)

        let favsTitle = NSAttributedString(string: LGLocalizedString.profileFavouritesProductsTab.uppercase,
            attributes: attributes)
        favoritesButton.setAttributedTitle(favsTitle, forState: .Selected)
    }

    private func setIndicatorAtTab(tab: UserViewHeaderTab, animated: Bool) {
        let leading = CGFloat(tab.rawValue) * sellingButton.frame.width
        indicatorViewLeadingConstraint.constant = leading
        if animated {
            UIView.animateWithDuration(0.15) { [weak self] in
                self?.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    private func updateBuildTrustButton(big big: Bool) {
        buildTrustButtonHeight.constant = big ? UserViewHeader.buildTrustButtonBigHeight : UserViewHeader.buildTrustButtonSmallHeight
        buildTrustButton.setStyle(.Secondary(fontSize: big ? .Medium : .Small, withBorder: true))
        let inset = big ? UserViewHeader.buildTrustButtonInsetBig : UserViewHeader.buildTrustButtonInsetSmall
        buildTrustButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0,
                                                          right: inset+UserViewHeader.buildTrustButtonTitleInset)
        buildTrustButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: UserViewHeader.buildTrustButtonTitleInset,
                                                        bottom: 0, right: -UserViewHeader.buildTrustButtonTitleInset)
        buildTrustButton.layer.cornerRadius = buildTrustButtonHeight.constant / 2
        buildTrustButton.setImage(UIImage(named: big ? "ic_build_trust" : "ic_build_trust_small"), forState: .Normal)
    }
}


// MARK: > Rx

extension UserViewHeader {
    
    private func setupRxBindings() {
        setupButtonsRxBindings()
        setupAccountsRxBindings()
    }

    private func setupButtonsRxBindings() {
        avatarButton.rx_tap.subscribeNext { [weak self] _ in
            self?.delegate?.headerAvatarAction()
        }.addDisposableTo(disposeBag)

        ratingsButton.rx_tap.subscribeNext { [weak self] _ in
            self?.delegate?.ratingsAvatarAction()
        }.addDisposableTo(disposeBag)

        sellingButton.rx_tap.subscribeNext { [weak self] _ in
            self?.tab.value = .Selling
        }.addDisposableTo(disposeBag)

        soldButton.rx_tap.subscribeNext { [weak self] _ in
            self?.tab.value = .Sold
        }.addDisposableTo(disposeBag)

        favoritesButton.rx_tap.subscribeNext { [weak self] _ in
            self?.tab.value = .Favorites
        }.addDisposableTo(disposeBag)

        tab.asObservable().map { $0 == .Selling }.bindTo(sellingButton.rx_selected).addDisposableTo(disposeBag)
        tab.asObservable().map { $0 == .Sold }.bindTo(soldButton.rx_selected).addDisposableTo(disposeBag)
        tab.asObservable().map { $0 == .Favorites }.bindTo(favoritesButton.rx_selected).addDisposableTo(disposeBag)

        tab.asObservable().skip(1).subscribeNext { [weak self] tab in
            self?.setIndicatorAtTab(tab, animated: true)
        }.addDisposableTo(disposeBag)
    }

    private func setupAccountsRxBindings() {
        buildTrustButton.rx_tap.bindNext { [weak self] in
            self?.delegate?.buildTrustAction()
        }.addDisposableTo(disposeBag)
    }
}


private extension UserViewHeaderMode {
    
    var showSelling: Bool {
        switch self {
        case .MyUser:
            return false
        case .OtherUser:
            return true
        }
    }

    var buildTrustMode: Bool {
        switch self {
        case .MyUser:
            return true
        case .OtherUser:
            return false
        }
    }
}
