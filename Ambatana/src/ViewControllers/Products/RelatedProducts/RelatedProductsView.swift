//
//  RelatedProductsView.swift
//  LetGo
//
//  Created by Eli Kohen on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import RxCocoa


protocol RelatedProductsViewDelegate: class {
    func relatedProductsViewDidShow(view: RelatedProductsView)
    func relatedProductsView(view: RelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?)

}


class RelatedProductsView: UIView {

    private static let defaultProductsDiameter: CGFloat = 100
    private static let elementsMargin: CGFloat = 10
    private static let itemsSpacing: CGFloat = 5

    let productId = Variable<String?>(nil)
    let hasProducts = Variable<Bool>(false)

    weak var delegate: RelatedProductsViewDelegate?

    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let productsDiameter: CGFloat

    private var requester: ProductListRequester?
    private var objects: [ProductCellModel] = []
    private let drawerManager = GridDrawerManager()

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience override init(frame: CGRect) {
        self.init(productsDiameter: RelatedProductsView.defaultProductsDiameter, frame: frame)
    }

    init(productsDiameter: CGFloat, frame: CGRect) {
        self.productsDiameter = productsDiameter
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        self.productsDiameter = RelatedProductsView.defaultProductsDiameter
        super.init(coder: aDecoder)
        setup()
    }


    // MARK: - Private

    private func setup() {
        backgroundColor = UIColor.clearColor()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        setupCollection()

        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        let views = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil,
            views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil,
            views: views))
    }

    private func setupRx() {
        productId.asObservable().bindNext{ [weak self] productId in
             guard let productId = productId else {
                self?.hasProducts.value = false
                self?.objects = []
                self?.collectionView.reloadData()
                return
            }
            self?.loadProducts(productId)
        }.addDisposableTo(disposeBag)
        hasProducts.asObservable().map { !$0 }.bindTo(self.rx_hidden).addDisposableTo(disposeBag)
    }
}


// MARK: - UICollectionView

extension RelatedProductsView: UICollectionViewDelegate, UICollectionViewDataSource {

    private func setupCollection() {
        drawerManager.cellStyle = .Small
        drawerManager.registerCell(inCollectionView: collectionView)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: RelatedProductsView.elementsMargin, bottom: 0,
                                                   right: RelatedProductsView.elementsMargin)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            layout.itemSize = CGSize(width: productsDiameter, height: productsDiameter)
            layout.minimumInteritemSpacing = RelatedProductsView.itemsSpacing
        }
    }

    private func itemAtIndex(index: Int) -> ProductCellModel? {
        guard 0..<objects.count ~= index else { return nil }
        return objects[index]
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            guard let item = itemAtIndex(indexPath.row) else { return UICollectionViewCell() }
            let cell = drawerManager.cell(item, collectionView: collectionView, atIndexPath: indexPath)
            drawerManager.draw(item, inCell: cell)
            cell.tag = indexPath.hash
            return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let item = itemAtIndex(indexPath.row) else { return }
        switch item {
        case let .ProductCell(product):
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ProductCell
            let thumbnailImage = cell?.thumbnailImageView.image

            var originFrame: CGRect? = nil
            if let cellFrame = cell?.frame {
                originFrame = superview?.convertRect(cellFrame, fromView: collectionView)
            }
            guard let requester = requester else { return }
            delegate?.relatedProductsView(self, showProduct: product, atIndex: indexPath.row,
                                          productListModels: objects, requester: requester,
                                          thumbnailImage: thumbnailImage, originFrame: originFrame)
        case .CollectionCell, .EmptyCell:
            // No banners or collections here
            break
        }
    }
}


// MARK: - Data handling

private extension RelatedProductsView {

    func loadProducts(productId: String) {
        requester = RelatedProductListRequester(productId: productId, itemsPerPage: Constants.numProductsPerPageDefault)
        requester?.retrieveFirstPage { [weak self] result in
            if let products = result.value where !products.isEmpty {
                let productCellModels = products.map(ProductCellModel.init)
                self?.objects = productCellModels
            } else {
                self?.objects = []
            }
            self?.collectionView.reloadData()
            self?.hasProducts.value = !(self?.objects.isEmpty ?? true)
        }
    }
}
