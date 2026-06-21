# AutoWeChat 技术文档

> 文档版本: v1.1 | 最后更新: 2026-06-21
>
> 相关文档导航:
> - [需求分析](requirements-analysis.md) — 功能需求、用例图、验收标准
> - [系统架构](system-architecture.md) — 分层设计、MVVM、线程模型、数据流
> - [前端设计](frontend-design.md) — 组件树、路由、MVVM 交互、状态管理
> - [后端设计](backend-design.md) — ER图、类图、Service接口、安全鉴权
> - [Proto 服务设计](proto-design.md) — gRPC 服务定义、消息结构
> - [gRPC 集成方案](grpc-integration.md) — CompletionQueue、双向流、回调桥接
> - [测试指南](testing-guide.md) — 测试策略、覆盖矩阵、运行命令
> - [环境配置](environment-setup.md) — IDE、Qt 安装、工具链、构建命令

---

## 项目简介

AutoWeChat 是一个使用 **Qt6 QML + C++ + gRPC** 复刻微信桌面应用的学习项目，核心目标是深度学习 C++ 多线程编程和网络编程。项目采用前后端分离架构：

- **前端**：Qt6 QML GUI 客户端（MVVM 模式），负责界面展示与用户交互
- **后端**：Qt6 QCoreApplication headless 服务端，负责业务逻辑与数据持久化
- **共享层**：日志库等前后端公用代码
- **Proto 层**：Protocol Buffers 服务定义（gRPC 通信契约）

## 技术栈

| 层 | 技术 | 用途 |
|---|------|------|
| 前端 UI | Qt 6.10 QML (Quick Controls) | 声明式 UI |
| 前端逻辑 | C++17 ViewModels (MVVM) | Q_PROPERTY 绑定 QML |
| 通信协议 | gRPC 1.78.1 + Protocol Buffers | 前后端 RPC 通信（third_party 预编译） |
| 后端平台 | Qt6 QCoreApplication | 无头进程，复用 QSqlDatabase、QThreadPool |
| 数据库 | SQLite (Phase 1) | 零配置，单文件 |
| 构建系统 | CMake 3.21+ | 跨平台构建 |
| 编译器 | MSVC 2022 | Windows 原生编译 |

## 文档依赖关系

```mermaid
graph LR
    INDEX["📑 文档索引"] --> REQ["📋 需求分析"]
    INDEX --> ENV["🔧 环境配置"]
    REQ --> ARCH["🏗️ 系统架构"]
    ARCH --> FE["🎨 前端设计"]
    ARCH --> BE["⚙️ 后端设计"]
    ARCH --> PROTO["📡 Proto 设计"]
    FE --> GRPC["🔌 gRPC 集成"]
    BE --> GRPC
    PROTO --> GRPC
    FE --> TEST["🧪 测试指南"]
    BE --> TEST
    REQ --> TEST

    style INDEX fill:#e1f5fe
    style REQ fill:#e8f5e9
    style ARCH fill:#f3e5f5
    style FE fill:#e0f2f1
    style BE fill:#fff3e0
    style PROTO fill:#e8eaf6
    style GRPC fill:#fce4ec
    style ENV fill:#f5f5f5
    style TEST fill:#f1f8e9
```

**图1 文档依赖关系图**：该图展示了各文档之间的前置依赖关系。文档索引是入口，环境配置为所有开发工作提供基础。需求分析是设计的起点，系统架构是核心枢纽。前端/后端设计依赖架构决策，gRPC 集成方案依赖 Proto 设计和前后端设计。测试指南依赖需求分析（追溯）和设计文档（验证路径）。阅读建议：从上到下、从左到右。

## 快速开始

```bash
# 1. CMake 配置（自动检测 third_party/grpc1.78.1）
cmake --preset windows-msvc2022-debug

# 2. 构建 proto 库（验证 gRPC 集成）
cmake --build build/windows-msvc2022-debug --config Debug --target wechat_proto --parallel

# 3. 构建前端客户端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatClient --parallel

# 4. 构建后端服务端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatServer --parallel

# 5. 运行客户端
./build/windows-msvc2022-debug/frontend/src/app/Debug/WeChatClient.exe

# 6. 运行服务端
./build/windows-msvc2022-debug/backend/src/Debug/WeChatServer.exe
```

## 实施阶段

| Phase | 内容 | 状态 |
|-------|------|------|
| Phase 0 | 文件结构与 CMake 配置 + gRPC 静态库集成 | 🧑‍💻 进行中 |
| Phase 1 | 登录 + 联系人 + 一对一文字聊天 | 待实现 |
| Phase 2 | 群聊 + 文件传输 | 规划中 |
| Phase 3 | 朋友圈 + 音视频通话 | 规划中 |
