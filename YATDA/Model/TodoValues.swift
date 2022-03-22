//
//  TodoValues.swift
//  YATDA
//
//  Created by Scott Bolin on 14-Jan-22.
//

import Foundation

struct TodoValues {
    let completed: Bool
    let dateCompleted: Date?
    let dateCreated: Date
    let dateDue: Date
    let focused: Bool
    let id: UUID
    let note: String?
    let notifiable: Bool
    let notifyTime: Date
    let order: Int64
    let priority: String
    let priorityID: Int16
    let title: String
}
