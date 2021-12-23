//
//  Priority.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

enum Priority: String, Identifiable, CaseIterable {
    var id: Priority { self }
    case non = "None" // 0
    case low = "Low" // 1
    case medium = "Medium" // 2
    case high = "High" // 3

    static func styleForPriority(_ value: String) -> Color {
        let priority = Priority(rawValue: value)
        switch priority {
        case .non: return Color.gray
        case .low: return Color.green
        case .medium: return Color.yellow
        case .high: return Color.red
        case .none: return Color.gray
        }
    }
}

extension Priority {
    var title: String {
        switch self {
        case .non:
            return "None"
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}
