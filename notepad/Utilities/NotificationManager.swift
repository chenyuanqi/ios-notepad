import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private var hasPermission = false
    
    private init() {
        checkNotificationPermission()
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
                print("通知权限状态：\(settings.authorizationStatus.rawValue)")
                print("通知设置：\n- 声音：\(settings.soundSetting.rawValue)\n- 横幅：\(settings.alertSetting.rawValue)\n- 标记：\(settings.badgeSetting.rawValue)")
            }
        }
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            DispatchQueue.main.async {
                self.hasPermission = granted
                print("通知权限请求结果：\(granted ? "成功" : "失败")")
            }
            return granted
        } catch {
            print("通知权限获取失败：\(error.localizedDescription)")
            return false
        }
    }
    
    func scheduleNotification(for note: Note) async -> Bool {
        guard let reminder = note.reminder, note.isReminderActive else {
            print("无法设置提醒：reminder为空或提醒未激活")
            return false
        }
        
        // 如果没有权限，先请求权限
        if !hasPermission {
            print("尝试请求通知权限...")
            let granted = await requestAuthorization()
            if !granted {
                print("用户拒绝了通知权限")
                return false
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "笔记提醒"
        content.body = note.title.isEmpty ? "查看您的笔记" : note.title
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        print("设置提醒：\n- 标题：\(content.title)\n- 内容：\(content.body)\n- 时间：\(reminder)")
        
        let request = UNNotificationRequest(
            identifier: "note-reminder-\(note.id)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("提醒设置成功")
            
            // 验证提醒是否真的设置成功
            let pendingRequests = await getPendingNotifications()
            let found = pendingRequests.contains { $0.identifier == "note-reminder-\(note.id)" }
            print("验证提醒：\(found ? "成功" : "失败")")
            
            return true
        } catch {
            print("设置提醒失败：\(error.localizedDescription)")
            return false
        }
    }
    
    func cancelNotification(for note: Note) {
        print("取消笔记提醒：\(note.id)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["note-reminder-\(note.id)"]
        )
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                print("当前待处理的提醒数量：\(requests.count)")
                for request in requests {
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        print("- \(request.identifier): \(trigger.dateComponents)")
                    }
                }
                continuation.resume(returning: requests)
            }
        }
    }
} 