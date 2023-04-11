//
//  DataService.swift
//  lulutechnical
//
//  Created by Landon Rohatensky on 2023-04-11.
//

import Combine
import Foundation

protocol DatabaseService {
    associatedtype Object: Codable
    
    func getAllObjects(completionHandler: (Result<[Object], Error>) -> ())
    func addObject(key: String, object: Object, completionHandler: (Result<Void, Error>) -> ())
    func removeObject(key: String, completionHandler: (Result<Void, Error>) -> ())
}

class DataService: DatabaseService {
    private let defaults = UserDefaults.standard

    private static let id = "saveditems"
    func getAllObjects(completionHandler: (Result<[Object], Error>) -> ()) {
        if let savedItems = defaults.object(forKey: DataService.id) as? Data {
            let decoder = JSONDecoder()
            if let loadedItems = try? decoder.decode([Object].self, from: savedItems) {
                completionHandler(.success(loadedItems))
                return
            }
        }
        completionHandler(.success([]))
    }
    
    private func saveItems(items: [Object]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: DataService.id)
        }
    }

    func addObject(key: String, object: Object, completionHandler: (Result<Void, Error>) -> ()) {
        getAllObjects(completionHandler: { [weak self] result in
            switch result {
            case .success(var objects):
                if objects.contains(where: { model in
                    model.title.lowercased() == key.lowercased()
                }) {
                    completionHandler(.failure(ItemVerificationError.duplicate))
                    return
                }
                objects.append(object)
                self?.saveItems(items: objects)
                completionHandler(.success(()))
            case .failure(let error):
                print(error)
                completionHandler(.failure(error))
            }
        })
    }

    func removeObject(key: String, completionHandler: (Result<Void, Error>) -> ()) {
        getAllObjects(completionHandler: { [weak self] result in
            switch result {
            case .success(let objects):
                guard objects.contains(where: { model in
                    model.title.lowercased() == key.lowercased()
                }) else {
                    completionHandler(.failure(ItemVerificationError.doesntExist))
                    return
                }
                let items = objects.filter { $0.title.lowercased() != key.lowercased()}
                self?.saveItems(items: items)
            default:
                break
            }
        })
    }

    typealias Object = LuluModel
}
