# Notepad iOS App

一个简洁优雅的iOS笔记应用，使用SwiftUI开发。

## 项目结构

```
notepad/
├── Models/           # 数据模型
│   └── Note.swift    # 笔记数据模型
├── ViewModels/       # 视图模型
│   └── NoteViewModel.swift  # 笔记业务逻辑
├── Views/           # 视图
│   └── Components/  # 可复用组件
│       └── AppIcon.swift
├── Resources/       # 资源文件
│   ├── Components/  # UI组件
│   └── Screens/     # 页面视图
│       ├── ContentView.swift
│       └── NoteEditView.swift
├── Services/        # 服务层
│   ├── StorageService.swift
│   └── NotificationManager.swift
├── Utilities/       # 工具类
│   ├── IconExporter.swift
│   └── ImagePicker.swift
└── Constants/       # 常量配置
    ├── Theme.swift
    └── Constants.swift
```

## 功能特性

- 创建、编辑、删除笔记
- 支持富文本编辑
- 笔记分类管理
- 标签系统
- 本地通知提醒
- 自定义应用图标

## 技术栈

- SwiftUI
- Combine
- SwiftData
- UserNotifications

## 开发环境要求

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 安装说明

1. 克隆项目
2. 打开 `notepad.xcodeproj`
3. 选择目标设备
4. 点击运行按钮

## 使用说明

1. 主界面显示所有笔记列表
2. 点击右上角"+"按钮创建新笔记
3. 点击笔记进入编辑界面
4. 在编辑界面可以设置提醒时间
5. 支持添加标签和分类

## 贡献指南

欢迎提交Issue和Pull Request来帮助改进这个项目。

## 许可证

本项目采用 MIT 许可证。