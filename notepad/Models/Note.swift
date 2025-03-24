import Foundation
import SwiftData
import SwiftUI

// 用于JSON序列化的Note模型
struct NoteJSON: Codable {
    let id: String
    let title: String
    let content: String
    let categoryID: String?
    let tagIDs: [String]
    let isPinned: Bool
    let images: [Data]
    let imageDescriptions: [String]
    let reminder: Date?
    let isReminderActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    init(from note: Note) {
        self.id = note.id
        self.title = note.title
        self.content = note.content
        self.categoryID = note.categoryID
        self.tagIDs = note.tagIDs
        self.isPinned = note.isPinned
        self.images = note.images
        self.imageDescriptions = note.imageDescriptions
        self.reminder = note.reminder
        self.isReminderActive = note.isReminderActive
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
    }
}

@Model
final class Note {
    @Attribute(.unique) var id: String
    var title: String
    var content: String
    var categoryID: String?
    @Attribute(originalName: "tagIDs") private var _tagIDs: Data
    var isPinned: Bool
    @Attribute(originalName: "images") private var _images: Data
    @Attribute(originalName: "imageDescriptions") private var _imageDescriptions: Data
    var reminder: Date?
    var isReminderActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    var tagIDs: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: _tagIDs)) ?? []
        }
        set {
            _tagIDs = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    var images: [Data] {
        get {
            (try? JSONDecoder().decode([Data].self, from: _images)) ?? []
        }
        set {
            _images = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    var imageDescriptions: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: _imageDescriptions)) ?? []
        }
        set {
            _imageDescriptions = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    init(title: String = "", content: String = "") {
        self.id = UUID().uuidString
        self.title = title
        self.content = content
        self._tagIDs = try! JSONEncoder().encode([String]())
        self.isPinned = false
        self._images = try! JSONEncoder().encode([Data]())
        self._imageDescriptions = try! JSONEncoder().encode([String]())
        self.isReminderActive = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func update(title: String? = nil, content: String? = nil, categoryID: String? = nil) {
        if let title = title {
            self.title = title
        }
        if let content = content {
            self.content = content
        }
        if let categoryID = categoryID {
            self.categoryID = categoryID
        }
        self.updatedAt = Date()
    }
    
    func addImage(_ imageData: Data, description: String = "") {
        images.append(imageData)
        imageDescriptions.append(description)
        self.updatedAt = Date()
    }
    
    func removeImage(at index: Int) {
        guard index < images.count else { return }
        images.remove(at: index)
        if index < imageDescriptions.count {
            imageDescriptions.remove(at: index)
        }
        self.updatedAt = Date()
    }
    
    func setReminder(date: Date?) {
        self.reminder = date
        self.isReminderActive = date != nil
        self.updatedAt = Date()
    }
    
    func togglePin() {
        self.isPinned.toggle()
        self.updatedAt = Date()
    }
    
    func addTagID(_ tagID: String) {
        if !tagIDs.contains(tagID) {
            tagIDs.append(tagID)
        }
    }
    
    func removeTagID(_ tagID: String) {
        tagIDs.removeAll(where: { $0 == tagID })
    }
}

@Model
final class Category {
    @Attribute(.unique) var id: String
    var name: String
    var createdAt: Date
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.createdAt = Date()
    }
}

@Model
final class Tag {
    @Attribute(.unique) var id: String
    var name: String
    var createdAt: Date
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.createdAt = Date()
    }
} 