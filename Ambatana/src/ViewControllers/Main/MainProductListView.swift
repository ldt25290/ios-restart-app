//
//  MainProductListView.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class MainProductListView: ProductListView {
    
    // View Model
    var mainProductListViewModel: MainProductListViewModel
    
    
    // MARK: - Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        self.mainProductListViewModel = MainProductListViewModel()
        
        super.init(viewModel: mainProductListViewModel, coder: aDecoder)
        mainProductListViewModel.delegate = self
    }


    // MARK: - Public methods

    public func sessionDidChange() {
        mainProductListViewModel.sessionDidChange()
    }
    
    
    // MARK: - ProductListViewModelDataDelegate
    
    public override func vmDidSucceedRetrievingProductsPage(page: UInt,
        hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {
            
            // If it's the first page with no results
            if page == 0 && !hasProducts {
                
                // Set the error state
                let errBgColor = UIColor(patternImage: UIImage(named: "pattern_white")!)
                let errBorderColor = StyleHelper.lineColor
                let errContainerColor: UIColor = StyleHelper.emptyViewContentBgColor
                let errImage: UIImage?
                let errTitle: String?
                let errBody: String?
                
                // Search
                if viewModel.queryString != nil || viewModel.hasFilters {
                    errImage = UIImage(named: "err_search_no_products")
                    errTitle = LGLocalizedString.productSearchNoProductsTitle
                    errBody = LGLocalizedString.productSearchNoProductsBody
                } else {
                    // Listing
                    errImage = UIImage(named: "err_list_no_products")
                    errTitle = LGLocalizedString.productListNoProductsTitle
                    errBody = LGLocalizedString.productListNoProductsBody
                }
                
                mainProductListViewModel.state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor,
                                   errContainerColor: errContainerColor, errImage: errImage, errTitle: errTitle,
                                   errBody: errBody, errButTitle: nil, errButAction: nil)
            } else {
                // Otherwise (has results), let super work
                super.vmDidSucceedRetrievingProductsPage(page, hasProducts: hasProducts,
                    atIndexPaths: indexPaths)
            }
    }
    
    public override func vmDidFailRetrievingProductsPage(page: UInt,
        hasProducts: Bool, error: RepositoryError) {

        defer {
            super.vmDidFailRetrievingProductsPage(page, hasProducts: hasProducts, error: error)
        }

        guard page == 0 && !hasProducts else { return }

        // If it's the first page & we have no data
        // Set the error state
        let errBgColor: UIColor?
        let errBorderColor: UIColor?
        let errContainerColor: UIColor = StyleHelper.emptyViewContentBgColor
        let errImage: UIImage?
        let errTitle: String?
        let errBody: String?
        let errButTitle: String?
        let errButAction: (() -> Void)?

        switch error {
        case .Network:
            errImage = UIImage(named: "err_network")
            errTitle = LGLocalizedString.commonErrorTitle
            errBody = LGLocalizedString.commonErrorNetworkBody
            errButTitle = LGLocalizedString.commonErrorRetryButton
        case .Internal, .Unauthorized, .NotFound:
            errImage = UIImage(named: "err_generic")
            errTitle = LGLocalizedString.commonErrorTitle
            errBody = LGLocalizedString.commonErrorGenericBody
            errButTitle = LGLocalizedString.commonErrorRetryButton
        }
        errBgColor = UIColor(patternImage: UIImage(named: "pattern_white")!)
        errBorderColor = StyleHelper.lineColor

        errButAction = {
            self.refresh()
        }

        mainProductListViewModel.state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor,
                           errContainerColor: errContainerColor,errImage: errImage, errTitle: errTitle,
                           errBody: errBody, errButTitle: errButTitle, errButAction: errButAction)
    }
}