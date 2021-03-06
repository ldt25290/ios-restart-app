import UI

final class ProductDescriptionViewController: ViewController {

  private let productDescriptionView = ProductDescriptionView()
  private let viewBinder: ProductDescriptionViewBinder

  var viewModel: ProductDescriptionViewModelType!

  init(viewBinder: ProductDescriptionViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }

  override func loadView() {
    self.view = productDescriptionView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.input.viewWillAppear()
    productDescriptionView.becomeFirstResponder()
  }

  override func bindViewModel() {
    viewBinder.bind(view: productDescriptionView, to: viewModel, using: bag)
  }
}
