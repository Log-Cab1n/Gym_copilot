# Gym Copilot

<p align="center">
  <img src="assets/logo.png" width="120" alt="Gym Copilot Logo">
</p>

<p align="center">
  <b>你的智能健身助手</b>
</p>

<p align="center">
  <a href="#功能特性">功能特性</a> •
  <a href="#安装">安装</a> •
  <a href="#技术栈">技术栈</a> •
  <a href="#项目结构">项目结构</a>
</p>

---

## 简介

Gym Copilot 是一款专为健身爱好者设计的 Flutter 应用，采用深色极简风格（#0A0A0A 背景），帮助你记录训练、管理动作库、追踪身体数据，让每一次训练都有迹可循。

## 功能特性

### 训练记录
- 训练计时器（带脉冲动画效果）
- 6 大部位选择：胸、背、腿、肩、臂、腹
- 逐组记录重量、次数
- 疲劳度评分（1-10 滑动条）
- 训练状态自动保存（每 10 秒），意外退出可恢复

### 动作库
- 内置丰富训练动作，按部位分类
- 每个动作显示关联部位（如：杠铃卧推 → 胸大肌、肩前束、肱三头肌）
- 搜索与筛选功能
- 使用次数统计，自动排序常用动作
- 查看动作使用历史

### 训练模板
- 创建个性化训练模板
- 为每个动作配置：重量、次数、组数
- 一键加载模板开始训练
- 标签式展示已选动作列表

### 个人数据中心
- 记录体重、身高、体脂率、肌肉量
- 历史趋势追踪
- 最新数据卡片展示
- 日期选择器支持回溯记录

### 数据统计
- 训练时长趋势图（近7天）
- 部位训练分布饼图
- 平均疲劳度追踪
- 总训练天数、总组数统计

### 数据备份与恢复
- 导出备份：生成 JSON 备份文件，包含所有训练数据
- 导入备份：更新版本后一键恢复历史数据
- 跨版本数据迁移，防止更新导致数据丢失

### 其他功能
- 训练计划周期管理
- 休息提醒（训练结束后 2 分钟）
- 深色极简 UI，沉浸体验

## 安装

### 方法一：直接安装 APK

1. 下载最新版 `app-release.apk`（约 23MB）
2. 在 Android 手机上允许"未知来源"安装
3. 点击 APK 文件完成安装

### 方法二：自行构建

```bash
# 克隆仓库
git clone https://github.com/yourusername/gym-copilot.git
cd gym-copilot

# 安装依赖
flutter pub get

# 构建 Release APK
flutter build apk --release

# 安装到设备
flutter install
```

**环境要求：**
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK
- Java 17

## 技术栈

- **框架：** Flutter 3.x + Dart
- **状态管理：** StatefulWidget
- **本地存储：** SQLite (sqflite)
- **图表：** fl_chart
- **日期处理：** intl
- **本地通知：** flutter_local_notifications
- **图标：** Material Design 3

## 项目结构

```
gym_copilot/
├── android/            # Android 平台配置
├── assets/             # 应用图标和图片
├── lib/                # Flutter 源代码
│   ├── data/           # 内置数据（动作、部位标签）
│   ├── database/       # SQLite 数据库操作
│   ├── models/         # 数据模型
│   ├── screens/        # 页面（12 个）
│   │   ├── home_screen.dart
│   │   ├── workout_screen.dart
│   │   ├── workout_templates_screen.dart
│   │   ├── personal_data_screen.dart
│   │   ├── exercise_library_screen.dart
│   │   ├── stats_screen.dart
│   │   ├── plan_screen.dart
│   │   ├── profile_screen.dart
│   │   └── ...
│   └── services/       # 通知服务
├── test/               # 测试文件
├── .gitignore
├── README.md
├── analysis_options.yaml
├── pubspec.lock
└── pubspec.yaml
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

---

<p align="center">
  Made with ❤️ for fitness enthusiasts
</p>
