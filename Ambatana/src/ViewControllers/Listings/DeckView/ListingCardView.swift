import Foundation
import UIKit
import RxSwift
import LGCoreKit
import LGComponents

protocol ListingCardViewDelegate: class {
    func cardViewDidTapOnStatusView(_ cardView: ListingCardView)
<<<<<<< HEAD
    func cardViewDidTapOnReputationTooltip(_ cardView: ListingCardView)
=======
    func cardViewDidTapOnPreview(_ cardView: ListingCardView)
    func cardViewDidShowMoreInfo(_ cardView: ListingCardView)
    func cardViewDidScroll(_ cardView: ListingCardView, contentOffset: CGFloat)
>>>>>>> master
}

final class ListingCardView: UICollectionViewCell, ReusableCell {
    weak var delegate: ListingCardViewDelegate?

    private let binder = ListingCardViewBinder()

    private let statusView = ProductStatusView()
    private var statusTapGesture: UITapGestureRecognizer?

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    var previewVisibleFrame: CGRect {
        let size = CGSize(width: contentView.width, height: previewImageView.height)
        return CGRect(origin: frame.origin, size: size)
    }

    private var imageDownloader: ImageDownloaderType?
    private(set) var pageCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        binder.cardView = self
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
    }

    func populateWith(cellModel listingViewModel: ListingCardViewCellModel, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        binder.bind(withViewModel: listingViewModel)
    }

    func populateWith(_ listingSnapshot: ListingDeckSnapshotType, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        populateWith(preview: listingSnapshot.preview, imageCount: listingSnapshot.imageCount)
    }

    func populateWith(preview: URL?, imageCount: Int) {
        update(pageCount: imageCount)
        guard let previewURL = preview else { return }
        _ = imageDownloader?.downloadImageWithURL(previewURL) { [weak self] (result, url) in
            if let value = result.value {
                let higherThanWider = value.image.size.height >= value.image.size.width
                DispatchQueue.main.async {
                    self?.previewImageView.contentMode = higherThanWider ? .scaleAspectFill : .scaleAspectFit
                    self?.previewImageView.image = value.image
                    self?.previewImageView.setNeedsDisplay()
                }
            }
        }
    }

    func populateWith(status: ListingViewModelStatus?, featured: Bool) {
        guard let listingStatus = status else {
            statusView.isHidden = true
            return
        }
        statusTapGesture?.isEnabled = featured
        let statusVisible = featured || listingStatus.shouldShowStatus
        statusView.isHidden = !statusVisible
        statusView.setFeaturedStatus(listingStatus, featured: featured)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(pageCount: Int) {
        self.pageCount = pageCount
        // TODO: Update page progress bar
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([previewImageView, statusView])

        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            statusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            statusView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        setupStatusView()

        backgroundColor = .clear
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
    }

    private func setupStatusView() {
        let statusTap = UITapGestureRecognizer(target: self, action: #selector(touchUpStatusView))
        statusView.addGestureRecognizer(statusTap)
        statusTapGesture = statusTap
        statusView.isHidden = true
    }

    @objc private func touchUpStatusView() {
        statusView.bounce { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.cardViewDidTapOnStatusView(strongSelf)
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        contentView.layer.cornerRadius = Metrics.margin
        previewImageView.layer.cornerRadius = Metrics.margin
    }
}
<<<<<<< HEAD
extension ListingCardView: LetgoTooltipDelegate {
    func showReputationTooltip() {
        // TODO: See if this still makes sense
//        guard reputationTooltip == nil else { return }
//        let tooltip = LetgoTooltip()
//        addSubviewForAutoLayout(tooltip)
//        tooltip.setupWith(peakOnTop: false, peakOffsetFromLeft: 40,
//                          message: R.Strings.profileReputationTooltipTitle)
//        tooltip.leftAnchor.constraint(equalTo: userView.leftAnchor, constant: Metrics.veryShortMargin).isActive = true
//        tooltip.bottomAnchor.constraint(equalTo: userView.topAnchor, constant: Metrics.veryBigMargin).isActive = true
//        tooltip.delegate = self
//        reputationTooltip = tooltip
    }

    func hideReputationTooltip() {
        reputationTooltip?.removeFromSuperview()
        reputationTooltip = nil
    }

    func didTapTooltip() {
        hideReputationTooltip()
        delegate?.cardViewDidTapOnReputationTooltip(self)
    }
}
=======
>>>>>>> master
