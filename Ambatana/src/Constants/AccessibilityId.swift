//
//  AccessibilityId.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
 Defines the accessibility identifiers used for automated UI testing. The format is the following:
    case <screen><element-name>
 
 i.e:
    case SignUpLoginEmailButton
 */
enum AccessibilityId: String {
    case EraseMe

    /** ABIOS-1554 */

    // Main Products List
    case MainProductsNavBarSearch
    case MainProductsFilterButton
    case MainProductsListView
    case MainProductsTagsCollection
    case MainProductsInfoBubbleLabel
    case MainProductsTrendingSearchesTable

    // Product List View
    case ProductListViewFirstLoadView
    case ProductListViewFirstLoadActivityIndicator
    case ProductListViewCollection
    case ProductListViewErrorView
    case ProductListErrorImageView
    case ProductListErrorTitleLabel
    case ProductListErrorBodyLabel
    case ProductListErrorButton

    // Product Cell
    case ProductCell
    case ProductCellPriceLabel
    case ProductCellThumbnailImageView
    case ProductCellLikeButton
    case ProductCellShareButton
    case ProductCellChatButton
    case ProductCellStripeImageView
    case ProductCellStripeLabel
    case ProductCellStripeIcon

    // Collection & Banner Cells
    case CollectionCell
    case CollectionCellImageView
    case CollectionCellTitle
    case CollectionCellExploreButton

    case BannerCell
    case BannerCellImageView
    case BannerCellTitle

    // Filter Tags VC
    case FilterTagsCollectionView
    case FilterTagCell
    case FilterTagCellTagIcon
    case FilterTagCellTagLabel

    // Categories
    case CategoriesActivityIndicator
    case CategoriesCollectionView
    case CategoryCell
    case CategoryCellTitleLabel
    case CategoryCellImageView

    /** ABIOS-1555 */
    // ...

    /** ABIOS-1556 */
    // ...

    /** ABIOS-1557 */
    // ...
}

extension UIAccessibilityIdentification {
    var accessibilityId: AccessibilityId? {
        get {
            guard let accessibilityIdentifier = accessibilityIdentifier else { return nil }
            return AccessibilityId(rawValue: accessibilityIdentifier)
        }
        set {
            accessibilityIdentifier = newValue?.rawValue
        }
    }
}
