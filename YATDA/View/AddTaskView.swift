//
//  AddTaskView.swift
//  YATDA
//
//  Created by Scott Bolin on 17-Jan-22.
//

import SwiftUI
import WidgetKit

struct AddTaskView: View {

    @Environment(\.managedObjectContext) private var viewContext
    let coreDataManager: CoreDataManager = .shared
    @ObservedObject var notificationManager: NotificationManager


    @State var title: String = ""
    @FocusState private var taskIsFocused: Bool
    @State private var selectedPriority: Priority = .non

    private var buttonColor: Color {
        return todoIsValid ? .accentColor : .gray.opacity(0.3)
    }

    private var todoIsValid: Bool {
        !title.isEmpty
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField("Enter New Task", text: $title)
                .textFieldStyle(.roundedBorder)
//                .background(Color.white)
//                .padding(6)
//                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green, lineWidth: 1))
                .focused($taskIsFocused)
                .textInputAutocapitalization(.words)

            Picker("Priority", selection: $selectedPriority) {
                ForEach(Priority.allCases) { priority in
                    Text(priority.rawValue.capitalized) // .tag(priority)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                }
            }
            .colorMultiply(Priority.styleForPriority(selectedPriority.rawValue))
            .pickerStyle(.segmented)

            Button("Add Task") {
                saveTask()
                title = ""
                taskIsFocused = false
            }
            .disabled(!todoIsValid)
            .frame(width: 125, height: 32)
            .background(buttonColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .circular))
//            Divider()
        }
        .padding(.horizontal)
    }

    private func saveTask() {
        let task = TaskEntity(context: viewContext)
        task.title = title
        task.id = UUID()
        task.priority = selectedPriority.rawValue
        switch selectedPriority {
        case .non:
            task.priorityID = 0
        case .low:
            task.priorityID = 1
        case .medium:
            task.priorityID = 2
        case .high:
            task.priorityID = 3
        }
        task.dateCreated = Date.now
        // default due date is 1 day after creation.
        task.dateDue = Date().addingTimeInterval(60 * 60 * 24) // + 1 day
        task.completed = false
        task.notifiable = false
//        task.order = 1
        coreDataManager.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(notificationManager: NotificationManager())
    }
}
