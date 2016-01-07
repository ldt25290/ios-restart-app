//
//  MyUserRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

public class MyUserRepository {
    private let dataSource: MyUserDataSource
    private let dao: MyUserDAO

    // TODO: Replace by standard persist when api includes locationType
    private var persistWithoutOverridingLocation: (MyUser) -> ()
    
    // Singleton
    public static let sharedInstance: MyUserRepository = MyUserRepository()
    
    
    // MARK: Lifecycle
    
    public convenience init() {
        let dataSource = MyUserApiDataSource.sharedInstance
        let dao = MyUserUDDAO.sharedInstance
        self.init(dataSource: dataSource, dao: dao)
    }
    
    init(dataSource: MyUserDataSource, dao: MyUserDAO) {
        self.dataSource = dataSource
        self.dao = dao

        self.persistWithoutOverridingLocation = { myUser in
            let userToSave: MyUser
            if let actualUser = dao.myUser, let actualLocation = actualUser.location {
                userToSave = myUser.myUserWithNewLocation(actualLocation)
            } else {
                userToSave = myUser
            }
            dao.save(userToSave)
        }
    }
    
    
    // MARK: - Public methods

    /**
    Returns the logged user.
    */
    public var myUser: MyUser? {
        return dao.myUser
    }
    
    /**
    Returns if the user is logged in.
    */
    public var loggedIn: Bool {
        return myUser != nil
    }
    
    /**
    Updates the name of my user.
    - parameter myUserId: My user identifier.
    - parameter name: The name.
    - parameter completion: The completion closure.
    */
    public func updateName(name: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let params: [String: AnyObject] = [LGMyUser.JSONKeys.name: name]
        update(params, completion: completion)
    }
    
    /**
    Updates the password of my user.
    - parameter myUserId: My user identifier.
    - parameter password: The password.
    - parameter completion: The completion closure.
    */
    public func updatePassword(password: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let params: [String: AnyObject] = [LGMyUser.JSONKeys.password: password]
        update(params, completion: completion)
    }
    
    /**
    Updates the email of my user.
    - parameter myUserId: My user identifier.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    public func updateEmail(email: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let params: [String: AnyObject] = [LGMyUser.JSONKeys.email: email]
        update(params, completion: completion)
    }

    /**
    Updates the avatar of my user.
    - parameter avatar: The avatar.
    - parameter completion: The completion closure.
    */
    public func updateAvatar(avatar: NSData, progressBlock: ((Int) -> ())?,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
            uploadAvatar(avatar, progressBlock: progressBlock, completion: completion)
    }


    // MARK: - Internal methods
       
    /**
    Creates a `MyUser` with the given credentials, public user name and location.
    - parameter email: The email.
    - parameter password: The password.
    - parameter name: The name.
    - parameter location: The location.
    - parameter completion: The completion closure.
    */
    func createWithEmail(email: String, password: String, name: String, location: LGLocation?,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
            guard myUser == nil else {
                completion?(Result<MyUser, RepositoryError>(error: .Internal))
                return
            }
            dataSource.createWithEmail(email, password: password, name: name, location: location) {
                (result: Result<MyUser, ApiError>) -> () in
                    if let value = result.value {
                        let myUser = value.myUserWithNewAuthProvider(.Email)
                        completion?(Result<MyUser, RepositoryError>(value: myUser))
                    } else if let apiError = result.error {
                        let error = RepositoryError(apiError: apiError)
                        completion?(Result<MyUser, RepositoryError>(error: error))
                    }
            }
    }
    
    /**
    Retrieves my user.
    - parameter myUserId: My user identifier.
    - parameter completion: The completion closure.
    */
    public func show(myUserId: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        dataSource.show(myUserId) { [weak self] result in
            handleApiResult(result, success: self?.persistWithoutOverridingLocation, completion: completion)
        }
    }
    
