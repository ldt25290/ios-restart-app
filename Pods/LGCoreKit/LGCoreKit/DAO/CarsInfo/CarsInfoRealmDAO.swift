//
//  CarsInfoRealmDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 24/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import RealmSwift
import Argo

class RealmCarsMakeWithModels: Object {
    dynamic var makeId: String = ""
    dynamic var makeName: String = ""
    let models = List<RealmCarsModel>()
}

class RealmCarsModel: Object {
    dynamic var modelId: String = ""
    dynamic var modelName: String = ""
}


class CarsInfoRealmDAO: CarsInfoDAO {

    static let dataBaseName = "CarsInfo"
    static let dataBaseExtension = "realm"

    let dataBase: Realm

    var carsMakesList: [CarsMake] {
        let carsMakes = dataBase.objects(RealmCarsMakeWithModels.self)
        let rmCarsMakesArray = Array(carsMakes)
        return rmCarsMakesArray.map { convertToLGCarsMake(carsMake: $0) }
    }


    // MARK: - Lifecycle

    init(realm: Realm) {
        self.dataBase = realm
    }

    convenience init?() {

        guard let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                           .userDomainMask, true).first else { return nil }
        let cacheFilePath = cacheDirectoryPath + "/\(CarsInfoRealmDAO.dataBaseName).\(CarsInfoRealmDAO.dataBaseExtension)"

        do {
            let cacheFileUrl = URL(fileURLWithPath: cacheFilePath, isDirectory: false)
            let config = Realm.Configuration(fileURL: cacheFileUrl, readOnly: false)

            let dataBase = try Realm(configuration: config)
            self.init(realm: dataBase)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not create DB: \(error)")
            return nil
        }
    }


    // MARK: - Public methods

    func save(carsInfo: [CarsMakeWithModels]) {
        clean()

        let realmArray = carsInfo.map { convertToRealmCarsMake(carsMake: $0) }
        let realmList = convertArrayToRealmList(inputArray: realmArray)

        do {
            try dataBase.write ({ [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dataBase.add(realmList)
            })
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not write in DB: \(error)")
        }
    }

    func modelsForMake(makeId: String) -> [CarsModel] {
        let makes = dataBase.objects(RealmCarsMakeWithModels.self)
        let queryPredicate = NSPredicate(format: "makeId == '\(makeId)'")
        guard let rmMake = makes.filter(queryPredicate).first else { return [] }

        let modelsArray = convertRealmListToArray(realmList: rmMake.models).map { convertToLGCarsModel(carsModel: $0) }

        return modelsArray
    }

    func clean() {
        do {
            try dataBase.write ({ [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dataBase.deleteAll()
            })
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not clean the DB: \(error)")
        }
    }

    func loadFirstRunCacheIfNeeded(jsonURL: URL?) {
        guard dataBase.objects(RealmCarsMakeWithModels.self).isEmpty else { return }

        do {
            guard let url = jsonURL else { return }
            let data = try Data(contentsOf: url)
            let jsonCarsMakesList = try JSONSerialization.jsonObject(with: data, options: [])
            let carsMakeList = decoder(jsonCarsMakesList)
            guard let actualCarsMakeList = carsMakeList else { return }

            save(carsInfo: actualCarsMakeList)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Failed to create first run cache: \(error)")
        }
    }

    private func decoder(_ object: Any) -> [CarsMakeWithModels]? {
        let apiCarsMakeList: [ApiCarsMake]? = decode(object)
        return apiCarsMakeList
    }
}


// MARK: - Private Methods

extension CarsInfoRealmDAO {

    // LG to Realm

    fileprivate func convertToRealmCarsMake(carsMake: CarsMakeWithModels) -> RealmCarsMakeWithModels {
        let resultMake = RealmCarsMakeWithModels()
        resultMake.makeId = carsMake.makeId
        resultMake.makeName = carsMake.makeName

        let realmModelsArray = carsMake.models.map { convertToRealmCarsModel(carsModel: $0) }
        resultMake.models.append(objectsIn: realmModelsArray)

        return resultMake
    }

    fileprivate func convertToRealmCarsModel(carsModel: CarsModel) -> RealmCarsModel {
        let resultModel = RealmCarsModel()
        resultModel.modelId = carsModel.modelId
        resultModel.modelName = carsModel.modelName
        return resultModel
    }


    // Realm to LG

    fileprivate func convertToLGCarsMake(carsMake: RealmCarsMakeWithModels) -> LGCarsMake {
        let resultMake = LGCarsMake(makeId: carsMake.makeId, makeName: carsMake.makeName)
        return resultMake
    }

    fileprivate func convertToLGCarsModel(carsModel: RealmCarsModel) -> LGCarsModel {
        let resultModel = LGCarsModel(modelId: carsModel.modelId, modelName: carsModel.modelName)
        return resultModel
    }


    fileprivate func convertArrayToRealmList<T: Object>(inputArray: [T]) -> List<T> {
        let resultList = List<T>()
        inputArray.forEach { item in
            resultList.append(item)
        }
        return resultList
    }

    fileprivate func convertRealmListToArray<T>(realmList: List<T>) -> [T] {
        return Array(realmList)
    }
}
