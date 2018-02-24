import RxSwift

protocol ProductPriceViewModelInput {
  func onNextStepPressed()
}

protocol ProductPriceViewModelOutput {
  var description: BehaviorSubject<String> { get }
  var nextStepEnabled: Observable<Bool> { get }
}

protocol ProductPriceViewModelType {
  var input: ProductPriceViewModelInput { get }
  var output: ProductPriceViewModelOutput { get }
}
