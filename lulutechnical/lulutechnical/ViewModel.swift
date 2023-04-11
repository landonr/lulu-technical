//
//  ViewModel.swift
//  lulutechnical
//
//  Created by Landon Rohatensky on 2023-04-11.
//

import Combine

enum ItemVerificationError: Error {
    case tooShort
    case tooLong
    case duplicate
}

class ViewModel {
//    let service:  = MainDataService()
    
    private static let minLength = 2
    private static let maxLength = 20
    @Published private(set) var items: [LuluModel]? = []
    
    init() {
        Task {
            items?.append(.init(title: "hey"))
        }
//        Task {
//            package = (await service.loadPackage())?.map {
//                FormattedPackageElement(package: $0)
//            }
//        }
    }
    
    func addItem(_ title: String) async throws -> LuluModel {
        let saveTask = Task { () -> LuluModel in
            if title.count < ViewModel.minLength {
                throw ItemVerificationError.tooShort
            } else if title.count > ViewModel.maxLength {
                throw ItemVerificationError.tooLong
            } else if items?.contains(where: { model in
                model.title.lowercased() == title.lowercased()
            }) ?? false {
                throw ItemVerificationError.duplicate
            }
            let newModel = LuluModel(title: title)
            items?.append(newModel)
            return newModel
        }
        return try await saveTask.value
    }
}
