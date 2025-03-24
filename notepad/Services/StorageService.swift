import Foundation

class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Notes Storage
    func saveNotes(_ notes: [Note]) {
        let noteJSONs = notes.map { NoteJSON(from: $0) }
        if let encoded = try? JSONEncoder().encode(noteJSONs) {
            userDefaults.set(encoded, forKey: Constants.StorageKeys.notes)
        }
    }
    
    func loadNotes() -> [Note] {
        guard let data = userDefaults.data(forKey: Constants.StorageKeys.notes),
              let noteJSONs = try? JSONDecoder().decode([NoteJSON].self, from: data) else {
            return []
        }
        
        // 将NoteJSON转换回Note对象
        return noteJSONs.map { json in
            let note = Note(title: json.title, content: json.content)
            note.id = json.id
            note.categoryID = json.categoryID
            note.tagIDs = json.tagIDs
            note.isPinned = json.isPinned
            note.images = json.images
            note.imageDescriptions = json.imageDescriptions
            note.reminder = json.reminder
            note.isReminderActive = json.isReminderActive
            note.createdAt = json.createdAt
            note.updatedAt = json.updatedAt
            return note
        }
    }
    
    // MARK: - Settings Storage
    func saveSettings(_ settings: [String: Any]) {
        userDefaults.set(settings, forKey: Constants.StorageKeys.settings)
    }
    
    func loadSettings() -> [String: Any] {
        return userDefaults.dictionary(forKey: Constants.StorageKeys.settings) ?? [:]
    }
} 