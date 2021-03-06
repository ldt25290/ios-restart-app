import Foundation

public enum ProductExtraType {
  case sealedProduct
  case collectorsEdition
  case exchangeAccepted
  case unknown
}

extension Product {
  public struct Extra: Equatable {
    public let identifier: Identifier<Product.Extra>
    public let type: ProductExtraType
    
    public init(identifier: Identifier<Product.Extra>,
                type: ProductExtraType) {
      self.identifier = identifier
      self.type = type
    }
  }
}
