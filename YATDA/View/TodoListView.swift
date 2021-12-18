//
//  TodoListView.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

struct TodoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: Task
    @State private var selectedPriority: Priority

    init(task: Task) {
        self.task = task
        self.selectedPriority = Priority(rawValue: task.priority ?? "Medium") ?? .medium
    }


    var body: some View {

        HStack(spacing: 0) {

            Menu {
                Picker(selection: $selectedPriority, label: Text("")) {
                    ForEach(Priority.allCases) { priority in
                        Text(priority.rawValue.capitalized)
                    }
                }
                .onChange(of: selectedPriority) { priority in
                    task.priority = priority.rawValue
                    switch priority {
                    case .low:
                        task.priorityID = 0
                    case .medium:
                        task.priorityID = 1
                    case .high:
                        task.priorityID = 2
                    }
                }
            } label: {
                Label {
                    Text("")
                } icon: {
                    Circle()
                        .fill(Priority.styleForPriority(task.priority ?? "Medium"))
                        .frame(width: 12, height: 12)
                }
            } primaryAction: {
                switch task.priorityID {
                case 0:
                    task.priority = Priority.medium.rawValue
                    task.priorityID = 1
                case 1:
                    task.priority = Priority.high.rawValue
                    task.priorityID = 2
                case 2:
                    task.priority = Priority.low.rawValue
                    task.priorityID = 0
                default:
                    task.priority = Priority.medium.rawValue
                    task.priorityID = 1
                }
            }
            TextField("", text: $task.title ?? "")
            Spacer()
            Image(systemName: task.isFavorite ? "target": "scope")
                .foregroundColor(.red)
                .onTapGesture {
                    withAnimation {
                        updateTask()
                    }
                }
                .padding(.trailing, 6)
            Image(systemName: task.completed ? "checkmark.circle.fill": "checkmark.circle")
                .foregroundColor(.green)
                .onTapGesture {
                    withAnimation {
                        updateCompletion()
                    }
                }
        }
    }

    /// Helper function to unwrap optional binding
    private func updateTask() {
        withAnimation {
            let oldValue = task.isFavorite
            task.isFavorite = !oldValue
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func updateCompletion() {
        withAnimation {
            let oldValue = task.completed
            task.completed = !oldValue
            if !oldValue {
                task.isFavorite = false
                task.dateCompleted = Date() // task has been completed
            } else {
                task.dateCompleted = nil // dateCompleted is reset if completed task is marked as incomplete
            }
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

//struct TodoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = CoreDataManager.preview.container.viewContext
//        TodoListView(task: Task(context: context))
//            .environment(\.managedObjectContext, context)
//    }
//}

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
