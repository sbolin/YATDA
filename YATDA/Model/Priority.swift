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
        case .low: return Color.yellow
        case .medium: return Color.orange
        case .high: return Color.red
        default: return Color.gray
        }
    }

    static func priorityGivenString(_ priority: String) -> Priority {
        switch priority {
        case "None": return .non
        case "Low": return .low
        case "Medium": return .medium
        case "High": return .high
        default: return .non
        }
    }
}
