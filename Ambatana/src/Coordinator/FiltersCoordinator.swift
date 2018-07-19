import Foundation
import LGCoreKit
import LGComponents

final class FiltersCoordinator: Coordinator {
    
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController {
        return navigationController
    }
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager
    
    fileprivate var navigationController = UINavigationController()
    
    // MARK: Lifecycle
    
    convenience init(viewModel: FiltersViewModel) {
        self.init(bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager,
                  viewModel: viewModel)
    }
    
    init(bubbleNotificationManager: BubbleNotificationManager,
          sessionManager: SessionManager,
          viewModel: FiltersViewModel) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        
        viewModel.navigator = self
        let vc = FiltersViewController(viewModel: viewModel)
        viewModel.delegate = vc
        let navVC = UINavigationController(rootViewController: vc)
        navigationController = navVC
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

// MARK: - FiltersNavigator

extension FiltersCoordinator: FiltersNavigator {
    func openEditLocation(withViewModel viewModel: EditLocationViewModel) {
        let vc = EditLocationViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openCarAttributeSelection(withViewModel viewModel: CarAttributeSelectionViewModel) {
        let vc = CarAttributeSelectionViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openTaxonomyList(withViewModel viewModel: TaxonomiesViewModel) {
        let vc = TaxonomiesViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openServicesDropdown(viewModel: DropdownViewModel) {
        let vc = DropdownViewController(withViewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func closeFilters() {
        closeCoordinator(animated: true, completion: nil)
    }
}

