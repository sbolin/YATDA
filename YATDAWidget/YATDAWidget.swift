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
    var moc = CoreDataManager.shared.container.viewContext

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), focusTodo: [Task]())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), focusTodo: [Task]())
        return completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        // get core data
        let moc = CoreDataManager.shared.container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        var results = [Task]()

        do {
            results = try moc.fetch(request) as! [Task]
        } catch {
            print("Could not fetch task for widget \(error.localizedDescription)")
        }

        var focusTodo: [Task] {
            results
                .filter { $0.isFavorite == true }
        }

        let entry = SimpleEntry(date: .now, focusTodo: focusTodo)
        entries.append(entry)


        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let focusTodo: [Task]
}

struct YATDAWidgetEntryView : View {
    var entry: Provider.Entry


    var body: some View {
        ForEach(entry.focusTodo) { task in
            HStack(alignment: .top) {
                Circle()
                    .fill(Priority.styleForPriority(task.priority ?? "Medium"))
                    .frame(width: 12, height: 12)
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title ?? "")
                    Text(task.dateDue ?? Date(), format: .dateTime)
                }
            }
            .background(Color.gray)
//            .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
        }
    }
}

@main
struct YATDAWidget: Widget {
    let kind: String = "YATDAWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YATDAWidgetEntryView(entry: entry)
//                .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
        }
        .configurationDisplayName("YATDA Focus")
        .description("Current Focus Task")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct YATDAWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            YATDAWidgetEntryView(entry: SimpleEntry(date: Date(), focusTodo: [Task]()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            YATDAWidgetEntryView(entry: SimpleEntry(date: Date(), focusTodo: [Task]()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
