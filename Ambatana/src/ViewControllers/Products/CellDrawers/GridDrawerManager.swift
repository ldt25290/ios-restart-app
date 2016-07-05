//
//  GridCellDrawerFactory.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import LGCoreKit

class GridDrawerManager {
    
    var productDrawer = ProductCellDrawer()
    var bannerDrawer = BannerCellDrawer()
    
    func registerCell(inCollectionView collectionView: UICollectionView) {
        ProductCellDrawer.registerCell(collectionView)
        BannerCellDrawer.registerCell(collectionView)
    }
    
    func cell(model: ProductCellModel, collectionView: UICollectionView, atIndexPath: NSIndexPath) -> UICollectionViewCell {
        switch model {
        case .BannerCell:
            return bannerDrawer.cell(collectionView, atIndexPath: atIndexPath)
        case .ProductCell:
            return productDrawer.cell(collectionView, atIndexPath: atIndexPath)
        }
    }
    
    func draw(model: ProductCellModel, inCell cell: UICollectionViewCell) {
        switch model {
            
        case .BannerCell(let data) where cell is ProductCell:
            guard let cell = cell as? ProductCell else { return }
            return bannerDrawer.draw(data, inCell: cell)
            
        case .ProductCell(let product) where cell is ProductCell:
            guard let cell = cell as? ProductCell else { return }
            return productDrawer.draw(product.cellData, inCell: cell)
        
        default:
            assert(false, "⛔️ You shouldn't be here!")
        }
    }
}


private extension Product {
    var cellData: ProductData {
        return ProductData(productID: objectId, thumbUrl: thumbnail?.fileURL)
    }
}
