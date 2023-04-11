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

enum SortOrder: CaseIterable {
    case alphabetical
    case date
    
    var localizedName: String {
        switch self {
        case .alphabetical:
            return "Alpha"
        case .date:
            return "Creation Time"
        }
    }
}

class ViewModel: ObservableObject {
    let service = DataService()
    private let itemSubject = CurrentValueSubject<[LuluModel], Never>([])
    let sortOrder = CurrentValueSubject<SortOrder, Never>(.alphabetical)
    private static let minLength = 2
    private static let maxLength = 20
    
    var items: AnyPublisher<[LuluModel], Never> {
        Publishers
            .CombineLatest(itemSubject, sortOrder)
            .map { (model, order) in
                switch order {
                case .alphabetical:
                    return model.sorted { (first, second) in
                        first.title < second.title
                    }
                case .date:
                    return model.sorted { (first, second) in
                        first.date < second.date
                    }
                }
            }.eraseToAnyPublisher()
    }
    
    init() {
        reload()
    }
    
    func reload() {
        service.getAllObjects { result in
            switch result {
            case .success(let data):
                itemSubject.send(data)
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
