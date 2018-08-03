import Foundation
import LGCoreKit
import LGComponents

struct ListingVMProductInfo {
    let title: String?
    let titleAuto: String?
    let linkedTitle: NSAttributedString?
    let titleAutoGenerated: Bool
    let titleAutoTranslated: Bool
    let price: String
    let priceType: String?
    let description: NSAttributedString?
    let address: String?
    let location: LGLocationCoordinates2D?
    let distance: String?
    let creationDate: Date?
    let category: ListingCategory?
    let attributeGridTitle: String?
    let attributeGridItems: [ListingAttributeGridItem]?
    
    fileprivate(set) var attributeTags: [String]?

    init(listing: Listing,
         isAutoTranslated: Bool,
         distance: String?,
         freeModeAllowed: Bool,
         postingFlowType: PostingFlowType) {
        self.title = listing.title
        self.titleAuto = listing.nameAuto
        self.linkedTitle = listing.title?.attributedHiddenTagsLinks
        self.titleAutoGenerated = listing.isTitleAutoGenerated
        self.titleAutoTranslated = isAutoTranslated
        self.price = listing.priceString(freeModeAllowed: freeModeAllowed)
        self.priceType = listing.service?.servicesAttributes.priceType?.localizedDisplayName
        self.description = listing.description?.trim.attributedHiddenTagsLinks
        self.address = listing.postalAddress.zipCodeCityString
        self.location = listing.location
        self.distance = distance
        self.creationDate = listing.createdAt
        self.category = listing.category
        self.attributeGridItems = ListingVMProductInfo.gridItems(forListing: listing)
        self.attributeGridTitle = ListingVMProductInfo.attributeGridTitle(forListing: listing)
        
        self.attributeTags = tags(for: listing, postingFlowType: postingFlowType)
    }
}


extension ListingVMProductInfo {
    
    private func tags(for listing: Listing, postingFlowType: PostingFlowType) -> [String]? {
        switch listing {
        case .product, .car:
            return nil
        case .realEstate(let realEstate):
            return realEstate.realEstateAttributes.generateTags(postingFlowType: postingFlowType)
        case .service:
            // FIXME: Implement this in ABIOS-4184
            return nil
        }
    }
    
    private static func attributeGridTitle(forListing listing: Listing) -> String? {
        switch listing {
        case .car(let car):
            return car.carAttributes.generatedTitle
        case .realEstate, .product, .service:
            return nil
        }
    }
    
    private static func gridItems(forListing listing: Listing) -> [ListingAttributeGridItem]? {
        switch listing {
        case .car(let car):
            return car.carAttributes.createListingAttributesCollection()
        case .realEstate, .product, .service:
            return nil
        }
    }
}

private extension String {
    
    var attributedHiddenTagsLinks: NSMutableAttributedString {
        var urlDict: [String : URL] = [:]
        for tag in TextHiddenTags.allTags {
            if let url = tag.linkURL {
                urlDict[tag.localized] = url
            }
        }
        return attributedHyperlinkedStringWithURLDict(urlDict, textColor: nil)
    }
}
