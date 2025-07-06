import Foundation

// Task model to represent a to-do item
struct Task: Identifiable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var dueDate: Date? = nil
    var notes: String = ""
}