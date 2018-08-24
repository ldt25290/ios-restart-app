import UIKit
import LGCoreKit
import SwiftyGif
import LGComponents

private struct InterestedLayout {
    static let width: CGFloat = 54
    static let edges = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: Metrics.veryShortMargin)
}

protocol ListingCellDelegate: class {
    func chatButtonPressedFor(listing: Listing)
    func editPressedForDiscarded(listing: Listing)
    func moreOptionsPressedForDiscarded(listing: Listing)
    func postNowButtonPressed(_ view: UIView)
    func interestedActionFor(_ listing: Listing, userListing: LocalUser?, completion: @escaping (InterestedState) -> Void)
    func openAskPhoneFor(_ listing: Listing, interlocutor: LocalUser)
    func getUserInfoFor(_ listing: Listing, completion: @escaping (User?) -> Void)
    func bumpUpPressedFor(listing: Listing)
}

final class ListingCell: UICollectionViewCell, ReusableCell {
    private struct Layout {
        static let stripWidth: CGFloat = 70
        static let extraInfoTrailing: CGFloat = 30
    }
    
    private let featureFlags: FeatureFlaggeable
    
    private lazy var interestedButton: UIButton = UIButton()
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .white)

    private let ribbonView = LGRibbonView()
    
    // > Thumbnail Image and background
    
    private let thumbnailBgColorView = UIView()
    private let thumbnailImageView = UIImageView()
    private let thumbnailGifImageView = UIImageView()
    
    // > Product Detail related Views
    
    private let featuredListingInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let featuredListingChatButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.frame = CGRect(x: 0, y: 0, width: 0, height: LGUIKitConstants.mediumButtonHeight)
        button.setStyle(.primary(fontSize: .medium))
        return button
    }()
    
    private var featureView: ProductPriceAndTitleView?
    
    private let detailViewInImage: ProductPriceAndTitleView = {
        let view = ProductPriceAndTitleView()
        view.isHidden = true
        return view
    }()

    private let bumpUpIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.Asset.Monetization.icLightning.image
        return imageView
    }()

    private let bumpUpLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 15)
        label.text = R.Strings.bumpUpProductCellFeatureItLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .blackText
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let extraInfoTagView: ExtraInfoTagView = ExtraInfoTagView(withColour: .white)

    private let bumpUpContainer = UIView()

    
    // > Distance Labels
    
    private let  bottomDistanceInfoView: DistanceInfoView = {
        let view = DistanceInfoView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    private let topDistanceInfoView: DistanceInfoView = {
        let view = DistanceInfoView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    // > Discarded Views
    
    private let discardedView: DiscardedView = {
        let view = DiscardedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var detailViewInImageHeightConstraints: NSLayoutConstraint?
    private var thumbnailImageViewHeight: NSLayoutConstraint?

    var listing: Listing?
    weak var delegate: ListingCellDelegate?
    
    var likeButtonEnabled: Bool = true
    var chatButtonEnabled: Bool = true
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1.0
        }
    }
    
    var thumbnailImage: UIImage? {
        let image: UIImage?
        if thumbnailImageView.image != nil {
            image = thumbnailImageView.image
        } else {
            image = thumbnailGifImageView.currentImage
        }
        return image
    }
    
    // MARK:- Lifecycle
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        self.featureFlags = FeatureFlags.sharedInstance
        super.init(frame: frame)
        setupUI()
        contentView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        resetUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    // MARK: - Public / internal methods
    
    func setupBackgroundColor(id: String?) {
        thumbnailBgColorView.backgroundColor = UIColor.placeholderBackgroundColor(id)
    }
    
    func setupImageUrl(_ imageUrl: URL, imageSize: CGSize, preventMessagesToPro: Bool) {
        thumbnailImageViewHeight?.constant = imageSize.height
        thumbnailImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
            [weak self] (result, url) -> Void in
            if let (_, cached) = result.value, !cached {
                self?.thumbnailImageView.alpha = 0
                UIView.animate(withDuration: 0.4, animations: { self?.thumbnailImageView.alpha = 1 })
            }
        })
        setupInterestedButton(inside: thumbnailImageView, preventMessagesToPro: preventMessagesToPro)
    }
    
    func setupGifUrl(_ imageUrl: URL, imageSize: CGSize, preventMessagesToPro: Bool) {
        thumbnailImageViewHeight?.constant = imageSize.height
        thumbnailGifImageView.setGifFromURL(imageUrl, showLoader: false)
        
        guard interestedButton.superview != thumbnailGifImageView else { return }
        interestedButton.removeFromSuperview()
        setupInterestedButton(inside: thumbnailGifImageView, preventMessagesToPro: preventMessagesToPro)
    }
    
    private func setupInterestedButton(inside view: UIView, preventMessagesToPro: Bool) {
        guard interestedButton.superview != view else { return }
        interestedButton.removeFromSuperview()
        view.addSubviewForAutoLayout(interestedButton)
        view.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            interestedButton.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                    constant: InterestedLayout.edges.right),
            interestedButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                     constant: InterestedLayout.edges.bottom),
            interestedButton.heightAnchor.constraint(equalTo: interestedButton.widthAnchor),
            interestedButton.widthAnchor.constraint(equalToConstant: InterestedLayout.width)
        ])
        interestedButton.removeTarget(self, action: nil, for: .allEvents)
        interestedButton.addTarget(self, action: #selector(interestedButtonTapped), for: .touchUpInside)
        setupActivityIndicator(inside: view, preventMessagesToPro: preventMessagesToPro)
    }
    
    private func setupActivityIndicator(inside view: UIView, preventMessagesToPro: Bool) {
        guard preventMessagesToPro else { return }
        activityIndicator.hidesWhenStopped = true
        activityIndicator.removeFromSuperview()
        view.addSubviewForAutoLayout(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: interestedButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: interestedButton.centerYAnchor)
            ])
    }
    
    func setupFreeStripe() {
        let ribbonConfiguration = LGRibbonConfiguration(title: R.Strings.productFreePrice,
                                                        icon: nil,
                                                        titleColor: .orangeFree)
        ribbonView.setupRibbon(configuration: ribbonConfiguration)
        ribbonView.isHidden = false
    }
    
    func setupFeaturedStripe(withTextColor textColor: UIColor) {
        let ribbonConfiguration = LGRibbonConfiguration(title: R.Strings.bumpUpProductCellFeaturedStripe,
                                                        icon: nil,
                                                        titleColor: textColor)
        ribbonView.setupRibbon(configuration: ribbonConfiguration)
        ribbonView.isHidden = false
    }
    
    // Product Detail Under Image

    func setupFeaturedListingInfo(withPrice price: String,
                                  paymentFrequency: String?,
                                  titleViewModel: ListingTitleViewModel?,
                                  isMine: Bool,
                                  hideProductDetail: Bool,
                                  shouldShowBumpUpCTA: Bool) {
        if shouldShowBumpUpCTA {
            setupBumpUpCTA()
        } else {
            featureView = ProductPriceAndTitleView()
            featureView?.configUI(titleViewModel: titleViewModel,
                                  price: price,
                                  paymentFrequency: paymentFrequency,
                                  style: hideProductDetail ? .whiteText : .darkText)
            setupFeaturedListingChatButton()
            layoutFeatureListArea(isMine: isMine, hideProductDetail: hideProductDetail)
        }
    }
    
    func setupNonFeaturedProductInfoUnderImage(price: String,
                                               paymentFrequency: String?,
                                               titleViewModel: ListingTitleViewModel?,
                                               shouldShow: Bool,
                                               shouldShowBumpUpCTA: Bool) {
        if shouldShowBumpUpCTA {
            setupBumpUpCTA()
        } else {
            if shouldShow {
                featureView = ProductPriceAndTitleView()
                featureView?.configUI(titleViewModel: titleViewModel,
                                      price: price,
                                      paymentFrequency: paymentFrequency,
                                      style: .darkText)
                showDetail()
            }
        }
    }
    
    func setupExtraInfoTag(withText text: String) {
        setupExtraInfoTagView(withText: text)
    }

    func setupBumpUpCTA() {

        bumpUpContainer.addSubviewsForAutoLayout([bumpUpIcon, bumpUpLabel])
        bumpUpIcon.layout(with: bumpUpContainer).left(by: ListingCellMetrics.BumpUpIcon.leftMargin)
        bumpUpIcon.layout().height(ListingCellMetrics.BumpUpIcon.iconHeight).widthProportionalToHeight()
        bumpUpIcon.layout(with: bumpUpLabel).centerY().trailing(to: .leading, by: -ListingCellMetrics.BumpUpIcon.rightMargin)
        bumpUpLabel.layout(with: bumpUpContainer).right(by: -ListingCellMetrics.BumpUpLabel.rightMargin)
            .top()
            .bottom()

        featuredListingInfoView.addSubviewForAutoLayout(bumpUpContainer)
        bumpUpContainer.layout(with: featuredListingInfoView)
            .center()
            .left(relatedBy: .greaterThanOrEqual)
            .right(relatedBy: .lessThanOrEqual)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(bumpUpCTATapped))
        featuredListingInfoView.addGestureRecognizer(tapRecognizer)

        layer.masksToBounds = false
        applyShadow(withOpacity: 1,
                    radius: 4,
                    color: UIColor.black.withAlphaComponent(0.1).cgColor,
                    offset: CGSize(width: 0, height: 2))
    }

    @objc private func bumpUpCTATapped() {
        guard let listing = listing else { return }
        delegate?.bumpUpPressedFor(listing: listing)
    }
    
    // Product Detail In Image
    
    func show(isDiscarded: Bool, reason: String? = nil) {
        discardedView.isHidden = !isDiscarded
        discardedView.set(reason: reason ?? "")
        if !discardedView.isHidden {
            hideDistanceAndDetailViews()
        }
    }
    
    
    // MARK: - Private methods
    
    // > Sets up UI
    private func setupUI() {
        contentView.addSubviewsForAutoLayout([thumbnailBgColorView,
                                              thumbnailImageView,
                                              thumbnailGifImageView,
                                              featuredListingInfoView,
                                              ribbonView,
                                              discardedView,
                                              topDistanceInfoView,
                                              bottomDistanceInfoView,
                                              detailViewInImage])
        setupThumbnailImageViews()
        setupFeaturedListingInfoView()
        setupStripArea()
        setupDiscardedView()
        setupDistanceLabels()
        setupDetailViewInImage()
    }
    
    private func setupDetailViewInImage() {
        detailViewInImage.layout(with: thumbnailImageView)
            .fillHorizontal()
            .bottom()
        detailViewInImageHeightConstraints = detailViewInImage.heightAnchor.constraint(equalToConstant: contentView.height)
        detailViewInImageHeightConstraints?.isActive = true
    }
    
    private func setupThumbnailImageViews() {
        setupThumbnailImageViewUI()
        setupThumbnialImageViewConstraints()
    }
    
    private func setupThumbnailImageViewUI() {
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailGifImageView.clipsToBounds = true
        thumbnailGifImageView.contentMode = .scaleAspectFill
    }
    
    private func setupThumbnialImageViewConstraints() {
        thumbnailImageView.layout(with: contentView).top().leading().trailing()
        thumbnailImageViewHeight = thumbnailImageView.heightAnchor.constraint(equalToConstant: ListingCellMetrics.thumbnailImageStartingHeight)
        thumbnailImageViewHeight?.priority = .required - 1 // required if possible
        thumbnailImageViewHeight?.isActive = true
        thumbnailBgColorView.layout(with: thumbnailImageView).fill()
        thumbnailGifImageView.layout(with: thumbnailImageView).fill()
    }
    
    private func setupFeaturedListingInfoView() {
        featuredListingInfoView.layout(with: contentView).bottom().leading().trailing()
        featuredListingInfoView.layout(with: thumbnailImageView).below()
    }
    
    private func setupStripArea() {
        NSLayoutConstraint.activate([
            ribbonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ribbonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ribbonView.widthAnchor.constraint(equalToConstant: Layout.stripWidth),
            ribbonView.heightAnchor.constraint(equalTo: ribbonView.widthAnchor)
        ])
    }
    
    private func setupDiscardedView() {
        discardedView.editListingCallback = { [weak self] in
            guard let listing = self?.listing else { return }
            self?.delegate?.editPressedForDiscarded(listing: listing)
        }
        discardedView.moreOptionsCallback = { [weak self] in
            guard let listing = self?.listing else { return }
            self?.delegate?.moreOptionsPressedForDiscarded(listing: listing)
        }
        discardedView.layout(with: contentView).fill()
    }
    
    private func setupDistanceLabels() {
        let margin = ListingCellMetrics.DistanceView.margin
        let height = ListingCellMetrics.DistanceView.iconHeight
        topDistanceInfoView.layout(with: thumbnailImageView)
            .fillHorizontal(by: margin)
            .top(by: margin)
        
        bottomDistanceInfoView.layout(with: thumbnailImageView)
            .fillHorizontal(by: margin)
            .bottom(by: -margin)
        
        NSLayoutConstraint.activate([
            topDistanceInfoView.heightAnchor.constraint(equalToConstant: height),
            bottomDistanceInfoView.heightAnchor.constraint(equalToConstant: height)
            ])
    }

    private func setupExtraInfoTagView(withText text: String) {
        extraInfoTagView.removeFromSuperview()
        extraInfoTagView.text = text
        contentView.addSubviewsForAutoLayout([extraInfoTagView])
        let trailing: CGFloat = interestedButton.isHidden ? 0 : Layout.extraInfoTrailing
        NSLayoutConstraint.activate([
            extraInfoTagView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.shortMargin),
            extraInfoTagView.bottomAnchor.constraint(equalTo: featuredListingInfoView.topAnchor, constant: -Metrics.shortMargin),
            extraInfoTagView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -trailing)
            ])
    }
    
    func setupWith(interestedState action: InterestedState) {
        interestedButton.setImage(action.image, for: .normal)
        interestedButton.imageView?.contentMode = .scaleAspectFit
        interestedButton.imageView?.clipsToBounds = true
        interestedButton.isUserInteractionEnabled = action != .none
    }
    
    @objc private func interestedButtonTapped() {
        defer { updateInterestedButton(withState: .send(enabled: false)) }
        guard let listing = listing else { return }
        guard shouldPreventMessagesFromFeedToProUsers(category: listing.category) else {
            return interestActionFor(listing: listing, userListing: nil)
        }
        guard listing.user.type == .unknown else {
            return interestActionFor(listing: listing,
                                userListing: LocalUser(userListing: listing.user))
        }
        
        interestedButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        delegate?.getUserInfoFor(listing) { [weak self] user in
            self?.interestedButton.isHidden = false
            self?.activityIndicator.stopAnimating()
            self?.interestActionFor(listing: listing, userListing: LocalUser(userListing: listing.user))
        }
    }
    
    private func interestActionFor(listing: Listing, userListing: LocalUser?) {
        delegate?.interestedActionFor(listing, userListing: userListing) { [weak self] state in
            self?.updateInterestedButton(withState: state)
        }
    }
    
    private func updateInterestedButton(withState state: InterestedState) {
        interestedButton.setImage(state.image, for: .normal)
        interestedButton.isUserInteractionEnabled = (state != .none && state != .send(enabled: false))
    }
    private func shouldPreventMessagesFromFeedToProUsers(category: ListingCategory) -> Bool {
        guard featureFlags.preventMessagesFromFeedToProUsers.isActive else { return false }
        return category == .realEstate || category == .cars || category == .services
    }
    
    private func layoutFeatureListArea(isMine: Bool, hideProductDetail: Bool) {
        if hideProductDetail {
            showChatButton(isMine: isMine)
        } else {
            showDetailAndChatButton(isMine: isMine)
        }
    }
    
    private func showChatButton(isMine: Bool) {
        if !featuredListingInfoView.subviews.contains(featuredListingChatButton) {
            featuredListingInfoView.addSubviewsForAutoLayout([featuredListingChatButton])
        }
        layoutChatButton(isMine: isMine, isUnderProductDetail: false)
    }
    
    private func showDetailAndChatButton(isMine: Bool) {
        guard let featureView = featureView else { return }
        featuredListingInfoView.addSubviewsForAutoLayout([featureView,
                                                          featuredListingChatButton])
        featureView.layout(with: featuredListingInfoView).top().left().right()
        layoutChatButton(under: featureView, isMine: isMine, isUnderProductDetail: true)
    }
    
    private func showDetail() {
        guard let featureView = featureView else { return }
        featuredListingInfoView.addSubviewsForAutoLayout([featureView])
        featureView.layout(with: featuredListingInfoView).top().leading().trailing().bottom()
    }
    
    private func layoutChatButton(under view: UIView? = nil, isMine: Bool, isUnderProductDetail: Bool) {
        let buttonTopMargin = isMine || isUnderProductDetail ? 0.0 : ListingCellMetrics.ActionButton.topMargin
        let buttonHeight = isMine ? 0.0 : ListingCellMetrics.ActionButton.height
        
        featuredListingChatButton.layout().height(buttonHeight)
        featuredListingChatButton.layout(with: featuredListingInfoView)
            .left(by: ListingCellMetrics.sideMargin)
            .right(by: -ListingCellMetrics.sideMargin)
            .bottom(by: -ListingCellMetrics.ActionButton.bottomMargin)
        if let view = view {
            featuredListingChatButton.layout(with: view).below(by: buttonTopMargin)
        } else {
            featuredListingChatButton.layout(with: featuredListingInfoView).top(by: buttonTopMargin)
        }
    }
    
    // Setup FeatureListingChatButton with feature flags
    private func setupFeaturedListingChatButton() {
        let featureFlags = FeatureFlags.sharedInstance
        if featureFlags.shouldChangeChatNowCopyInTurkey {
            featuredListingChatButton.setTitle(featureFlags.copyForChatNowInTurkey.variantString,
                                               for: .normal)
        } else if featureFlags.shouldChangeChatNowCopyInEnglish {
            featuredListingChatButton.setTitle(featureFlags.copyForChatNowInEnglish.variantString,
                                               for: .normal)
        } else {
            featuredListingChatButton.setTitle(R.Strings.bumpUpProductCellChatNowButton,
                                               for: .normal)
        }
        featuredListingChatButton.addTarget(self, action: #selector(openChat), for: .touchUpInside)
    }
    
    private func hideDistanceAndDetailViews() {
        topDistanceInfoView.isHidden = true
        bottomDistanceInfoView.isHidden = true
        detailViewInImage.isHidden = true
    }
    
    // > Resets the UI to the initial state
    private func resetUI() {
        setupBackgroundColor(id: nil)
        thumbnailGifImageView.clear()
        thumbnailImageView.image = nil
        ribbonView.clear()
        ribbonView.isHidden = true
        detailViewInImage.clearLabelTexts()
        topDistanceInfoView.clearAll()
        bottomDistanceInfoView.clearAll()
        setupWith(interestedState: .none)

        self.delegate = nil
        self.listing = nil
        
        for featuredInfoSubview in featuredListingInfoView.subviews {
            featuredInfoSubview.removeFromSuperview()
        }
        
        extraInfoTagView.removeFromSuperview()
    }
    
    
    // > Accessibility Ids
    private func setAccessibilityIds() {
        thumbnailImageView.set(accessibilityId: .listingCellThumbnailImageView)
        thumbnailGifImageView.set(accessibilityId: .listingCellThumbnailImageView)
        featuredListingChatButton.set(accessibilityId: .listingCellFeaturedChatButton)
    }
    
    
    // MARK: Actions
    
    @objc private func openChat() {
        guard let listing = listing else { return }
        delegate?.chatButtonPressedFor(listing: listing)
    }
}

private extension InterestedState {
    var image: UIImage? {
        switch self {
        case .none: return nil
        case .send(let enabled):
            let alpha: CGFloat = enabled ? 1 : 0.7
            return R.Asset.IconsButtons.IAmInterested.icIamiSend.image.withAlpha(alpha) ?? R.Asset.IconsButtons.IAmInterested.icIamiSend.image
        case .seeConversation: return R.Asset.IconsButtons.IAmInterested.icIamiSeeconv.image
        }
    }
}
