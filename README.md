# 记事本 App

一个简洁优雅的iOS记事本应用，基于SwiftUI和SwiftData开发。

## 功能特点

- 创建、编辑和删除笔记
- 实时自动保存
- 优雅的用户界面设计
- 支持文本格式化
- 本地数据持久化存储
- 支持iOS 16及以上版本

## 技术架构

- 开发语言：Swift 5.9
- UI框架：SwiftUI
- 数据持久化：SwiftData
- 最低支持版本：iOS 16.0
- 设计模式：MVVM

## 项目结构

```
notepad/
├── Models/        # 数据模型
├── Views/         # UI视图
├── ViewModels/    # 视图模型
└── Utilities/     # 工具类
```

## 开发环境要求

- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

## 如何运行

1. 克隆项目到本地
2. 使用Xcode打开notepad.xcodeproj
3. 选择目标设备或模拟器
4. 点击运行按钮或按Command+R

## 开发规范

- 使用SwiftUI构建用户界面
- 遵循MVVM架构模式
- 使用SwiftData进行数据持久化
- 代码注释完整，遵循Swift API设计规范