//
//  TaskEntity+Ext.swift
//  YATDA
//
//  Created by Scott Bolin on 23-Dec-21.
//
//

import CoreData


extension TaskEntity {

    var groupByMonth: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yy" //"MMM yyyy"
            return dateFormatter.string(from: dateCreated ?? Date())
        }
    }

    var groupByWeek: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "'wk 'w ''yy"// "w Y"
            return dateFormatter.string(from: dateCreated ?? Date())
        }
    }

    var groupByDay: String {
        get {
            return dateFormatter.string(from: dateCreated ?? Date())
        }
    }

    // unwrap staus
    @objc var priorityString: String {
        switch priority {
        case "non": return "None"
        case "low": return "Low"
        case "medium": return "Medium"
        case "high": return "High"
        default: return "Medium"
        }
    }
    
    @objc var completedString: String {
        switch completed {
        case true: return "Completed Task"
        case false: return "Incomplete Task"
        }
    }

    @objc var titleString: String {
        return title ?? "No task"
    }

    // unwrap staus
    @objc var statusString: String {
        switch priorityID {
        case 0: return "Focused"
        case 1: return "Tasks to Complete"
        case 2: return "Completed Tasks"
        default: return "Tasks to Completes"
        }
    }


    // set date format for sections...
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, y" // "MMMM d, yyyy"
        return formatter
    }
}

/*
 @NSManaged public var completed: Bool
 @NSManaged public var dateCompleted: Date?
 @NSManaged public var dateCreated: Date?
 @NSManaged public var dateDue: Date?
 @NSManaged public var focused: Bool
 @NSManaged public var id: UUID?
 @NSManaged public var priority: String?
 @NSManaged public var priorityID: Int16
 @NSManaged public var title: String?
 */
