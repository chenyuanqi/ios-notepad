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
            container = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
            
            // 创建默认分类
            createDefaultCategoryIfNeeded()
        } catch {
            print("SwiftData初始化错误：\(error)")
            fatalError("无法初始化SwiftData容器")
        }
    }
    
    private func createDefaultCategoryIfNeeded() {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate<Category> { $0.name == "默认分类" }
        )
        
        do {
            let existingCategories = try context.fetch(fetchDescriptor)
            if existingCategories.isEmpty {
                let defaultCategory = Category(name: "默认分类")
                context.insert(defaultCategory)
                try context.save()
            }
        } catch {
            print("创建默认分类时出错：\(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
