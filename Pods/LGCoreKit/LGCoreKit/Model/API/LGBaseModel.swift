//
//  LGBaseModel.swift
//  LGCoreKit
//
//  Created by Dídac on 24/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class LGBaseModel: BaseModel {

    public var objectId: String?
    public var createdAt: NSDate?
    public var updatedAt: NSDate?

    public var isSaved: Bool {
        return objectId != nil
    }
}
