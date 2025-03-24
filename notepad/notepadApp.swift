//
//  notepadApp.swift
//  notepad
//
//  Created by yuanqi.chen on 2025/3/21.
//

import SwiftUI
import SwiftData

@main
struct notepadApp: App {
    let container: ModelContainer
    @StateObject private var noteViewModel: NoteViewModel
    
    init() {
        do {
            // 使用简单的Schema配置
            let schema = Schema([
                Note.self,
                Category.self,
                Tag.self
            ])
            
            // 使用内存存储进行测试
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true  // 暂时使用内存存储
            )
            
            // 简化容器创建
            let tempContainer = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
            
            // 初始化属性
            self.container = tempContainer
            let viewModel = NoteViewModel(modelContext: tempContainer.mainContext)
            self._noteViewModel = StateObject(wrappedValue: viewModel)
            
            // 创建默认分类
            let context = tempContainer.mainContext
            let fetchDescriptor = FetchDescriptor<Category>(
                predicate: #Predicate<Category> { $0.name == "默认分类" }
            )
            
            let existingCategories = try context.fetch(fetchDescriptor)
            if existingCategories.isEmpty {
                let defaultCategory = Category(name: "默认分类")
                context.insert(defaultCategory)
                try context.save()
            }
        } catch {
            print("SwiftData初始化错误：\(error)")
            fatalError("无法初始化SwiftData容器")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(noteViewModel)
        }
        .modelContainer(container)
    }
}
