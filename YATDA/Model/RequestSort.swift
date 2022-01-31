//
//  RequestSort.swift
//  YATDA
//
//  Created by Scott Bolin on 23-Dec-21.
//

import Foundation

struct RequestSort: Hashable, Identifiable {
    let id: Int
    let name: String
    let descriptors: [SortDescriptor<TaskEntity>]
    let section: KeyPath<TaskEntity, String>

    static let sorts: [RequestSort] = [
        RequestSort(
            id: 0,
            name: "By Priority",
            descriptors: [
                SortDescriptor(\TaskEntity.priorityID, order: .reverse),
                SortDescriptor(\TaskEntity.title, order: .forward),
                SortDescriptor(\TaskEntity.dateCreated, order: .reverse)],
            section: \TaskEntity.priorityString),

        RequestSort(
            id: 1,
            name: "By Completion",
            descriptors: [
                SortDescriptor(\TaskEntity.completed, order: .forward),
                SortDescriptor(\TaskEntity.priorityID, order: .reverse),
                SortDescriptor(\TaskEntity.title, order: .forward)],
            section: \TaskEntity.priorityString),

        RequestSort(
            id: 2,
            name: "By Date Due",
            descriptors: [
                SortDescriptor(\TaskEntity.dateDue, order: .forward),
                SortDescriptor(\TaskEntity.title, order: .forward)],
            section: \TaskEntity.groupByMonth),

        RequestSort(
            id: 3,
            name: "By Date Created",
            descriptors: [
                SortDescriptor(\TaskEntity.dateCreated, order: .forward),
                SortDescriptor(\TaskEntity.title, order: .forward)],
            section: \TaskEntity.groupByMonth),

        RequestSort(
            id: 4,
            name: "By Name",
            descriptors: [
                SortDescriptor(\TaskEntity.title, order: .forward)],
            section: \TaskEntity.groupByMonth),

        RequestSort(
            id: 5,
            name: "User",
            descriptors: [
                SortDescriptor(\TaskEntity.order, order: .forward)],
            section: \TaskEntity.statusString),
    ]
    static var `default`: RequestSort { sorts[0] }
}

/*
 @NSManaged public var completed: Bool
 @NSManaged public var dateCompleted: Date?
 @NSManaged public var dateCreated: Date?
 @NSManaged public var dateDue: Date?
 @NSManaged public var id: UUID?
 @NSManaged public var focused: Bool
 @NSManaged public var priority: String?
 @NSManaged public var priorityID: Int16
 @NSManaged public var title: String?
 */
