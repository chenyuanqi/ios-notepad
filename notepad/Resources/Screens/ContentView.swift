import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]
    @Query(sort: \Category.createdAt) private var categories: [Category]
    @Query private var tags: [Tag]
    @State private var isAddingNewNote = false
    @State private var searchText = ""
    @State private var newNote: Note?
    @State private var selectedCategory: Category?
    @State private var selectedTag: Tag?
    @State private var isAddingCategory = false
    @State private var isAddingTag = false
    @State private var newCategoryName = ""
    @State private var newTagName = ""
    @State private var showingSortMenu = false
    @State private var showingDeleteError = false
    @State private var deleteErrorMessage = ""
    
    private func getNoteTags(for note: Note) -> [Tag] {
        return tags.filter { note.tagIDs.contains($0.id) }
    }
    
    private func canDeleteCategory(_ category: Category) -> Bool {
        let hasNotes = notes.contains { $0.categoryID == category.id }
        if hasNotes {
            deleteErrorMessage = "请先删除该分类下的笔记，再进行删除操作"
            showingDeleteError = true
            return false
        }
        return true
    }
    
    private func canDeleteTag(_ tag: Tag) -> Bool {
        let hasNotes = notes.contains { $0.tagIDs.contains(tag.id) }
        if hasNotes {
            deleteErrorMessage = "请先删除包含该标签的笔记，再进行删除操作"
            showingDeleteError = true
            return false
        }
        return true
    }
    
    var filteredNotes: [Note] {
        var filtered = notes
        
        // 按分类筛选
        if let category = selectedCategory {
            filtered = filtered.filter { $0.categoryID == category.id }
        }
        
        // 按标签筛选
        if let tag = selectedTag {
            filtered = filtered.filter { $0.tagIDs.contains(tag.id) }
        }
        
        // 按搜索文本筛选
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                getNoteTags(for: note).contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // 置顶笔记排在前面
        return filtered.sorted { note1, note2 in
            if note1.isPinned && !note2.isPinned {
                return true
            }
            if !note1.isPinned && note2.isPinned {
                return false
            }
            return note1.updatedAt > note2.updatedAt
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedCategory) {
                NavigationLink(destination: NoteListView(notes: notes, title: "所有笔记")) {
                    Label("所有笔记", systemImage: "note.text")
                }
                
                Section("分类") {
                    ForEach(categories) { category in
                        NavigationLink(destination: NoteListView(
                            notes: notes.filter { $0.categoryID == category.id },
                            title: category.name
                        )) {
                            Label(category.name, systemImage: "folder")
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if canDeleteCategory(category) {
                                    modelContext.delete(category)
                                }
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                    
                    Button(action: { isAddingCategory = true }) {
                        Label("添加分类", systemImage: "plus")
                    }
                }
                
                Section("标签") {
                    if tags.isEmpty {
                        Text("暂无标签")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(tags) { tag in
                            NavigationLink(destination: NoteListView(
                                notes: notes.filter { $0.tagIDs.contains(tag.id) },
                                title: "#\(tag.name)"
                            )) {
                                Label("#\(tag.name)", systemImage: "tag")
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    if canDeleteTag(tag) {
                                        modelContext.delete(tag)
                                    }
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    Button(action: { isAddingTag = true }) {
                        Label("添加标签", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("记事本")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let note = Note()
                        modelContext.insert(note)
                        newNote = note
                        isAddingNewNote = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .alert("无法删除", isPresented: $showingDeleteError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(deleteErrorMessage)
            }
        } detail: {
            List {
                ForEach(filteredNotes) { note in
                    NavigationLink(destination: NoteEditView(note: note)) {
                        NoteRowView(note: note, tags: getNoteTags(for: note))
                    }
                }
            }
            .navigationTitle(selectedCategory?.name ?? selectedTag?.name ?? "所有笔记")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "搜索笔记")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingSortMenu = true }) {
                            Label("排序", systemImage: "arrow.up.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingNewNote) {
            if let note = newNote {
                NavigationStack {
                    NoteEditView(note: note)
                }
            }
        }
        .alert("新建分类", isPresented: $isAddingCategory) {
            TextField("分类名称", text: $newCategoryName)
            Button("取消", role: .cancel) {
                newCategoryName = ""
            }
            Button("确定") {
                if !newCategoryName.isEmpty {
                    let category = Category(name: newCategoryName)
                    modelContext.insert(category)
                    newCategoryName = ""
                }
            }
        }
        .alert("新建标签", isPresented: $isAddingTag) {
            TextField("标签名称", text: $newTagName)
            Button("取消", role: .cancel) {
                newTagName = ""
            }
            Button("确定") {
                if !newTagName.isEmpty {
                    let tag = Tag(name: newTagName)
                    modelContext.insert(tag)
                    newTagName = ""
                }
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tags: [Tag]
    let notes: [Note]
    let title: String
    
    private func getNoteTags(for note: Note) -> [Tag] {
        return tags.filter { note.tagIDs.contains($0.id) }
    }
    
    var body: some View {
        List {
            ForEach(notes) { note in
                NavigationLink(destination: NoteEditView(note: note)) {
                    NoteRowView(note: note, tags: getNoteTags(for: note))
                }
            }
        }
        .navigationTitle(title)
        .listStyle(.insetGrouped)
    }
}

struct NoteRowView: View {
    let note: Note
    let tags: [Tag]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.accentColor)
                }
                
                Text(note.title.isEmpty ? "无标题" : note.title)
                    .font(.headline)
                
                Spacer()
                
                if note.isReminderActive, let reminder = note.reminder {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.accentColor)
                        .help(dateFormatter.string(from: reminder))
                }
            }
            
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            if !note.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<note.images.count, id: \.self) { index in
                            if let uiImage = UIImage(data: note.images[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .frame(height: 70)
            }
            
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Text(dateFormatter.string(from: note.updatedAt))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
} 