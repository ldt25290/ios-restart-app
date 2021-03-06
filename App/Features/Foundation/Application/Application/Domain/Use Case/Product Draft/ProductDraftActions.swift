import Domain
import Data
import Core

public struct ProductDraftActions: ProductDraftUseCase {
  
  private let productDraftRepository: ProductDraftRepository
  
  init(productDraftRepository: ProductDraftRepository) {
    self.productDraftRepository = productDraftRepository
  }
  
  public func save(images: [UIImage]) {
    productDraftRepository.set(images: images)
  }
  
  public func save(with title: String, productId: Identifier<Product>) {
    productDraftRepository.set(with: title, productId: productId)
  }
  
  public func save(description: String) {
    productDraftRepository.set(description: description)
  }
  
  public func save(price: Double) {
    productDraftRepository.set(price: price)
  }
  
  public func save(productExtras: [Identifier<Product.Extra>]) {
    productDraftRepository.set(productExtras: productExtras)
  }
  
  public func clear() {
    productDraftRepository.clear()
  }
  
  public func get() -> ProductDraft {
    return productDraftRepository.get()
  }
}

// MARK: - Public initializer

extension ProductDraftActions {
  public init() {
    self.productDraftRepository = resolver.productDraftRepository
  }
}
