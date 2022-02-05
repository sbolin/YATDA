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
    @ObservedObject var todo: TaskEntity
    @ObservedObject private var viewModel = TodoEditViewModel()

    @State private var completed: Bool // = false
    @State private var dateCompleted: Date? // = nil
    @State private var dateCreated: Date // = Date()
    @State private var dateDue: Date // = Date()
    @State private var focused: Bool // = false
    @State private var id: UUID // = UUID()
    @State private var order: Int64 // = 0
    @State private var priority: Priority // = .medium
    @State private var priorityID: Int16 // = 2
    @State private var title: String // = ""

    @State private var error = false

    init(todo: TaskEntity) {
        self.todo = todo
        self._title = State(initialValue: todo.titleString)
        self._completed = State(initialValue: todo.completed)
        self._dateCompleted = State(initialValue: todo.dateCompleted)
        self._dateCreated = State(initialValue: todo.dateCreated ?? Date())
        self._dateDue = State(initialValue: todo.dateDue ?? Date())
        self._focused = State(initialValue: todo.focused)
        self._id = State(initialValue: todo.id ?? UUID())
        self._order = State(initialValue: todo.order)
        self._priority = State(initialValue: Priority.priorityGivenString(todo.priority!))  //
        self._priorityID = State(initialValue: todo.priorityID)
    }

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
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                        }
                    }
                    .colorMultiply(Priority.styleForPriority(priority.rawValue))
                    .pickerStyle(.segmented)
                    .onChange(of: priority) { newPriority in // priority
                        switch newPriority {
                        case .non:
                            priorityID = 0
                        case .low:
                            priorityID = 1
                        case .medium:
                            priorityID = 2
                        case .high:
                            priorityID = 3
                        }
                        priority = newPriority
                    }
                } // Section
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
                } // Section

            } // Form
            // Note: .onAppear not used, values are set via init(). .onAppear sets values after view appears, so too late for picker. init() works properly.
//            .onAppear {
//            }
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
                        saveTodo()
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
        .navigationTitle("Edit Todo")
        .navigationBarTitleDisplayMode(.inline)
    }

    func saveTodo() {
        let values = TodoValues(
            completed: completed,
            dateCompleted: dateCompleted,
            dateCreated: dateCreated,
            dateDue: dateDue,
            focused: focused,
            id: id,
            order: order,
            priority: priority.rawValue,
            priorityID: priorityID,
            title: title)
        viewModel.saveTodo(taskID: todo.objectID, with: values, in: viewContext)
        presentation.wrappedValue.dismiss()

    }
}

struct TodoEditView_Previews: PreviewProvider {
    static var previews: some View {
        TodoEditView(todo: TaskEntity())
    }
}
