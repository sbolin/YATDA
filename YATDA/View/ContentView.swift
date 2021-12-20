//
//  ContentView.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let coreDataManager: CoreDataManager = .shared

    @FetchRequest<Task>(
        sortDescriptors: [
            SortDescriptor(\Task.priorityID, order: .reverse),
            SortDescriptor(\Task.dateCreated, order: .reverse)
        ],
        animation: .default)
    private var allTasks: FetchedResults<Task>

    @FocusState private var taskIsFocused: Bool
    @State private var title: String = ""
    @State private var selectedPriority: Priority = .medium
    //
    //   @State private var isEditing: EditMode = .inactive
    //

    private var activeTodo: [Task] {
        allTasks
            .filter { $0.completed == false && $0.isFavorite == false }
//            .sorted { $0.priorityID < $1.priorityID }
//            .sorted { $0.dateCreated ?? Date() < $1.dateCreated ?? Date() }

    }

    private var completedTodo: [Task] {
        allTasks
            .filter { $0.completed == true }
//            .sorted { $0.priorityID < $1.priorityID }
//            .sorted { $0.dateCreated ?? Date() < $1.dateCreated ?? Date() }
    }

    private var focusTodo: [Task] {
        allTasks
            .filter { $0.isFavorite == true }
    }

    private var todoIsValid: Bool {
        !title.isEmpty
    }

    private var buttonColor: Color {
        return todoIsValid ? .accentColor : .secondary
    }

    var body: some View {
        NavigationView {
            VStack {
                // add new todo...
                Group {
                    TextField("Enter task", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .focused($taskIsFocused)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(Priority.allCases) { priority in
                            Text(priority.title).tag(priority)
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
                    .frame(width: 125, height: 35)
                    .background(buttonColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                List {
                    Section {
                        ForEach(focusTodo) { task in
                            TodoListView(task: task)
                        }
                        .onDelete(perform: deleteTask)
                    } header: {
                        Label("Focus", systemImage: "target")
                            .foregroundColor(.pink)
                    } footer: {
                        HStack {
                            Spacer()
                            Text("\(focusTodo.count) Focus Tasks")
                                .font(.footnote)
                            .foregroundColor(.secondary)
                        }
                    }
                    .accentColor(.pink)

                    Section {
                        ForEach(activeTodo) { task in
                            TodoListView(task: task)
                        }
                        .onDelete(perform: deleteTask)
                    } header: {
                        Label("To Do", systemImage: "checkmark.circle")
                            .foregroundColor(.blue)
                    } footer: {
                        HStack {
                            Spacer()
                            Text("\(activeTodo.count) tasks remain")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accentColor(.blue)

                    Section {
                        ForEach(completedTodo) { task in
                            TodoListView(task: task)
                        }
                        .onDelete(perform: deleteTask)
                    } header: {
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } footer: {
                        HStack {
                            Spacer()
                            Text("\(completedTodo.count) completed tasks")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accentColor(.green)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                        Text("YATDA").font(.title2).bold()
                            .foregroundColor(.green)
                    }
                }
                //                ToolbarItem(placement: .navigationBarTrailing) {
                //                    EditButton()
                //                        .buttonStyle(.bordered)
                //                }
            }
            //            .environment(\.editMode, $isEditing)
        }
        .environment(\.defaultMinListHeaderHeight, 40)
    }

    private func saveTask() {
        let task = Task(context: viewContext)
        task.title = title
        task.id = UUID()
        task.priority = selectedPriority.rawValue
        switch selectedPriority {
        case .low:
            task.priorityID = 0
        case .medium:
            task.priorityID = 1
        case .high:
            task.priorityID = 2
        }
        task.dateCreated = Date()
        // for now...
        task.dateDue = Date().addingTimeInterval(60 * 60 * 24) // + 1 day
        task.completed = false
        coreDataManager.save()
    }

    private func deleteTask(at offsets: IndexSet) {
        withAnimation {
            offsets.forEach { index in
                let task = allTasks[index]
                coreDataManager.deleteTask(task: task, context: viewContext)
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = CoreDataManager.container.viewContext
//        ContentView()
//            .environment(\.managedObjectContext, context)
//    }
//}
