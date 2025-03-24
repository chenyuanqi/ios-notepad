import Foundation

enum Constants {
    static let appName = "Notepad"
    static let defaultNoteTitle = "新笔记"
    static let defaultNoteContent = ""
    
    // 存储键
    enum StorageKeys {
        static let notes = "notes"
        static let settings = "settings"
    }
    
    // 通知标识符
    enum NotificationIdentifiers {
        static let noteReminder = "noteReminder"
    }
} 