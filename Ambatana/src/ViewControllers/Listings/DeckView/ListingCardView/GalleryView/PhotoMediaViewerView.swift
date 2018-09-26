import RxSwift
import RxCocoa

final class PhotoMediaViewerView: UIView {
    fileprivate let collectionView: UICollectionView
    private let delegate = PhotoMediaViewerDelegate()
    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = frame.size
        let collection = UICollectionView(frame: frame, collectionViewLayout: flowLayout)

        collection.isPagingEnabled = true
        collection.isScrollEnabled = false
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.allowsSelection = false
        collection.delegate = delegate
        collectionView = collection

        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    func reset() {
        collectionView.setContentOffset(.zero, animated: false)
    }

    func reloadData() {
        collectionView.reloadData()
    }

    func set(viewModel: PhotoMediaViewerViewModel) {
        disposeBag = DisposeBag()
        collectionView.dataSource = viewModel.datasource
        viewModel.rx.index.drive(rx.index).disposed(by: disposeBag)
    }

    private func setupUI() {
        addSubviewForAutoLayout(collectionView)
        [
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ].activate()

        collectionView.register(type: ListingCarouselImageCell.self)
        collectionView.register(type: ListingCarouselVideoCell.self)
    }
}

extension Reactive where Base: PhotoMediaViewerView {
    var index: Binder<Int> {
        return Binder(self.base) { view, index in
            view.collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                             at: .centeredHorizontally,
                                             animated: true)
        }
    }
}