//
//  Product+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension Listing {
    func belongsTo(userId: String?) -> Bool {
        let ownerId = user.objectId
        guard user.objectId != nil && userId != nil else { return false }
        return ownerId == userId
    }

    func isMine(myUserRepository: MyUserRepository) -> Bool {
        return belongsTo(userId: myUserRepository.myUser?.objectId)
    }

    func containsVideo() -> Bool {
        return media.contains(where: { $0.type == .video })
    }
    
    var isRealEstateWithEmptyAttributes: Bool {
        guard isRealEstate else { return false }
        return realEstate?.realEstateAttributes == RealEstateAttributes.emptyRealEstateAttributes()
    }
    
    var isServiceWithEmptyAttributes: Bool {
        guard isService else { return false }
        return service?.servicesAttributes == ServiceAttributes.emptyServicesAttributes()
    }
}

extension Listing {
    func tags(postingFlowType: PostingFlowType) -> [String]? {
        switch self {
        case .product, .car:
            return nil
        case .realEstate(let realEstate):
            return realEstate.realEstateAttributes.generateTags(postingFlowType: postingFlowType)
        case .service(_):
            // FIXME: Implement this in ABIOS-4184
            return nil
        }
    }
}

extension Product {
    func belongsTo(userId: String?) -> Bool {
        let ownerId = user.objectId
        guard user.objectId != nil && userId != nil else { return false }
        return ownerId == userId
    }

    func isMine(myUserRepository: MyUserRepository) -> Bool {
        return belongsTo(userId: myUserRepository.myUser?.objectId)
    }
}

