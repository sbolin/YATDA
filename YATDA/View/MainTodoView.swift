//
//  MainTodoView.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI
import WidgetKit

struct MainTodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var notificationManager = NotificationManager()
    let coreDataManager: CoreDataManager = .shared

    @FetchRequest<TaskEntity>(
        sortDescriptors: [
            //            SortDescriptor(\TaskEntity.order, order: .forward),
            SortDescriptor(\TaskEntity.priorityID, order: .reverse),
            //            SortDescriptor(\TaskEntity.dateCreated, order: .reverse)
            SortDescriptor(\TaskEntity.title, order: .forward)
        ],
        animation: .default)
    private var allTasks: FetchedResults<TaskEntity>

    //    @FocusState private var taskIsFocused: Bool
    //    @State private var title: String = ""
    //    @State private var selectedPriority: Priority = .medium
    @State private var selectedSort = RequestSort.default
    //
    //    @State private var editMode: EditMode = .inactive
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

    let backgroundGradient = LinearGradient(
        colors: [Color.blue.opacity(0.05), Color.white.opacity(0.05)],
        startPoint: .top, endPoint: .bottom)

    var body: some View {
        NavigationView {
            VStack(spacing: 6) {
                // add new todo...
                AddTaskView(notificationManager: notificationManager)
                    .padding(.top, 4)
                List {
                    // Focus Task Section
                    Section {
                        ForEach(focusTodo) { taskItem in
                            ZStack(alignment: .leading) {
                                NavigationLink(destination: TodoEditView(todo: taskItem)) {
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
                    } header: {
                        Label("Focus", systemImage: "target")
                            .font(.body)
                            .foregroundColor(.pink)
                    } footer: {
                        HStack {
                            Spacer()
                            Text("\(focusTodo.count) Focus Task")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .accentColor(.pink)

                    // Active Task Section
                    Section {
                        ForEach(activeTodo) { taskItem in
                            ZStack(alignment: .leading) {
                                //                                NavigationLink(destination: TodoEditView(task: taskItem.objectID)) {
                                NavigationLink(destination: TodoEditView(todo: taskItem)) {
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
                        //                        .onMove(perform: move)
                        //                        .onInsert(of: [.text], perform: insert)
                    } header: {
                        Label("To Do", systemImage: "checkmark.circle")
                            .font(.body)
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
                    .listRowSeparator(.hidden)
                    .accentColor(.blue)

                    // Completed Task Section
                    Section {
                        ForEach(completedTodo) { taskItem in
                            ZStack(alignment: .leading) {
                                //                                NavigationLink(destination: TodoEditView(task: taskItem.objectID)) {
                                NavigationLink(destination: TodoEditView(todo: taskItem)) {
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
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .font(.body)
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
                    .listRowSeparator(.hidden)
                    .accentColor(.green)
                } // List
                .listRowBackground(Color.clear)
                .listStyle(.automatic)
                .onAppear(perform: notificationManager.reloadAuthorizationStatus)
                .onChange(of: notificationManager.authorizationStatus) { authStatus in
                    switch authStatus {
                    case .notDetermined:
                        notificationManager.requestAuthorization()
                    case .authorized:
                        notificationManager.reloadLocalNotifications()
                    default:
                        break
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    notificationManager.reloadAuthorizationStatus()
                }
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
                    } // HStack
                } // ToolbarItemGroup

                //                ToolbarItemGroup(placement: .navigationBarTrailing) {
                //                    EditButton()
                //                        .tint(.green)
                //                } // ToolbarItemGroup
            } // toolbar
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.blue.opacity(0.1))
        } // NavigationView
        .environment(\.defaultMinListHeaderHeight, 32)
        .accentColor(.green)
    } // View

    private func move(from source: IndexSet, to destination: Int) {
        // try to use activeTodo rather than revisedItems. If works, keep it, otherwise change activeTodo back to revisedItems

        //        var revisedItems: [TaskEntity] = activeTodo.map { $0 }

        let itemToMove = source.first! // guard ... else { return }
        if itemToMove == destination { return }
        if itemToMove < destination {
            var startIndex = itemToMove + 1
            let endIndex = destination - 1
            var startOrder = activeTodo[itemToMove].order
            while startIndex <= endIndex {
                activeTodo[startIndex].order = startOrder
                startOrder += 1
                startIndex += 1
            }
            activeTodo[itemToMove].order = startOrder
        } else if destination < itemToMove {
            var startIndex = destination
            let endIndex = itemToMove - 1
            var startOrder = activeTodo[destination].order + 1
            let newOrder = activeTodo[destination].order
            while startIndex <= endIndex {
                activeTodo[startIndex].order = startOrder
                startOrder += 1
                startIndex += 1
            }
            activeTodo[itemToMove].order = newOrder
        }
        //        activeTodo.move(fromOffsets: source, toOffset: destination)
        coreDataManager.save()

        //        revisedItems.move(fromOffsets: source, toOffset: destination)
        //        if let oldIndex = source.first, oldIndex != destination {
        //            let newIndex = oldIndex < destination ? destination - 1 : destination
        //        }
        //
        //        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
        //            revisedItems[reverseIndex].order = Int64(reverseIndex)
        //        }
    }

    //    private func insert(at offset: Int, itemProvider: [NSItemProvider]) {
    //        for provider in itemProvider {
    //            if provider.canLoadObject(ofClass: String.self) {
    //                _ = provider.loadObject(ofClass: String.self) { item, error in
    //                    DispatchQueue.main.async {
    //                        item.map { self.items.insert(TaskEntity(title: $0.absoluteString), at: offset) }
    //                    }
    //                }
    //            }
    //        }
    //    }

    private func deleteTask(task: TaskEntity) {
        withAnimation {
            if let identifier = task.id?.uuidString {
                notificationManager.deleteLocalNotifications(identifiers: [identifier])
            }
            coreDataManager.deleteTask(task: task, context: viewContext)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTodoView()
    }
}


