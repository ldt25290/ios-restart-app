import UI
import Domain

final class ProductSelectorViewController: ViewController {

  var viewModel: ProductSelectorViewModelType!
  
  private let productSelectorView = ProductSelectorView()
  private let viewBinder: ProductSelectorViewBinder
  
  init(viewBinder: ProductSelectorViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  override func loadView() {
    self.view = productSelectorView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    productSelectorView.becomeFirstResponder()
  }
  
  override func bindViewModel() {
    viewBinder.bind(view: productSelectorView, to: viewModel, using: bag)
  }
}
