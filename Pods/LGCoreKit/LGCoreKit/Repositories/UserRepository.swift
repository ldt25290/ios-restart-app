//
//  UserRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

public typealias UsersResult = Result<[User], RepositoryError>
public typealias UsersCompletion = UsersResult -> Void

public typealias UserResult = Result<User, RepositoryError>
public typealias UserCompletion = UserResult -> Void

public typealias UserUserRelationResult = Result<UserUserRelation, RepositoryError>
public typealias UserUserRelationCompletion = UserUserRelationResult -> Void

public typealias UserVoidResult = Result<Void, RepositoryError>
public typealias UserVoidCompletion = UserVoidResult -> Void


public final class UserRepository {
    let dataSource: UserDataSource
    let myUserRepository: MyUserRepository

    
    // MARK: - Lifecycle
    
    init(dataSource: UserDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }
    
    /**
    Retrieves the user for the given ID.
    - parameter userId: User identifier.
    - parameter completion: The completion closure.
    */
    public func show(userId: String, completion: UserCompletion?) {
        dataSource.show(userId) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }

    /**
     Retrieves relation data with other user

     - parameter relatedUserId: Related user Identifier
     - parameter completion:    The Completion closure
     */
    public func retrieveUserToUserRelation(relatedUserId: String, completion: UserUserRelationCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserUserRelationResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.retrieveRelation(userId, relatedUserId: relatedUserId) { result in
            if let error = result.error {
                completion?(UserUserRelationResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                completion?(UserUserRelationResult(value: value))
            }
        }
    }

    /**
     Retrieves the list of all blocked users

     - parameter completion: The completion closure
     */
    public func indexBlocked(completion: UsersCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UsersResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.indexBlocked(userId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Blocks users

     - parameter user:       users to block
     - parameter completion: Completion closure
     */
    public func blockUsersWithIds(userIds: [String], completion: UserVoidCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserVoidResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        guard !userIds.isEmpty else {
            completion?(UserVoidResult(error: .Internal(message: "Missing users to block")))
            return
        }

        dataSource.blockUsers(userId, relatedUserIds: userIds) { result in
            if let error = result.error {
                completion?(UserVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(UserVoidResult(value: Void()))
            }
        }
    }

    /**
     Unblocks users

     - parameter userIds:       users to unblock
     - parameter completion: Completion closure
     */

    public func unblockUsersWithIds(userIds: [String], completion: UserVoidCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserVoidResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        guard !userIds.isEmpty else {
            completion?(UserVoidResult(error: .Internal(message: "Missing users to block")))
            return
        }

        dataSource.unblockUsers(userId, relatedUserIds: userIds) { result in
            if let error = result.error {
                completion?(UserVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(UserVoidResult(value: Void()))
            }
        }
    }

    /**
    Reports a 'bad' user

    - parameter reportedUser: User to report
    - parameter params:       Report reason and comment
    - parameter completion:   The completion closure
    */
    public func saveReport(reportedUser: User, params: ReportUserParams, completion: UserCompletion?) {

        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }

        guard let reportedUserId = reportedUser.objectId else {
            completion?(UserResult(error: .Internal(message: "Missing objectId in ReportedUser")))
            return
        }

        dataSource.saveReport(reportedUserId, userId: userId, parameters: params.reportUserApiParams) { result in
            UserRepository.handleVoidResultToUser(result, user: reportedUser, completion: completion)
        }
    }


    // MARK: - Private methods

    static func handleVoidResultToUser(result: Result<Void, ApiError>, user: User, completion: UserCompletion?) {
        if let error = result.error {
            completion?(UserResult(error: RepositoryError(apiError: error)))
        } else if let _ = result.value {
            completion?(UserResult(value: user))
        }
    }
}
