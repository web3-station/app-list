//
//  ContentView.swift
//  ListAPP
//
//  Created by user274669 on 2025/7/5.
//

import SwiftUI

struct ContentView: View {
    // State to store the list of tasks
    @State private var tasks: [Task] = [
        Task(title: "Task Demo", notes: "empty notes"),
        Task(title: "Task Demo2", isCompleted: true, dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), notes: "Complete the to-do list app"),
        Task(title: "Task Demo3", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()))
    ]
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var editingTask: Task? = nil

    var body: some View {
        NavigationView {
            List {
                if tasks.isEmpty {
                    Text("No tasks yet. Add a new task to get started!")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(tasks) { task in
                        TaskRow(task: task, onToggle: {
                            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                tasks[index].isCompleted.toggle()
                            }
                        }, onEdit: {
                            editingTask = task
                        })
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
            .navigationTitle("To-Do List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(isPresented: $showingAddTask, tasks: $tasks)
            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task, tasks: $tasks, isPresented: Binding(
                    get: { editingTask != nil },
                    set: { if !$0 { editingTask = nil } }
                ))
            }
        }
    }

    // Function to delete tasks
    private func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

// View for a single task row
struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }

            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

// View for adding a new task
struct AddTaskView: View {
    @Binding var isPresented: Bool
    @Binding var tasks: [Task]
    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)

                    Toggle("Set Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    let newTask = Task(
                        title: title,
                        dueDate: hasDueDate ? dueDate : nil,
                        notes: notes
                    )
                    tasks.append(newTask)
                    isPresented = false
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

// View for editing an existing task
struct EditTaskView: View {
    let task: Task
    @Binding var tasks: [Task]
    @Binding var isPresented: Bool

    @State private var title: String
    @State private var notes: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var isCompleted: Bool

    init(task: Task, tasks: Binding<[Task]>, isPresented: Binding<Bool>) {
        self.task = task
        self._tasks = tasks
        self._isPresented = isPresented

        _title = State(initialValue: task.title)
        _notes = State(initialValue: task.notes)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _hasDueDate = State(initialValue: task.dueDate != nil)
        _isCompleted = State(initialValue: task.isCompleted)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)

                    Toggle("Completed", isOn: $isCompleted)

                    Toggle("Set Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                        var updatedTask = task
                        updatedTask.title = title
                        updatedTask.notes = notes
                        updatedTask.dueDate = hasDueDate ? dueDate : nil
                        updatedTask.isCompleted = isCompleted
                        tasks[index] = updatedTask
                    }
                    isPresented = false
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

#Preview {
    ContentView()
}
