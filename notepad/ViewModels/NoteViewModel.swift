import Foundation
import SwiftUI
import SwiftData

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var selectedNote: Note?
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadNotes()
    }
    
    // MARK: - Note Management
    func addNote(_ note: Note) {
        modelContext.insert(note)
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        modelContext.delete(note)
        saveNotes()
    }
    
    // MARK: - Persistence
    private func saveNotes() {
        do {
            try modelContext.save()
        } catch {
            print("保存笔记失败：\(error)")
        }
    }
    
    private func loadNotes() {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        do {
            notes = try modelContext.fetch(descriptor)
        } catch {
            print("加载笔记失败：\(error)")
            notes = []
        }
    }
} 