//
//  LGChatMessageContent.swift
//  LGCoreKit
//
//  Created by Nestor on 11/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

enum ChatMessageTypeDecodable: String, Decodable {
    case text = "text"
    case offer = "offer"
    case sticker = "sticker"
    case quickAnswer = "quick_answer"
    case expressChat = "express_chat"
    case favoritedListing  = "favorited_product"
    case phone = "phone"
    case meeting = "chat_norris"
    case multiAnswer = "multi_answer"
}

public protocol ChatMessageContent {
    var type: ChatMessageType { get }
    var defaultText: String? { get }
    var text: String? { get }
}

struct LGChatMessageContent: ChatMessageContent, Decodable, Equatable {

    let type: ChatMessageType
    let defaultText: String?
    let text: String?
    
    init(type: ChatMessageType,
         defaultText: String?,
         text: String?) {
        
        self.type = type
        self.defaultText = defaultText
        self.text = text
    }
    
    // MARK: Decodable
    
    /*
     {
     "text": "Hi! I'd like to buy it",
     "type": "ChatMessageTypeDecodable",
     "default": "You've received a message not supported for your app version.\nPlease update your app to use the newest features!",
     
     "answers": [LGChatAnswer],
     "key": String?
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let textValue = try keyedContainer.decodeIfPresent(String.self, forKey: .text)
        defaultText = try keyedContainer.decodeIfPresent(String.self, forKey: .unsupportedMessageTypeDescription)
        let chatMessageTypeString = try keyedContainer.decode(String.self, forKey: .type)
        if let chatMessageTypeDecodable = ChatMessageTypeDecodable(rawValue: chatMessageTypeString) {
            switch chatMessageTypeDecodable {
            case .text:
                type = .text
                text = textValue
            case .offer:
                type = .offer
                text = textValue
            case .sticker:
                type = .sticker
                text = textValue
            case .quickAnswer:
                type = .quickAnswer(id: nil, text: textValue ?? "")
                text = nil
            case .expressChat:
                type = .expressChat
                text = textValue
            case .favoritedListing:
                type = .favoritedListing
                text = textValue
            case .phone:
                type = .phone
                text = textValue
            case .meeting:
                type = .meeting
                text = textValue
            case .multiAnswer:
                if let answers = try? keyedContainer.decode([LGChatAnswer].self, forKey: .answers) {
                    let questionKey = try keyedContainer.decodeIfPresent(String.self, forKey: .key)
                    let questionString = try keyedContainer.decode(String.self, forKey: .text)
                    let question = LGChatQuestion(key: questionKey, text: questionString)
                    type = .multiAnswer(question: question, answers: answers)
                    text = nil
                } else {
                    type = .unsupported(defaultText: defaultText)
                    text = nil
                }
            }
        } else {
            type = .unsupported(defaultText: defaultText)
            text = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case unsupportedMessageTypeDescription = "default"
        case key
        case answers
    }
    
    // MARK: Equatable
    
    static func ==(lhs: LGChatMessageContent, rhs: LGChatMessageContent) -> Bool {
        return lhs.type == rhs.type
        && lhs.defaultText == rhs.defaultText
        && lhs.text == rhs.text
    }
}
