//
//  OldChatListViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

class OldChatListViewModel: OldChatGroupedListViewModel<Chat>, ChatListViewModel {
    private var chatRepository: OldChatRepository

    private(set) var chatsType: ChatsType
    weak var delegate: ChatListViewModelDelegate?


    var titleForDeleteButton: String {
        return LGLocalizedString.chatListDelete
    }


    // MARK: - Lifecycle

    convenience init(chatsType: ChatsType) {
        self.init(chatRepository: Core.oldChatRepository, chats: [], chatsType: chatsType)
    }

    required init(chatRepository: OldChatRepository, chats: [Chat], chatsType: ChatsType) {
        self.chatRepository = chatRepository
        self.chatsType = chatsType
        super.init(objects: chats)
    }


    // MARK: - Public methods

    override func index(page: Int, completion: (Result<[Chat], RepositoryError> -> ())?) {
        super.index(page, completion: completion)
        chatRepository.index(chatsType, page: page, numResults: resultsPerPage, completion: completion)
    }

    override func didFinishLoading() {
        super.didFinishLoading()

        if active {
            NotificationsManager.sharedInstance.updateCounters()
        }
    }

    func conversationDataAtIndex(index: Int) -> ConversationCellData? {
        guard let chat = objectAtIndex(index) else { return nil }
        guard let myUser = Core.myUserRepository.myUser else { return nil }

        let status: ConversationCellStatus
        switch chat.status {
        case .Forbidden:
            status = .Forbidden
        case .Sold:
            status = .Sold
        case .Deleted:
            status = .Deleted
        case .Available:
            status = .Available
        }


        var otherUser: User?
        if let myUserId = myUser.objectId, let userFromId = chat.userFrom.objectId, let _ = chat.userTo.objectId {
            otherUser = (myUserId == userFromId) ? chat.userTo : chat.userFrom
        }

        return ConversationCellData(status: status,
                                    userName: otherUser?.name ?? "",
                                    userImageUrl: otherUser?.avatar?.fileURL,
                                    userImagePlaceholder: LetgoAvatar.avatarWithID(otherUser?.objectId, name: otherUser?.name),
                                    productName: chat.product.name ?? "",
                                    productImageUrl: chat.product.thumbnail?.fileURL,
                                    unreadCount: chat.msgUnreadCount,
                                    messageDate: chat.updatedAt)
    }

    func oldChatViewModelForIndex(index: Int) -> OldChatViewModel? {
        guard let chat = objectAtIndex(index) else { return nil }
        return OldChatViewModel(chat: chat)
    }

    func chatViewModelForIndex(index: Int) -> ChatViewModel? { return nil }


    // MARK: >  Unread

    var hasMessagesToRead: Bool {
        for index in 0..<objectCount {
            if objectAtIndex(index)?.msgUnreadCount > 0 { return true }
        }
        return false
    }


    // MARK: > Send

    func deleteButtonPressed() {
        delegate?.vmDeleteSelectedChats()
    }

    func deleteConfirmationTitle(itemCount: Int) -> String {
        return itemCount <= 1 ? LGLocalizedString.chatListDeleteAlertTitleOne :
            LGLocalizedString.chatListDeleteAlertTitleMultiple
    }

    func deleteConfirmationMessage(itemCount: Int) -> String {
        return itemCount <= 1 ? LGLocalizedString.chatListDeleteAlertTextOne :
            LGLocalizedString.chatListDeleteAlertTextMultiple
    }

    func deleteConfirmationCancelTitle() -> String {
        return LGLocalizedString.commonCancel
    }

    func deleteConfirmationSendButton() -> String {
        return LGLocalizedString.chatListDeleteAlertSend
    }

    func deleteChatsAtIndexes(indexes: [Int]) {
        let chatIds: [String] = indexes.filter { $0 < objectCount && $0 >= 0 }.flatMap {
            objectAtIndex($0)?.objectId
        }

        chatRepository.archiveChatsWithIds(chatIds) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.error {
                strongSelf.delegate?.chatListViewModelDidFailArchivingChats(strongSelf)
            } else {
                strongSelf.delegate?.chatListViewModelDidSucceedArchivingChats(strongSelf)
            }
        }
    }
}
