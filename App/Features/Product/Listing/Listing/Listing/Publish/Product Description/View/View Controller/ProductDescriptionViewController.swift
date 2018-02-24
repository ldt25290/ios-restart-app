import UI

final class ProductDescriptionViewController: ViewController {

  private let productDescriptionView = ProductDescriptionView()
  private let viewBinder: ProductDescriptionViewBinder

  var viewModel: ProductDescriptionViewModelType!

  init(viewBinder: ProductDescriptionViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  required public init?(coder aDecoder: NSCoder) { fatalError() }

  public override func loadView() {
    self.view = productDescriptionView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    title = Localize("product_description.title", table: Table.productDescription, in: .framework)
  }

  override public func bindViewModel() {
    viewBinder.bind(view: productDescriptionView, to: viewModel, using: bag)
  }
}
