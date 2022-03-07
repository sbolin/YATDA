//
//  YATDAWidget.swift
//  YATDAWidget
//
//  Created by Scott Bolin on 20-Dec-21.
//

import CoreData
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    let snapshotEntry = SimpleEntry(date: Date(), titleString: "A Focus Task", priority: .medium, dueDate: Date())

    func placeholder(in context: Context) -> SimpleEntry {
        return snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        return completion(snapshotEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // get core data
        let moc = CoreDataManager.shared.container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        var results = [TaskEntity]()

        do {
            results = try moc.fetch(request) as! [TaskEntity]
        } catch {
            print("Could not fetch \(error.localizedDescription)")
        }

        let focusItems = results.filter { $0.focused == true }

        let titleString = focusItems.first?.title ?? "No Focus Item"
        let priorityString = focusItems.first?.priority ?? "None"
        let dueDate = focusItems.first?.dateDue ?? Date()

        let entry = SimpleEntry(date: Date(), titleString: titleString, priority: Priority(rawValue: priorityString) ?? .non, dueDate: dueDate)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd) // .never
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let titleString: String
    let priority: Priority
    let dueDate: Date
}

struct YATDAWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        //        ForEach(focusTodo) { task in
        let titleString = entry.titleString // task.title ?? "No Current Task"
        let dueDate = entry.dueDate // task.dateDue?.formatted(date: .abbreviated, time: .omitted) ?? ""
        let priorityString = entry.priority.rawValue // task.priority
        ZStack {
            Color(.systemOrange)
            VStack(alignment: .leading, spacing: 0) {
                Text("FOCUS TODO")
                    .font(.caption2).bold()
                    .foregroundColor(.pink)
                    .padding(2)
                Divider()
                    .padding(.bottom, 4)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Circle()
                        .fill(Priority.styleForPriority(priorityString))
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(titleString)
                            .font(.body)
                            .minimumScaleFactor(0.6)
                            .foregroundColor(.indigo)
                        Text("Due \(dueDate.formatted(.relative(presentation: .numeric)))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                Spacer(minLength: 0)
            } // VStack
            .padding(6)
            .background(ContainerRelativeShape().fill(.white))
            .padding(8)
        } // ZStack
        //        } // ForEach
    }
}

@main
struct YATDAWidget: Widget {
    let kind: String = "YATDAWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YATDAWidgetEntryView(entry: entry)
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
        }
        .configurationDisplayName("YATDA Focus")
        .description("Current Focus Task")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct YATDAWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            YATDAWidgetEntryView(entry: SimpleEntry(date: Date(), titleString: "A Pretty Long Medium Priority Task", priority: .medium, dueDate: Date().addingTimeInterval(60 * 60 * 24)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            YATDAWidgetEntryView(entry: SimpleEntry(date: Date(), titleString: "A No Priority Task", priority: .non, dueDate: Date().addingTimeInterval(60 * 60 * 24 * 7)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            YATDAWidgetEntryView(entry: SimpleEntry(date: Date(), titleString: "A Short Task", priority: .high, dueDate: Date().addingTimeInterval(60 * 60 * 24 * 3)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            YATDAWidgetEntryView(entry: SimpleEntry(date: Date(), titleString: "A Low Priority Task", priority: .low, dueDate: Date().addingTimeInterval(60 * 60 * 24 * 1)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
