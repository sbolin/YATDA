//
//  TodoListRowView.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI
import WidgetKit

struct TodoListRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var notificationManager = NotificationManager()
    @ObservedObject var task: TaskEntity
    @State private var selectedPriority: Priority

    init(task: TaskEntity) {
        self.task = task
        self.selectedPriority = Priority(rawValue: task.priority ?? "Medium") ?? .medium
    }

    var body: some View {

        HStack(alignment: .center ,spacing: 0) {
            // change priority by tapping on colored dot or holding and selecting menu item
            Menu {
                Picker("", selection: $selectedPriority) {
                    ForEach(Priority.allCases) { priority in
                        Text(priority.rawValue.capitalized)
                    }
                }
                .onChange(of: selectedPriority) { priority in
                    task.priority = priority.rawValue
                    switch priority {
                    case .non:
                        task.priorityID = 0
                    case .low:
                        task.priorityID = 1
                    case .medium:
                        task.priorityID = 2
                    case .high:
                        task.priorityID = 3
                    }
                }
            } label: {
                Label {
                    Text("")
                } icon: {
                    // TODO: frame must be at least 18x18 for menu/tap to work consistently. However, circle size is much to big (should be ~12x12). Need to make this a simple image with tapGesture.
                    Circle()
                        .fill(Priority.styleForPriority(task.priority ?? "Medium"))
                        .frame(width: 18, height: 18)
                }
            } primaryAction: {
                switch task.priorityID {
                case 0:
                    task.priorityID = 1
                    task.priority = Priority.low.rawValue
                    break
                case 1:
                    task.priorityID = 2
                    task.priority = Priority.medium.rawValue
                    break
                case 2:
                    task.priorityID = 3
                    task.priority = Priority.high.rawValue
                    break
                case 3:
                    task.priorityID = 0
                    task.priority = Priority.non.rawValue
                    break
                default:
                    task.priorityID = 0
                    task.priority = Priority.non.rawValue
                    break
                }
                // save priority change
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            .frame(width: 32)
//            .contentShape(Rectangle())
            VStack(alignment: .leading) {
                TextField("", text: $task.title ?? "")
                    .submitLabel(SubmitLabel.done)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        if let textField = obj.object as? UITextField {
                            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                        }
                }
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("Start:")
                        .fontWeight(.semibold)
                    if let createdDate = task.dateCreated {
                        Text(createdDate.formatted(.dateTime.day().month(.abbreviated)))
                    }
                    Spacer()
                    Text("Due:")
                        .fontWeight(.semibold)
                    if let dueDate = task.dateDue {
//                        Text(dueDate.formattedRelativeToday())
                        Text(dueDate.formatted(.dateTime.day().month(.abbreviated)))
                    } else {
//                        Text(Date().formattedRelativeToday())
                        Text(Date().formatted(.dateTime.day().month(.abbreviated)))
                    }
                    Spacer()

                } // HStack
                .font(.footnote)
                .foregroundColor(.secondary)
            } // VStack
            Spacer()
            Image(systemName: task.focused ? "target": "scope")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.red)
                .onTapGesture {
                    withAnimation {
                        updateFocus()
                    }
                }
                .padding(.trailing, 6)
            Image(systemName: task.completed ? "checkmark.circle.fill": "checkmark.circle")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.green)
                .onTapGesture {
                    withAnimation {
                        updateCompletion()
                    }
                }
        } // HStack
        .background(Color.clear)
    }

    // Update focus
    private func updateFocus() {
        withAnimation {
            let oldValue = task.focused
            task.focused = !oldValue
            // oldValue = true means task is no longer focused, delete notifications
            if oldValue {
                task.notifiable = false
                if let identifier = task.id?.uuidString {
                    notificationManager.deleteLocalNotifications(identifiers: [identifier])
                }
            }
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func updateCompletion() {
        withAnimation {
            let oldValue = task.completed
/*
oldValue = true means previously completed task marked as incomplete: reset dateCompleted
oldValue = false means task is marked completed: set dateCompleted to now
in both cases focused and notifiable are set to false, and cancel local notifications:
 (1) completed task can't be focused and unfocused task can't have notifications, and
 (2) since task was previously completed it defaults to unfocused and no notifications
*/
            task.focused = false
            task.notifiable = false
            if let identifier = task.id?.uuidString {
                notificationManager.deleteLocalNotifications(identifiers: [identifier])
            }

            if oldValue {
                task.completed = false
                task.dateCompleted = nil
            } else {
                task.completed = true
                task.dateCompleted = Date.now
            }

            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

//struct TodoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = CoreDataManager.preview.container.viewContext
//        TodoListRowView(task: Task(context: context))
//            .environment(\.managedObjectContext, context)
//    }
//}

/// Helper function to unwrap optional binding
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct ColorfulIconLabelStyle: LabelStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .imageScale(.small)
                .tint(color)
        }
    }
}
