import UIKit
import LGComponents

class SellListingCell: UICollectionViewCell, ReusableCell {

    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var iconImageView : UIImageView!
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var activity : UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupEmptyCell() {
        iconImageView.image = UIImage()
        self.label.isHidden = true
        self.activity.isHidden = true
        self.activity.stopAnimating()
        self.imageView.image = UIImage()
        self.backgroundColor = UIColor.grayLight
    }
    
    func setupLoadingCell() {
        iconImageView.image = UIImage()
        self.label.isHidden = true
        self.activity.isHidden = false
        self.activity.startAnimating()
        self.imageView.image = UIImage()
    }

    func setupCellWithMediaType(_ type: EditListingMediaType) {
        switch type {
        case .local(let image):
            setupCellWithImage(image)
        case .remote(let media):
            setupCellWithUrl(media.outputs.imageThumbnail)
        }
    }
    
    func setupCellWithImage(_ image: UIImage) {
        iconImageView.image = UIImage()
        self.label.isHidden = true
        self.activity.isHidden = true
        self.activity.stopAnimating()
        imageView.image = image
    }

    func setupCellWithUrl(_ url: URL?) {
        guard let url = url else { return }
        setupLoadingCell()
        imageView.lg_setImageWithURL(url, placeholderImage: nil, completion: { [weak self] (_, _) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.activity.stopAnimating()
            strongSelf.activity.isHidden = true
            }
        )
    }

    func setupAddPictureCell() {
        self.label.isHidden = false
        label.text = R.Strings.sellPictureLabel.localizedUppercase
        label.textColor = UIColor.red
        self.activity.isHidden = true
        iconImageView.image = R.Asset.IconsButtons.icAddWhite.image.imageWithColor(UIColor.red)?.withRenderingMode(.alwaysOriginal)
        imageView.image = UIImage()
        self.backgroundColor = UIColor.white
    }
}


// MARK: fancy highlight

extension SellListingCell {
    func highlight() {
        self.backgroundColor = UIColor.secondaryColorHighlighted
        perform(#selector(resetBgColor), with: nil, afterDelay: 0.2)
    }

    @objc private func resetBgColor() {
        self.backgroundColor = UIColor.white
    }
}
