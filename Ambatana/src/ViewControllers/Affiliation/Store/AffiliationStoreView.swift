import LGComponents

private enum Layout {
    static let interItemSpacing: CGFloat = 35
    static let aspect: CGFloat = 0.74
}

final class AffiliationStoreView: UIView {

    private static let flowLayout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout.init()
        flow.minimumInteritemSpacing = Layout.interItemSpacing
        flow.scrollDirection = .vertical

        let width = min(UIScreen.main.bounds.width - 2*Metrics.bigMargin - 2, 325)
        let height = Layout.aspect * width
        flow.itemSize = CGSize(width: width, height: height)

        flow.sectionInset = UIEdgeInsetsMake(Metrics.bigMargin, Metrics.bigMargin, Metrics.bigMargin, Metrics.bigMargin)
        return flow
    }()

    let collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: AffiliationStoreView.flowLayout)
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = .never
        }
        collection.contentInset = .zero
        return collection
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setupUI() {
        backgroundColor = .white
        collectionView.backgroundColor = .white

        addSubviewsForAutoLayout([collectionView])
        collectionView.constraintToEdges(in: self)

        collectionView.register(type: AffiliationStoreCell.self)
    }
}
