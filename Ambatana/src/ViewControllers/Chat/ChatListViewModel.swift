//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

public protocol ChatListViewModelDelegate: class {
    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool)
    func didFailRetrievingChatList(viewModel: ChatListViewModel, error: ErrorData)
    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, nonEmptyChatList: Bool)
}

public class ChatListViewModel : BaseViewModel {

    public weak var delegate : ChatListViewModelDelegate?

    public var chats: [Chat]?
    var chatRepository: ChatRepository

    // computed iVars
    public var chatCount : Int {
        return chats?.count ?? 0
    }

    // MARK: - Lifecycle

    public override convenience init() {
        self.init(chatRepository: ChatRepository.sharedInstance, chats: [])
    }

    public required init(chatRepository: ChatRepository, chats: [Chat]) {
        self.chatRepository = chatRepository
        self.chats = chats
        super.init()
    }

    override func didSetActive(active: Bool) {
        if active {
            updateConversations()
        }
    }

    // MARK: public methods

    public func updateConversations() {
        guard !chatRepository.loadingChats else { return }

        delegate?.didStartRetrievingChatList(self, isFirstLoad: chatCount < 1)

        chatRepository.retrieveChatsWithCompletion { [weak self] (result) in

            if let strongSelf = self {
                if let chats = result.value {
                    strongSelf.chats = chats
                    strongSelf.delegate?.didSucceedRetrievingChatList(strongSelf, nonEmptyChatList: chats.count > 0)
                } else if let actualError = result.error {

                    var errorData = ErrorData()
                    // ⚠️ TODO : remove comments & update with real RepositoryError values
//                    switch actualError {
//                    case .Forbidden:
//                        errorData.isScammer = true
//                    case .Network:
//                        errorData.errImage = UIImage(named: "err_network")
//                        errorData.errTitle = LGLocalizedString.commonErrorTitle
//                        errorData.errBody = LGLocalizedString.commonErrorNetworkBody
//                        errorData.errButTitle = LGLocalizedString.commonErrorRetryButton
//                    case .Internal, .Unauthorized:
//                        break
//                    }

                    strongSelf.delegate?.didFailRetrievingChatList(strongSelf, error: errorData)
                }
            }
        }
        updateUnreadMessagesCount()
    }

    public func updateUnreadMessagesCount() {
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    public func chatAtIndex(index: Int) -> Chat? {
        guard let chats = chats where index < chatCount else { return nil }
        return chats[index]
    }

    public func clearChatList() {
        chats = []
    }

}