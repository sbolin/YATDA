//
//  Priority.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

enum Priority: String, Identifiable, CaseIterable {
    var id: UUID {
        return UUID()
    }
    case low = "Low" // 0
    case medium = "Medium" // 1
    case high = "High" // 2

    static func styleForPriority(_ value: String) -> Color {
        let priority = Priority(rawValue: value)
        switch priority {
        case .low:
            return Color.green
        case .medium:
            return Color.yellow
        case .high:
            return Color.red
        case .none:
            return Color.black
        }
    }
}

extension Priority {
    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}
