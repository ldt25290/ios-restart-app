//
//  PostingCategoriesPickViewModel.swift
//  LetGo
//
//  Created by Dídac on 08/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol PostingCategoriesPickDelegate: class {
    func didSelectCategory(category: ListingCategory)
}

class PostingCategoriesPickViewModel: BaseViewModel {

    var backButtonImage: UIImage? {
        return #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate)
    }

    var titleText: String {
        return LGLocalizedString.postDescriptionCategoryTitle
    }

    var categoriesCount: Int {
        return categories.count
    }

    var selectedCategory: ListingCategory?
    let categories: [ListingCategory] = ListingCategory.visibleValuesInFeed(servicesIncluded: false,
                                                                            realEstateIncluded: false)

    weak var delegate: PostingCategoriesPickDelegate?
    weak var navigator: BlockingPostingNavigator?

    init(selectedCategory: ListingCategory?) {
        self.selectedCategory = selectedCategory
        super.init()
    }

    func categoryNameForCellAtIndexPath(indexPath: IndexPath) -> String? {
        let position: Int = indexPath.row
        guard categoriesCount > position, position >= 0 else { return nil }
        return categories[position].name
    }

    func selectCategoryAtIndexPath(indexPath: IndexPath) {
        let position: Int = indexPath.row
        guard categoriesCount > position, position >= 0 else { return }
        delegate?.didSelectCategory(category: categories[position])
        navigator?.closeCategoriesPicker()
    }

    func categorySelectedForIndexPath(indexPath: IndexPath) -> Bool {
        let position: Int = indexPath.row
        guard let category = selectedCategory, categoriesCount > position, position >= 0 else { return false }
        return categories[position] == category
    }

    func closeCategoriesPicker() {
        navigator?.closeCategoriesPicker()
    }
}