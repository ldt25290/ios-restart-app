import LGCoreKit
import LGComponents

final class BulkPostingListingsView: UIView {

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 18
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 75, height: 75)
        return UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 75), collectionViewLayout: layout)
    }()

    private let listingsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()

    var images: [URL?]

    init(images: [URL?]) {
        self.images = images
        super.init(frame: CGRect(x: 0, y: 0, width: 300, height: 75))

        setupUI()
        collectionView.reloadData()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func setupUI() {
        listingsLabel.text = R.Strings.productPostCameraBulkPostingItemsLabel(images.count)

        collectionView.register(BulkPostingCell.self, forCellWithReuseIdentifier: BulkPostingCell.reusableID)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self

        addSubviewsForAutoLayout([listingsLabel, collectionView])
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: listingsLabel.topAnchor),
            leadingAnchor.constraint(equalTo: listingsLabel.leadingAnchor),
            trailingAnchor.constraint(equalTo: listingsLabel.trailingAnchor),

            listingsLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -Metrics.margin),
            leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
}

extension BulkPostingListingsView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BulkPostingCell.reusableID, for: indexPath) as? BulkPostingCell else {
            return UICollectionViewCell()
        }
        cell.setupWith(imageURL: images[indexPath.row])
        return cell
    }
}
