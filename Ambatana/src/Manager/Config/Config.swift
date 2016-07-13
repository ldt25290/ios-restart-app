//
//  Config.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Alamofire
import Argo
import LGCoreKit

public class Config: ResponseObjectSerializable {

    // Constant
    public static let currentVersionInfoJSONKey = "currentVersionInfo"
    private static let buildNumberJSONKey = "buildNumber"
    private static let forceUpdateVersionsJSONKey = "forceUpdateVersions"
    private static let configURLJSONKey = "configURL"
    private static let userRatingJSONKey = "userRating"
    private static let myMessagesCountJSONKey = "myMessagesCountForRating"
    private static let otherMessagesCountJSONKey = "otherMessagesCountForRating"

    public var buildNumber : Int
    public var forceUpdateVersions : [Int]
    public var configURL : String
    public var myMessagesCountForRating: Int    // # of messages I must have sent to be able to rate an user
    public var otherMessagesCountForRating: Int // # of messages another user must have sent to me to be able to rate him


    // MARK : - Lifecycle

    public init() {
        buildNumber = 0
        forceUpdateVersions = []
        configURL = ""
        myMessagesCountForRating = Constants.myMessagesCountForRating
        otherMessagesCountForRating = Constants.otherMessagesCountForRating
    }

    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {

        let json = JSON(representation)
        self.init(json: json)
    }

    public required convenience init?(data: NSData) {
        guard let json = JSON.parse(data: data) else {
            return nil
        }
        self.init(json: json)
    }

    public required convenience init(json: JSON) {
        self.init()

        if let currentVersionInfo: JSON = json.decode(Config.currentVersionInfoJSONKey) {
            if let buildNumber: Int = currentVersionInfo.decode(Config.buildNumberJSONKey) {
                self.buildNumber = buildNumber
            }
            if let forceUpdateVersions: [Int] = currentVersionInfo.decode(Config.forceUpdateVersionsJSONKey) {
                self.forceUpdateVersions = forceUpdateVersions
            }
        }

        if let cfgURL : String = json.decode(Config.configURLJSONKey) {
            self.configURL = cfgURL
        }

        if let userRating: JSON = json.decode(Config.userRatingJSONKey) {
            if let myMessages: Int = userRating.decode(Config.myMessagesCountJSONKey) {
                self.myMessagesCountForRating = myMessages
            }
            if let otherMessages: Int = userRating.decode(Config.otherMessagesCountJSONKey) {
                self.otherMessagesCountForRating = otherMessages
            }
        }
    }

    // MARK : - Public Methods

    public func jsonRepresentation() -> AnyObject {

        var tmpFinalDic : [String:AnyObject] = [:]
        var tmpCurrentVersionDic : [String:AnyObject] = [:]
        var tmpUserRatingDic : [String:AnyObject] = [:]

        tmpCurrentVersionDic[Config.buildNumberJSONKey] = buildNumber
        tmpCurrentVersionDic[Config.forceUpdateVersionsJSONKey] = forceUpdateVersions

        tmpFinalDic[Config.currentVersionInfoJSONKey] = tmpCurrentVersionDic
        tmpFinalDic[Config.configURLJSONKey] = configURL

        tmpUserRatingDic[Config.myMessagesCountJSONKey] = myMessagesCountForRating
        tmpUserRatingDic[Config.otherMessagesCountJSONKey] = otherMessagesCountForRating

        tmpFinalDic[Config.userRatingJSONKey] = tmpUserRatingDic

        return tmpFinalDic
    }
}
