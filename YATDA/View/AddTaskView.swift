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

    @State var title: String = ""
    @FocusState private var taskIsFocused: Bool
    @State private var selectedPriority: Priority = .medium

    private var buttonColor: Color {
        return todoIsValid ? .accentColor : .secondary
    }

    private var todoIsValid: Bool {
        !title.isEmpty
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField("Enter New Task", text: $title)
            //            .textFieldStyle(.roundedBorder)
                .padding(6)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green, lineWidth: 2))
            //                .background(Color.green.opacity(0.3), in: RoundedRectangle(cornerRadius: 6))
                .focused($taskIsFocused)
                .textInputAutocapitalization(.words)

            Picker("Priority", selection: $selectedPriority) {
                ForEach(Priority.allCases) { priority in
                    Text(priority.title).tag(priority)
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
            .frame(width: 90, height: 32)
            .background(buttonColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .circular))
            Divider()
        }.padding(.horizontal)
    }

    private func saveTask() {
        let task = TaskEntity(context: viewContext)
        task.title = title
        task.id = UUID()
        task.priority = selectedPriority.rawValue
        switch selectedPriority {
        case .low:
            task.priorityID = 1
        case .medium:
            task.priorityID = 2
        case .high:
            task.priorityID = 3
        case .non:
            task.priorityID = 0
        }
        task.dateCreated = Date()
        // for now...
        task.dateDue = Date().addingTimeInterval(60 * 60 * 24) // + 1 day
        task.completed = false
        task.order = 1
        coreDataManager.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
