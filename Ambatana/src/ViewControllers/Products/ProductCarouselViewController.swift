//
//  ProductCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class ProductCarouselViewController: BaseViewController {
    
    var collectionView: UICollectionView
    
    
    // MARK: - Init
    
    init(viewModel: ProductCarouselViewModel) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        setupUI()
        addSubviews()
    }
    
    func addSubviews() {
        view.addSubview(collectionView)
    }
    
    func setupUI() {
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(ProductCarouselCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor.greenColor()
        collectionView.alwaysBounceHorizontal = true
        automaticallyAdjustsScrollViewInsets = false

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        collectionView.collectionViewLayout = layout
    }
}


extension ProductCarouselViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItemsInSection(0) {
            let nextIndexPath = NSIndexPath(forItem: newIndexRow, inSection: 0)
            collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .Right, animated: true)
        } else {
            showRubberBandEffect()
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {}
    
    func showRubberBandEffect() {
        let originalOffset = collectionView.contentOffset
        var newOffset = originalOffset
        newOffset.x += 35
        
        UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseOut, animations: { [weak self] in
            self?.collectionView.contentOffset = newOffset
            }, completion: { _ in
                UIView.animateWithDuration(0.15, delay: 0.05, options: .CurveEaseIn, animations: {
                    self.collectionView.contentOffset = originalOffset
                    }, completion: nil)
        })
    }
}

extension ProductCarouselViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as?
            ProductCarouselCell else { return UICollectionViewCell() }
        cell.backgroundColor = StyleHelper.productCellImageBgColor
        return cell
    }
}

extension ProductCarouselViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return view.bounds.size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}
