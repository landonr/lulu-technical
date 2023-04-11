//
//  Model.swift
//  lulutechnical
//
//  Created by Landon Rohatensky on 2023-04-11.
//

import Foundation

class LuluModel: Codable, Hashable, ObservableObject {
    let identifier = UUID()
    let title: String
    let date = Date()
    
    init(title: String) {
        self.title = title
    }
    
    private enum CodingKeys : String, CodingKey {
        case title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: LuluModel, rhs: LuluModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
