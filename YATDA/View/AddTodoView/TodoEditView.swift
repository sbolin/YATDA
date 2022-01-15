//
//  TodoEditView.swift
//  YATDA
//
//  Created by Scott Bolin on 13-Jan-22.
//

import CoreData
import SwiftUI

struct TodoEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentation

    @State private var completed: Bool = false
    @State private var dateCompleted: Date? = nil
    @State private var dateCreated: Date = Date()
    @State private var dateDue: Date = Date()
    @State private var focused: Bool = false
    @State private var id: UUID = UUID()
    @State private var priority: String = "Medium"
    @State private var priorityID: Int16 = 1
    @State private var title: String = ""

    @State private var error = false

    var task: NSManagedObjectID?
    let viewModel = TodoEditViewModel()

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Task")) {
                    // use ZStack to mimic TextField title (TextEditor does not have this)
                    ZStack(alignment: .topLeading) {
                        if title.isEmpty {
                            Text("Task?")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .font(.body)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                        }
                        TextEditor(text: $title)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .allowsTightening(false)
                            .textInputAutocapitalization(.sentences)
                            .frame(minHeight: 72)
                    }
                    if error {
                        Text("Task is required").foregroundColor(.red)
                    }
                    DatePicker("Creation Date", selection: $dateCreated, displayedComponents: .date)
                    DatePicker("Due Date", selection: $dateDue, displayedComponents: .date)
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { priority in
                            Text(priority.title).tag(priority)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                        }
                    }
                    .colorMultiply(Priority.styleForPriority(priority))
                    .pickerStyle(.segmented)
                }
                Section("Status") {
                    HStack {
                        Text("Focus")
                        Spacer()
                        Toggle(isOn: $focused) {
                            Image(systemName: focused ? "target": "scope")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .toggleStyle(.button)
                        .tint(.clear)
                    }
                    HStack {
                        Text("Completed")
                        Spacer()
                        Toggle(isOn: $completed) {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(.green)
                                .symbolVariant(completed ? .fill : .none)
                        }
                        .toggleStyle(.button)
                        .tint(.clear)
                    }
                }

            } // Form
            Spacer()
            HStack {
                Button {
                    presentation.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                }
                .buttonStyle(.bordered)
                .accentColor(.red)

                Spacer()

                Button {
                    if title.isEmpty {
                        error = title.isEmpty
                    } else {
                        addTask()
                    }
                } label: {
                    Text("Save")
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .accentColor(.green)
                .disabled(title.isEmpty)
            } // HStack
            .padding(.horizontal, 30)
        } // VStack
        .navigationTitle("\(task == nil ? "Add Todo" : "Edit Todo")")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard let taskID = task else { return }
            guard let todo = viewModel.fetchTodo(for: taskID, context: viewContext) else { return }
            title = todo.titleString
            completed = todo.completed
            dateCreated = todo.dateCreated ?? Date()
            dateDue = todo.dateDue ?? Date().advanced(by: 24 * 60 * 60)
            dateCompleted = todo.dateCompleted ?? nil
            focused = todo.focused
            id = todo.id ?? UUID()
            priority = todo.priority ?? "Medium"
            priorityID = todo.priorityID
        }
    }

    func addTask() {
        priorityID = 1
        if focused { priorityID = 0 }
        if completed { priorityID = 2 }
        let values = TodoValues(
            completed: completed,
            dateCompleted: dateCompleted,
            dateCreated: dateCreated,
            dateDue: dateDue,
            focused: focused,
            id: id,
            priority: priority,
            priorityID: priorityID,
            title: title)
        viewModel.saveTodo(taskID: task, with: values, in: viewContext)
    }
}

struct TodoEditView_Previews: PreviewProvider {
    static var previews: some View {
        TodoEditView()
    }
}

/*
 @NSManaged public var priority: String?
 @NSManaged public var priorityID: Int16
 @NSManaged public var title: String?
 */
