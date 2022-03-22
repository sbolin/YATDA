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
    @ObservedObject private var notificationManager = NotificationManager()
    @ObservedObject private var viewModel = TodoEditViewModel()

    @State private var title: String // = ""
    @State private var completed: Bool // = false
    @State private var dateCompleted: Date? // = nil
    @State private var dateCreated: Date // = Date()
    @State private var dateDue: Date // = Date()
    @State private var focused: Bool // = false
    @State private var id: UUID // = UUID()
    @State private var note: String
    @State private var notifiable: Bool
    @State private var notifyTime: Date
    @State private var order: Int64 // = 0
    @State private var priority: Priority // = .medium
    @State private var priorityID: Int16 // = 2

    @State private var error = false

    init(todo: TaskEntity) {
        self.todo = todo
//        self.notificationManager = NotificationManager()
        self._title = State(initialValue: todo.title ?? "")
        self._completed = State(initialValue: todo.completed)
        self._dateCompleted = State(initialValue: todo.dateCompleted)
        self._dateCreated = State(initialValue: todo.dateCreated ?? Date.now)
        self._dateDue = State(initialValue: todo.dateDue ?? Date.now)
        self._focused = State(initialValue: todo.focused)
        self._id = State(initialValue: todo.id ?? UUID())
        self._note = State(initialValue: todo.note ?? "")
        self._notifiable = State(initialValue: todo.notifiable)
        self._notifyTime = State(initialValue: todo.notifyTime ?? Date.now)
        self._order = State(initialValue: todo.order)
        self._priority = State(initialValue: Priority.priorityGivenString(todo.priority!))  //
        self._priorityID = State(initialValue: todo.priorityID)
    }

    var body: some View {
            List {
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
                            .lineLimit(2)
                            .frame(height: 32)
                    }
                    if error {
                        Text("Task is required").foregroundColor(.red)
                    }
                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("Note?")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .font(.body)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                        }
                        TextEditor(text: $note)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .allowsTightening(false)
                            .textInputAutocapitalization(.sentences)
                            .lineLimit(4)
                            .frame(height: 64)
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
                .listRowSeparator(.hidden)

                Section(header: Text("Status")) {
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
                    } // HStack
                    if focused { // focused
                        HStack {
                            Text("Notification")
                            Spacer()
                            Toggle(isOn: $notifiable) {
                                Image(systemName: "bell")
                                    .font(.title2)
                                    .foregroundColor(.pink)
                                    .symbolVariant(notifiable ? .fill : .none)
                            }
                            .toggleStyle(.button)
                            .tint(.clear)
                        }
                        if notifiable {
                            HStack {
                                Text("Notification Time")
                                Spacer()
                                DatePicker("", selection: $notifyTime, displayedComponents: [.hourAndMinute])
                                    .datePickerStyle(.compact)
                            } // HStack
                        }
                    } // focused
                } // Section
                .listRowSeparator(.hidden)

                Section(header: Text("Action")) {
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
                    .padding(.vertical, 8)
//                    .background(Color.white)
                } // Section
                .listRowSeparator(.hidden)
            } // List
            .listStyle(.automatic)
            .navigationTitle("Edit Todo")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.blue.opacity(0.1))
            // Note: .onAppear is not used for setting passed in values, as they are set too late for picker.  setting via init() works properly.
    } // View

    func saveTodo() {
        let values = TodoValues(
            completed: completed,
            dateCompleted: dateCompleted,
            dateCreated: dateCreated,
            dateDue: dateDue,
            focused: focused,
            id: id,
            note: note,
            notifiable: notifiable,
            notifyTime: notifyTime,
            order: order,
            priority: priority.rawValue,
            priorityID: priorityID,
            title: title)
        viewModel.saveTodo(taskID: todo.objectID, with: values, in: viewContext)

        // generate notification if request is focused & notifiable
        if focused && notifiable {
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notifyTime)
            guard let hour = dateComponents.hour, let minute = dateComponents.minute else { return }
            notificationManager.createLocalNotification(title: "Daily Todo Reminder",
                                                        subtitle: "",
                                                        body: title,
                                                        notificationID: id.uuidString,
                                                        hour: hour,
                                                        minute: minute) { error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                }
            }
        } else {
            notificationManager.deleteLocalNotifications(identifiers: [id.uuidString])
        }
        presentation.wrappedValue.dismiss()
    }
}

struct TodoEditView_Previews: PreviewProvider {
    static var previews: some View {
        TodoEditView(todo: TaskEntity())
    }
}
