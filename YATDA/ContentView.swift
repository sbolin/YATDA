//
//  ContentView.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState private var taskIsFocused: Bool

    @State private var title: String = ""
    @State private var selectedPriority: Priority = .medium
    //
    //   @State private var isEditing: EditMode = .inactive
    //

    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.priorityID, ascending: false), NSSortDescriptor(keyPath: \Task.title, ascending: false)])
    var allTasks: FetchedResults<Task>

    private var activeTodo: [Task] {
        allTasks.filter { $0.completed == false && $0.isFavorite == false }
    }

    private var completedTodo: [Task] {
        allTasks.filter { $0.completed == true }
    }

    private var focusTodo: [Task] {
        allTasks.filter { $0.isFavorite == true }
    }

    private var todoIsValid: Bool {
        !title.isEmpty
    }

    private var buttonColor: Color {
        return todoIsValid ? .accentColor : .secondary
    }

    let coreDataManager = CoreDataManager.shared

    //    init() {
    //        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor(Color.accentColor)], for: .selected)
    //        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.blue], for: .normal)
    //        UISegmentedControl.appearance().selectedSegmentTintColor = .blue
    //        UISegmentedControl.appearance().backgroundColor = .yellow

    //    }


    var body: some View {
        NavigationView {
            VStack {
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
                            .foregroundColor(.secondary)                        }
                    }
                    .accentColor(.pink)

                    Section {
                        ForEach(activeTodo) { task in
                            TodoListView(task: task)
                        }
                        .onDelete(perform: deleteTask)
                    } header: {
                        Label("To Do", systemImage: "checkmark.circle")
                            .foregroundColor(.cyan)
                    } footer: {
                        HStack {
                            Spacer()
                            Text("\(activeTodo.count) tasks remain")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accentColor(.cyan)

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
                //                .listStyle(.grouped)
            }
            //            .navigationTitle("YATDA")
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
        task.completed = false
        coreDataManager.save()
    }

    private func deleteTask(at offsets: IndexSet) {
        withAnimation {
            offsets.forEach { offset in
                let task = allTasks[offset]
                coreDataManager.deleteTask(task: task)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataManager.shared.container.viewContext
        ContentView()
            .environment(\.managedObjectContext, context)
    }
}
