//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ChatListViewModelDelegate: class {
    func chatListViewModelDidFailArchivingChats(_ viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedArchivingChats(_ viewModel: ChatListViewModel)
    func chatListViewModelDidFailUnarchivingChats(_ viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedUnarchivingChats(_ viewModel: ChatListViewModel)
}

protocol ChatListViewModel: class, ChatGroupedListViewModel {
    weak var delegate: ChatListViewModelDelegate? { get set }
    weak var tabNavigator: TabNavigator? { get set }

    var titleForDeleteButton: String { get }
    var hasMessagesToRead: Bool { get }
    var shouldRefreshConversationsTabTrigger: Bool { get set }

    func deleteConfirmationTitle(_ itemCount: Int) -> String
    func deleteConfirmationMessage(_ itemCount: Int) -> String
    func deleteConfirmationCancelTitle() -> String
    func deleteConfirmationSendButton() -> String

    func deleteButtonPressed()

    func conversationDataAtIndex(_ index: Int) -> ConversationCellData?
    func isConversationSelected(index: Int) -> Bool
    func deselectAllConversations()
    func deselectConversation(index: Int, editing: Bool)
    func selectConversation(index: Int, editing: Bool)
    func openConversation(index: Int)
}