    /**
    Updates the location of my user. If no postal address is passed-by it nullifies it.
    - parameter myUserId: My user identifier.
    - parameter location: The location.
    - parameter postalAddress: The postal address.
    - parameter completion: The completion closure.
    */
    func updateLocation(location: LGLocation, postalAddress: PostalAddress?,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
            var wrappedParams: [String: Unwrappable] = [:]
            wrappedParams[LGMyUser.JSONKeys.latitude] = Nullable<Double>.value(location.coordinate.latitude)
            wrappedParams[LGMyUser.JSONKeys.longitude] = Nullable<Double>.value(location.coordinate.longitude)
            wrappedParams[LGMyUser.JSONKeys.zipCode] = Nullable<String>.value(postalAddress?.zipCode)
            wrappedParams[LGMyUser.JSONKeys.address] = Nullable<String>.value(postalAddress?.address)
            wrappedParams[LGMyUser.JSONKeys.city] = Nullable<String>.value(postalAddress?.city)
            wrappedParams[LGMyUser.JSONKeys.countryCode] = Nullable<String>.value(postalAddress?.countryCode)
            let params = unwrap(wrappedParams)

            //TODO: Replace by standard update method when api includes locationType
            updateWithLocation(location, params: params, completion: completion)
    }
    
    /**
    Saves the given `MyUser`.
    - parameter myUser: My user.
    */
    func save(myUser: MyUser) {
        persistWithoutOverridingLocation(myUser)
    }
    
    /**
    Deletes the user.
    */
    func deleteUser() {
        dao.delete()
    }
    
    
    // MARK: - Private methods

    /**
    Updates a `MyUser` with the given parameters.
    - parameter params: The parameters to be updated.
    - parameter completion: The completion closure.
    */
    private func update(params: [String: AnyObject], completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        guard let myUserId = myUser?.objectId else {
            completion?(Result<MyUser, RepositoryError>(error: .Internal))
            return
        }
        var paramsWithId = params
        paramsWithId[LGMyUser.JSONKeys.objectId] = myUserId
        dataSource.update(myUserId, params: paramsWithId) {
            [weak self] (result: Result<MyUser, ApiError>) -> () in
            handleApiResult(result, success: self?.persistWithoutOverridingLocation, completion: completion)
        }
    }

    /**
    Updates a `MyUser` with the given parameters but overriding location parameter.
    - parameter location: LGLocation to override on result
    - parameter params: The parameters to be updated.
    - parameter completion: The completion closure.
    */
    private func updateWithLocation(location: LGLocation?, params: [String: AnyObject],
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
            guard let myUserId = myUser?.objectId else {
                completion?(Result<MyUser, RepositoryError>(error: .Internal))
                return
            }
            var paramsWithId = params
            paramsWithId[LGMyUser.JSONKeys.objectId] = myUserId
            dataSource.update(myUserId, params: paramsWithId) { [weak self] (result: Result<MyUser, ApiError>) -> () in
                if let value = result.value {
                    let userToSave: MyUser
                    if let location = location {
                        userToSave = value.myUserWithNewLocation(location)
                    } else {
                        userToSave = value
                    }
                    self?.dao.save(userToSave)

                    completion?(Result<MyUser, RepositoryError>(value: userToSave))
                } else if let apiError = result.error {
                    let error = RepositoryError(apiError: apiError)
                    completion?(Result<MyUser, RepositoryError>(error: error))
                }
            }
    }

    /**
    Uploads a new user avatar.
    - parameter avatar: The avatar to be uploaded.
    - parameter myUserId: My user identifier.
    - parameter completion: The completion closure.
    */
    private func uploadAvatar(avatar: NSData, progressBlock: ((Int) -> ())?,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
            guard let myUserId = myUser?.objectId else {
                completion?(Result<MyUser, RepositoryError>(error: .Internal))
                return
            }
            dataSource.uploadAvatar(avatar, myUserId: myUserId, progressBlock: progressBlock) {
                    [weak self] (result: Result<MyUser, ApiError>) -> () in
                    handleApiResult(result, success: self?.persistWithoutOverridingLocation, completion: completion)
            }
    }
}