//
//  ContentView.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let coreDataManager: CoreDataManager = .shared

    @FetchRequest<TaskEntity>(
        sortDescriptors: [
            SortDescriptor(\TaskEntity.priorityID, order: .reverse),
            SortDescriptor(\TaskEntity.title, order: .forward),
            SortDescriptor(\TaskEntity.dateCreated, order: .reverse)
        ],
        animation: .default)
    private var allTasks: FetchedResults<TaskEntity>

//    @FocusState private var taskIsFocused: Bool
    @State private var title: String = ""
    @State private var selectedPriority: Priority = .medium
    @State private var selectedSort = RequestSort.default
    //
    //   @State private var isEditing: EditMode = .inactive
    //

    private var activeTodo: [TaskEntity] {
        allTasks
            .filter { $0.completed == false && $0.focused == false }
    }

    private var completedTodo: [TaskEntity] {
        allTasks
            .filter { $0.completed == true }
    }

    private var focusTodo: [TaskEntity] {
        allTasks
            .filter { $0.focused == true }
    }

    var body: some View {
        NavigationView {
                VStack {
                    // add new todo...
                    AddTaskView()
                    List {
                        // Focus Task Section
                        Section {
                            ForEach(focusTodo) { taskItem in
                                ZStack(alignment: .leading) {
                                    NavigationLink(destination: TodoEditView(task: taskItem.objectID)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    TodoListRowView(task: taskItem)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        deleteTask(task: taskItem)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
//                            .onDelete { deleteTask(at: $0) }
                        } header: {
                            Label("Focus", systemImage: "target")
                                .foregroundColor(.pink)
                        } footer: {
                            HStack {
                                Spacer()
                                Text("\(focusTodo.count) Focus Task")
                                    .font(.footnote)
                                .foregroundColor(.secondary)
                            }
                        }
//                        .listRowSeparator(.hidden)
                        .accentColor(.pink)

                        // Active Task Section
                        Section {
                            ForEach(activeTodo) { taskItem in
                                ZStack(alignment: .leading) {
                                    NavigationLink(destination: TodoEditView(task: taskItem.objectID)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    TodoListRowView(task: taskItem)
                                }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            deleteTask(task: taskItem)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                            }
//                            .onDelete { deleteTask(at: $0) }
                        } header: {
                            Label("To Do", systemImage: "checkmark.circle")
                                .foregroundColor(.blue)
                        } footer: {
                            HStack {
                                Spacer()
                                if activeTodo.count == 1 {
                                    Text("\(activeTodo.count) Task Remains")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                } else {
                                Text("\(activeTodo.count) Tasks Remain")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
//                        .listRowSeparator(.hidden)
                        .accentColor(.blue)

                        // Completed Task Section
                        Section {
                            ForEach(completedTodo) { taskItem in
                                ZStack(alignment: .leading) {
                                    NavigationLink(destination: TodoEditView(task: taskItem.objectID)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    TodoListRowView(task: taskItem)
                                }                                    .swipeActions {
                                        Button(role: .destructive) {
                                            deleteTask(task: taskItem)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                            }
//                            .onDelete { deleteTask(at: $0) }
                        } header: {
                            Label("Done", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } footer: {
                            HStack {
                                Spacer()
                                if completedTodo.count == 1 {
                                    Text("\(completedTodo.count) Completed Task")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("\(completedTodo.count) Completed Tasks")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
//                        .listRowSeparator(.hidden)
                        .accentColor(.green)
                    } // List
                    .listSectionSeparator(.hidden)
//                    .listRowSeparator(.hidden)
                } // VStack
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        SortSelectionView(selectedSortItem: $selectedSort, sorts: RequestSort.sorts)
                            .onChange(of: selectedSort) { _ in
                                let request = allTasks
                                request.sortDescriptors = selectedSort.descriptors
                            } // onChange
                    } // ToolbarItemGroup

                    ToolbarItemGroup(placement: .principal) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                            Text("YATDA").font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                    } // ToolbarItem
                } // toolbar
            .navigationBarTitleDisplayMode(.inline)
        } // NavigationView
        .environment(\.defaultMinListHeaderHeight, 40)
    } // View

    private func deleteTask(task: TaskEntity) {
        withAnimation {
            coreDataManager.deleteTask(task: task, context: viewContext)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
        coreDataManager.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}


