import SwiftUI
import SwiftData
import PhotosUI

struct NoteEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query(filter: #Predicate<Category> { $0.name == "默认分类" }) private var defaultCategory: [Category]
    @Query private var tags: [Tag]
    @Bindable var note: Note
    
    @State private var title: String
    @State private var content: String
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingTagSheet = false
    @State private var showingReminderPicker = false
    @State private var newTagName = ""
    @State private var selectedCategory: Category?
    @State private var showingDeleteAlert = false
    @State private var fontSize: CGFloat = 16
    @State private var hasChanges = false
    private let isNewNote: Bool
    @FocusState private var isEditing: Bool
    @State private var showingReminderError = false
    @State private var reminderErrorMessage = ""
    
    init(note: Note) {
        self.note = note
        self.isNewNote = note.title.isEmpty && note.content.isEmpty
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
        _selectedCategory = State(initialValue: nil)
    }
    
    private var noteTags: [Tag] {
        tags.filter { note.tagIDs.contains($0.id) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.accentColor)
                }
                
                TextField("标题", text: $title)
                    .font(.title2.bold())
                    .textInputAutocapitalization(.never)
                    .onChange(of: title) { _, _ in
                        hasChanges = true
                    }
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextEditor(text: $content)
                        .font(.system(size: fontSize))
                        .frame(minHeight: 200)
                        .focused($isEditing)
                        .onChange(of: content) { _, _ in
                            hasChanges = true
                        }
                    
                    if !note.images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<note.images.count, id: \.self) { index in
                                    if let uiImage = UIImage(data: note.images[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                Button(action: { removeImage(at: index) }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                }
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                                .padding(8),
                                                alignment: .topTrailing
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if !noteTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(noteTags) { tag in
                                    HStack {
                                        Text(tag.name)
                                        Button(action: { note.removeTagID(tag.id) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            
            if isEditing {
                formatToolbar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    if isNewNote {
                        modelContext.delete(note)
                    }
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveNote()
                    dismiss()
                }
                .disabled(!hasChanges)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("分类", selection: $selectedCategory) {
                        ForEach(categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                    .onChange(of: selectedCategory) { oldValue, newValue in
                        hasChanges = true
                    }
                    
                    Button(action: { note.togglePin() }) {
                        Label(
                            note.isPinned ? "取消置顶" : "置顶笔记",
                            systemImage: note.isPinned ? "pin.slash" : "pin"
                        )
                    }
                    
                    Button(action: { showingTagSheet = true }) {
                        Label("添加标签", systemImage: "tag")
                    }
                    
                    Button(action: { showingImagePicker = true }) {
                        Label("添加图片", systemImage: "photo")
                    }
                    
                    Button(action: { showingReminderPicker = true }) {
                        Label("设置提醒", systemImage: "bell")
                    }
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingTagSheet) {
            NavigationStack {
                List {
                    Section("现有标签") {
                        ForEach(tags) { tag in
                            Button(action: { note.addTagID(tag.id) }) {
                                HStack {
                                    Text(tag.name)
                                    Spacer()
                                    if note.tagIDs.contains(tag.id) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("新建标签") {
                        HStack {
                            TextField("标签名称", text: $newTagName)
                            Button("添加") {
                                if !newTagName.isEmpty {
                                    let tag = Tag(name: newTagName)
                                    modelContext.insert(tag)
                                    note.addTagID(tag.id)
                                    newTagName = ""
                                }
                            }
                            .disabled(newTagName.isEmpty)
                        }
                    }
                }
                .navigationTitle("管理标签")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            showingTagSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingReminderPicker) {
            NavigationStack {
                Form {
                    if note.isReminderActive, let reminder = note.reminder {
                        Section {
                            HStack {
                                Text("当前提醒时间")
                                Spacer()
                                Text(reminder.formatted())
                            }
                            
                            Button("删除提醒", role: .destructive) {
                                note.setReminder(date: nil)
                                NotificationManager.shared.cancelNotification(for: note)
                                showingReminderPicker = false
                            }
                        }
                    }
                    
                    Section {
                        DatePicker(
                            "提醒时间",
                            selection: Binding(
                                get: { note.reminder ?? Date() },
                                set: { note.setReminder(date: $0) }
                            ),
                            in: Date()...
                        )
                    }
                }
                .navigationTitle("设置提醒")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("确定") {
                            handleReminderSetting()
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .alert("提醒设置失败", isPresented: $showingReminderError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(reminderErrorMessage)
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) {
                deleteNote()
                dismiss()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要删除这个笔记吗？此操作不可撤销。")
        }
        .onAppear {
            if let categoryID = note.categoryID {
                selectedCategory = categories.first(where: { $0.id == categoryID })
            } else if isNewNote, let defaultCat = defaultCategory.first {
                selectedCategory = defaultCat
                note.categoryID = defaultCat.id
            }
        }
        .onChange(of: selectedImage) { oldValue, newImage in
            if let newImage = newImage,
               let imageData = newImage.jpegData(compressionQuality: 0.8) {
                note.addImage(imageData)
                hasChanges = true
            }
            selectedImage = nil
        }
        .onChange(of: selectedCategory) { oldValue, newValue in
            note.categoryID = newValue?.id
            hasChanges = true
        }
    }
    
    private var formatToolbar: some View {
        HStack {
            Button(action: { fontSize -= 2 }) {
                Image(systemName: "textformat.size.smaller")
            }
            .disabled(fontSize <= 12)
            
            Button(action: { fontSize += 2 }) {
                Image(systemName: "textformat.size.larger")
            }
            .disabled(fontSize >= 24)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(.bar)
    }
    
    private func saveNote() {
        let categoryID = selectedCategory?.id ?? defaultCategory.first?.id
        
        note.update(
            title: title,
            content: content,
            categoryID: categoryID
        )
        try? modelContext.save()
        hasChanges = false
    }
    
    private func removeImage(at index: Int) {
        note.removeImage(at: index)
        hasChanges = true
    }
    
    private func deleteNote() {
        if note.isReminderActive {
            NotificationManager.shared.cancelNotification(for: note)
        }
        modelContext.delete(note)
        try? modelContext.save()
    }
    
    private func handleReminderSetting() {
        Task {
            if note.isReminderActive {
                let success = await NotificationManager.shared.scheduleNotification(for: note)
                if !success {
                    await MainActor.run {
                        reminderErrorMessage = "设置提醒失败，请检查是否已授予通知权限"
                        showingReminderError = true
                        // 如果设置失败，重置提醒状态
                        note.setReminder(date: nil)
                    }
                }
            }
            await MainActor.run {
                showingReminderPicker = false
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Note.self, Category.self, Tag.self,
            configurations: config
        )
        // 创建测试数据
        let context = container.mainContext
        let defaultCategory = Category(name: "默认分类")
        context.insert(defaultCategory)
        let testNote = Note(title: "测试笔记", content: "这是一个测试笔记的内容")
        context.insert(testNote)
        
        return NavigationStack {
            NoteEditView(note: testNote)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
} 