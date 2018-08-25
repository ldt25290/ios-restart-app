import Domain
import RxSwift

enum ProductExtrasState {
  case idle
  case loading
}

protocol ProductExtrasViewModelInput {
  func didSelectProductExtra(with id: Identifier<Product.Extra>)
  func didUnSelectProductExtra(with id: Identifier<Product.Extra>)
}

protocol ProductExtrasViewModelOutput {
  var productExtras: PublishSubject<[ProductExtraUIModel]> { get }
  var state: PublishSubject<ProductExtrasState> { get }
}

protocol ProductExtrasViewModelType {
  var input: ProductExtrasViewModelInput { get }
  var output: ProductExtrasViewModelOutput { get }
}
