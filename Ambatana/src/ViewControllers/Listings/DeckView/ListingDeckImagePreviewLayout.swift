//
//  ListingDeckImagePreviewLayout.swift
//  LetGo
//
//  Created by Facundo Menzella on 08/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class ListingDeckImagePreviewLayout: UICollectionViewFlowLayout {

    private var cellSize: CGSize { return collectionView?.bounds.size ?? CGSize(width: 40, height: 80) }

    override init() {
        super.init()
        self.scrollDirection = .horizontal
        itemSize = cellSize
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepare() {
        super.prepare()
        itemSize = cellSize
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
