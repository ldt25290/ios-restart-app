import UIKit

protocol ListingAttributeGridViewDelegate: class {
    func didSelect(item: ListingAttributeGridItem)
    func didDeselect(item: ListingAttributeGridItem)
}

final class ListingAttributeGridView: UIView {
    
    private struct Layout {
        static let interItemSpacing: CGFloat = 15.0
        static let lineSpacing: CGFloat = 15.0
        static let defaultItemsPerRow: Int = 4
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.minimumInteritemSpacing = Layout.interItemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing

        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    private let itemsPerRow: Int
    private var items: [ListingAttributeGridItem]
    
    weak var delegate: ListingAttributeGridViewDelegate?
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame,
                  itemsPerRow: Layout.defaultItemsPerRow,
                  items: [])
    }
    
    init(frame: CGRect,
         itemsPerRow: Int,
         items: [ListingAttributeGridItem]) {
        self.itemsPerRow = itemsPerRow
        self.items = items
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    func setup(withItems items: [ListingAttributeGridItem],
               selectedItems: [ListingAttributeGridItem]) {
        self.items = items
        collectionView.reloadData()
        applySelectedItems(selectedItems: selectedItems)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applySelectedItems(selectedItems: [ListingAttributeGridItem]) {
        let indexes = selectedItems.map({ selectedItem in
            return items.index(where: { $0.value == selectedItem.value })
        }).flatMap( { $0 } )
            .map( { IndexPath(item: $0, section: 0) } )
        
        for index in indexes {
            collectionView.selectItem(at: index,
                                      animated: false,
                                      scrollPosition: UICollectionViewScrollPosition.top)
        }
    }
    
    private func setupUI() {
        backgroundColor = .white
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(type: ListingAttributeGridViewItemCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupConstraints() {
        addSubviewForAutoLayout(collectionView)
        
        collectionView.layout(with: self)
            .fillVertical()
            .fillHorizontal()
    }
    
    static func height(forItemCount itemCount: Int,
                       maxItemsPerRow: Int = Layout.defaultItemsPerRow,
                       inContainerWidth containerWidth: CGFloat) -> CGFloat {
        let numRows = CGFloat(CGFloat(itemCount)/CGFloat(maxItemsPerRow)).rounded(.up)
        let lineSpacing: CGFloat = (numRows-1)*Layout.lineSpacing
        let cellHeight: CGFloat = cellSize(forContainerWidth: containerWidth,
                                           withItemsPerRow: maxItemsPerRow).height
        return (cellHeight*numRows)+lineSpacing
    }
}


// MARK: - UICollectionViewDatasource Implementation

extension ListingAttributeGridView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let item = items[safeAt: indexPath.row],
            let cell = collectionView.dequeue(type: ListingAttributeGridViewItemCell.self,
                                              for: indexPath) else {
                                                return UICollectionViewCell()
        }
        
        let isSelected: Bool = collectionView.indexPathsForSelectedItems?
            .contains(where: { $0 == indexPath }) ?? false
        
        cell.setup(withItem: item,
                   isSelected: isSelected)
        return cell
    }
}


// MARK: - UICollectionViewDelegate Implementation

extension ListingAttributeGridView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ListingAttributeGridViewItemCell,
            let item = items[safeAt: indexPath.row] else { return }
        delegate?.didSelect(item: item)
        cell.updateSelectedState(isSelected: true,
                                 performSelectionAnimation: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ListingAttributeGridViewItemCell,
            let item = items[safeAt: indexPath.row] else { return }
        delegate?.didDeselect(item: item)
        cell.updateSelectedState(isSelected: false)
    }
}


// MARK: - UICollectionViewDelegteFlowLayout Implementation

extension ListingAttributeGridView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ListingAttributeGridView.cellSize(forContainerWidth: collectionView.width,
                                                 withItemsPerRow: itemsPerRow)
    }
    
    private static func cellSize(forContainerWidth containerWidth: CGFloat,
                                 withItemsPerRow itemsPerRow: Int) -> CGSize {
        let totalInterItemSpacings: CGFloat = Layout.interItemSpacing * CGFloat(max(1, itemsPerRow-1))
        let width = (containerWidth-totalInterItemSpacings)/CGFloat(itemsPerRow)
        return CGSize(width: width,
                      height: width)
    }
}