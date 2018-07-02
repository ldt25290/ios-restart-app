import Foundation
import LGComponents

protocol UserProfileHeaderDelegate: class {
    func didTapEditAvatar()
    func didTapAvatar()
}

enum UserHeaderViewBadge {
    case noBadge
    case silver
    case gold
    case pro

    init(userBadge: UserReputationBadge) {
        switch userBadge {
        case .noBadge: self = .noBadge
        case .silver: self = .silver
        case .gold : self = .gold
        }
    }
}

final class UserProfileHeaderView: UIView {
    let ratingView = RatingView(layout: .normal)
    let locationLabel = UILabel()
    let memberSinceLabel = UILabel()
    private let userNameLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let editAvatarButton = UIButton()
    private let verifiedBadgeImageView = UIImageView()
    private let proBadgeImageView = UIImageView()
    private var locationLabelTopConstraint: NSLayoutConstraint?
    weak var delegate: UserProfileHeaderDelegate?

    let isPrivate: Bool

    private struct Layout {
        static let verticalMargin: CGFloat = 5.0
        static let imageHeight: CGFloat = 110.0
        static let verifiedBadgeHeight: CGFloat = 30
        static let editAvatarButtonHeight: CGFloat = 44
        static let editAvatarButtonRightInset: CGFloat = 7
        static let editAvatarButtonTopInset: CGFloat = 4
        static let proBadgeHeight: CGFloat = 20
        static let proBadgeWidth: CGFloat = 50
    }

    init(isPrivate: Bool) {
        self.isPrivate = isPrivate
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var userBadge: UserHeaderViewBadge = .noBadge {
        didSet {
            updateBadge()
        }
    }

    var username: String? {
        didSet {
            userNameLabel.text = username
            userNameLabel.truncateWordsWithDotsIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userNameLabel.truncateWordsWithDotsIfNeeded()
    }

    private func setupView() {
        addSubviewsForAutoLayout([userNameLabel, ratingView, locationLabel, memberSinceLabel, avatarImageView,
                                  editAvatarButton, verifiedBadgeImageView, proBadgeImageView])

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = .grayLight
        avatarImageView.layer.cornerRadius = Layout.imageHeight / 2
        avatarImageView.clipsToBounds = true

        userNameLabel.font = .profileUserHeadline
        userNameLabel.textColor = .lgBlack
        userNameLabel.numberOfLines = 1

        locationLabel.font = .smallButtonFont
        locationLabel.textColor = .lgBlack

        memberSinceLabel.font = .mediumBodyFont
        memberSinceLabel.textColor = .grayDark
        editAvatarButton.isHidden = !isPrivate
        editAvatarButton.addTarget(self, action: #selector(didTapEditAvatar), for: .touchUpInside)

        verifiedBadgeImageView.image = R.Asset.IconsButtons.icKarmaBadgeActive.image
        verifiedBadgeImageView.contentMode = .scaleAspectFit
        verifiedBadgeImageView.isHidden = true

        proBadgeImageView.image = R.Asset.IconsButtons.icProTagWithShadow.image
        proBadgeImageView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        proBadgeImageView.contentMode = .scaleAspectFit
        proBadgeImageView.isHidden = true
    }

    private func setupConstraints() {
        let constraints = [
            userNameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            userNameLabel.topAnchor.constraint(equalTo: topAnchor),
            userNameLabel.rightAnchor.constraint(equalTo: avatarImageView.leftAnchor, constant: -Layout.verticalMargin),

            ratingView.leftAnchor.constraint(equalTo: leftAnchor),
            ratingView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: Layout.verticalMargin),

            locationLabel.leftAnchor.constraint(equalTo: leftAnchor),
            locationLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: Layout.verticalMargin),
            locationLabel.rightAnchor.constraint(lessThanOrEqualTo: avatarImageView.leftAnchor, constant: -Layout.verticalMargin),

            memberSinceLabel.leftAnchor.constraint(equalTo: leftAnchor),
            memberSinceLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: Layout.verticalMargin),

            avatarImageView.rightAnchor.constraint(equalTo: rightAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.imageHeight),
            avatarImageView.widthAnchor.constraint(equalToConstant: Layout.imageHeight),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            editAvatarButton.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: -Layout.editAvatarButtonTopInset),
            editAvatarButton.rightAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: Layout.editAvatarButtonRightInset),
            editAvatarButton.heightAnchor.constraint(equalToConstant: Layout.editAvatarButtonHeight),
            editAvatarButton.widthAnchor.constraint(equalToConstant: Layout.editAvatarButtonHeight),

            verifiedBadgeImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            verifiedBadgeImageView.rightAnchor.constraint(equalTo: avatarImageView.rightAnchor),
            verifiedBadgeImageView.heightAnchor.constraint(equalToConstant: Layout.verifiedBadgeHeight),
            verifiedBadgeImageView.widthAnchor.constraint(equalToConstant: Layout.verifiedBadgeHeight),

            proBadgeImageView.centerYAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            proBadgeImageView.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            proBadgeImageView.heightAnchor.constraint(equalToConstant: Layout.proBadgeHeight),
            proBadgeImageView.widthAnchor.constraint(equalToConstant: Layout.proBadgeWidth),
        ]
        NSLayoutConstraint.activate(constraints)

        locationLabelTopConstraint = locationLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor,
                                                                        constant: Layout.verticalMargin)
        locationLabelTopConstraint?.isActive = true
    }

    private func setupAccessibilityIds() {
        userNameLabel.set(accessibilityId: .userHeaderExpandedNameLabel)
        locationLabel.set(accessibilityId: .userHeaderExpandedLocationLabel)
        memberSinceLabel.set(accessibilityId: .userHeaderExpandedMemberSinceLabel)
        avatarImageView.set(accessibilityId: .userHeaderExpandedAvatar)
        editAvatarButton.set(accessibilityId: .userHeaderExpandedAvatarButton)
    }

    func setAvatar(_ url: URL?, placeholderImage: UIImage?) {
        if let url = url {
            avatarImageView.lg_setImageWithURL(url)
            editAvatarButton.setImage(R.Asset.IconsButtons.userProfileEditAvatar.image, for: .normal)
        } else {
            avatarImageView.image = placeholderImage
            editAvatarButton.setImage(R.Asset.IconsButtons.userProfileAddAvatar.image, for: .normal)
        }
    }

    func setUser(hasRatings: Bool) {
        ratingView.isHidden = !hasRatings

        locationLabelTopConstraint?.isActive = false
        locationLabelTopConstraint = locationLabel.topAnchor
            .constraint(equalTo: (hasRatings ? ratingView : userNameLabel).bottomAnchor,
                        constant: Layout.verticalMargin)
        locationLabelTopConstraint?.isActive = true
    }

    private func updateBadge() {
        let showVerifiedBadge = userBadge == .silver || userBadge == .gold
        let showProBadge = userBadge == .pro
        verifiedBadgeImageView.isHidden = !showVerifiedBadge
        proBadgeImageView.isHidden = !showProBadge
    }

    @objc private func didTapEditAvatar() {
        delegate?.didTapEditAvatar()
    }
}
