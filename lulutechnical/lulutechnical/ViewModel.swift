//
//  ViewModel.swift
//  lulutechnical
//
//  Created by Landon Rohatensky on 2023-04-11.
//

import Combine
import Foundation

enum ItemVerificationError: Error, LocalizedError {
    case tooShort
    case tooLong
    case duplicate
    case doesntExist
    
    public var errorDescription: String? {
        switch self {
        case .tooLong:
            return "Name too long"
        case .tooShort:
            return "Name too short"
        case .duplicate:
            return "Name already exists"
        case .doesntExist:
            return "Name doesn't exist"
        }
    }
}

class ViewModel: ObservableObject {
    let service = DataService()
//    @Published private(set) var items: [LuluModel] = []
    let stringSubject = CurrentValueSubject<[LuluModel], Never>([])

    private static let minLength = 2
    private static let maxLength = 20
    
    init() {
        reload()
//        Task {
//            do {
//                _ = try await addItem("Dress")
//            } catch {
//                print(error)
//            }
//        }
    }
    
    func reload() {
        service.getAllObjects { result in
            switch result {
            case .success(let data):
//                items = data
                stringSubject.send(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func add(_ title: String) async throws -> LuluModel {
        let model = try await addItem(title)
        return try await Future<LuluModel, Error>() { [weak service] promise in
            service?.addObject(key: title, object: model, completionHandler: { [weak self] result in
                switch result {
                case .success():
                    self?.reload()
                    promise(.success(model))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }.value
    }
    
    private func addItem(_ title: String) async throws -> LuluModel {
        let saveTask = Task { () -> LuluModel in
            if title.count < ViewModel.minLength {
                throw ItemVerificationError.tooShort
            } else if title.count > ViewModel.maxLength {
                throw ItemVerificationError.tooLong
            }
            let newModel = LuluModel(title: title)
            return newModel
        }

        return try await saveTask.value
    }
}
