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
    let order: Int64
    let priority: String
    let priorityID: Int16
    let title: String
}