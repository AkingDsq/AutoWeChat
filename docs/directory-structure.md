# 目录结构与模块职责

> 文档版本: v1.0 | 最后更新: 2026-06-20
>
> 相关文档导航:
> - [文档索引](index.md) — 项目概述
> - [系统架构](system-architecture.md) — 分层设计
> - [构建指南](build-guide.md) — CMake 配置

---

## 一、项目根目录

```
AutoWeChat/
  CMakeLists.txt              # 根 CMake 构建入口，project(AutoWeChat)
  CMakePresets.json           # 构建预设 (MSVC 2022 Debug/Release)
  .clang-format               # 代码格式化配置
  .gitignore / .gitattributes  # Git 配置
  README.md
  .vscode/settings.json       # VS Code CMake 源目录配置
```

| 文件 | 职责 |
|------|------|
| `CMakeLists.txt` | 根构建文件，设置 C++17，添加 shared / frontend / backend 子项目 |
| `CMakePresets.json` | CMake 预设：MSVC 2022 x64 Debug/Release，Qt 路径 `E:/Qt/6.10.0/msvc2022_64` |

## 二、shared/ —— 共享库

```
shared/
  CMakeLists.txt              # add_library(wechat_shared_logging STATIC)
  logging/
    LogApi.h                  # 全局日志 API 声明 + 便捷宏
    LogApi.cpp                # 全局日志 API 实现（mutex 保护的全局 logger）
    LoggerService.h           # 日志服务类（QObject，线程安全）
    LoggerService.cpp         # 日志服务实现（2000 条缓冲 + 2MB 文件轮转）
```

**职责**：存放 frontend 和 backend 共用的代码。当前仅包含线程安全的日志库，通过 `wechat_shared_logging` 目标被两端链接。

**关键设计**：
- `LogApi` 命名空间提供全局静态日志函数，使用 `QMutex` 保护全局 logger 指针
- `LoggerService` 继承 `QObject`，支持跨线程日志追加（`QMetaObject::invokeMethod` 自动调度到所属线程）
- 日志宏 `LOG_KEY_INFO/WARNING/ERROR` 简化调用

## 三、proto/ —— Protocol Buffers 定义

```
proto/
  CMakeLists.txt              # 占位（gRPC/protobuf 集成后启用）
  common.proto                # User, TextMessage 基础类型
  auth.proto                  # AuthService: Login, Register, Logout, ValidateToken
  chat.proto                  # ChatService: SendMessage, StreamMessages, GetHistory
  contact.proto               # ContactService: GetContacts, AddContact, DeleteContact, SearchUsers
```

**职责**：定义前后端通信的 gRPC 服务契约。当前仅存放 `.proto` 源文件，不参与 CMake 编译。待 gRPC/protobuf 手动集成后，`CMakeLists.txt` 中的代码生成配置将启用，生成 `.pb.h/.pb.cc` 和 `.grpc.pb.h/.grpc.pb.cc`。

## 四、frontend/ —— Qt QML GUI 客户端

```
frontend/
  CMakeLists.txt              # 子项目入口，find_package Qt6 Quick Qml Gui，windeployqt 设置
  resources/
    resources.qrc             # Qt 资源文件（QML、图标等）
    ui/                       # 图标、字体、图片等资源
  src/
    CMakeLists.txt            # 添加 qml / infrastructure / domain / app 子目录
    qml/
      CMakeLists.txt          # qt_add_qml_module("WeChatClient")，STATIC 库
      Main.qml                # 主窗口 ApplicationWindow（960x540，title "AutoWeChat"）
      views/                  # 页面 QML（待实现：LoginView, ChatListView 等）
      components/             # 可复用 QML 组件（待实现：MessageBubble, ContactItem 等）
    app/
      CMakeLists.txt          # project(WeChatClient)，qt_add_executable
      main.cpp                # QGuiApplication 入口，加载 QML 模块
      viewmodel/
        ApplicationControllerViewModel.h/.cpp  # 根 ViewModel，持有其他 ViewModel
        LogViewModel.h/.cpp                   # 日志 ViewModel（Q_PROPERTY allLogs）
    domain/
      CMakeLists.txt          # add_library(wechat_domain STATIC)
      model/
        User.h                # 用户数据结构
        Message.h             # 文本消息数据结构
    infrastructure/
      CMakeLists.txt          # add_library(wechat_client_infra STATIC)
      grpc/                   # gRPC 客户端实现（待实现）
      storage/                # 本地 SQLite 缓存（待实现）
  tests/
    CMakeLists.txt            # 前端测试脚手架（WeChatClientTests）
```

**分层依赖关系**：
```
qml/Main.qml → app/viewmodel/* → domain/model/* → infrastructure/*
                ↑ 数据绑定        ↑ 纯数据结构        ↑ gRPC/网络/存储
```

| 层 | 编译目标 | 链接依赖 |
|----|---------|---------|
| QML | `wechat_qml` | Qt6::Quick, Qt6::Qml |
| App | `WeChatClient.exe` | wechat_qml, wechat_domain, wechat_client_infra, Qt6::Quick |
| Domain | `wechat_domain` | wechat_client_infra, Qt6::Core |
| Infrastructure | `wechat_client_infra` | wechat_shared_logging, Qt6::Core, Qt6::Quick |

## 五、backend/ —— headless gRPC 服务端

```
backend/
  CMakeLists.txt              # 子项目入口，find_package Qt6 Core Sql（无 GUI 依赖）
  src/
    CMakeLists.txt            # project(WeChatServer)，add_executable
    main.cpp                  # QCoreApplication 入口，待集成 gRPC Server
    server/                   # gRPC Server 封装（待实现）
    service/
      CMakeLists.txt          # add_library(wechat_services STATIC)
      AuthServiceImpl.h/.cpp  # 认证服务骨架
    domain/
      CMakeLists.txt          # add_library(wechat_server_domain STATIC)
      model/
        User.h                # 服务端用户模型
    infrastructure/
      CMakeLists.txt          # add_library(wechat_server_infra STATIC)
      database/               # 数据库层（待实现）
  tests/
    CMakeLists.txt            # 后端测试脚手架（WeChatServerTests）
```

**关键差异 vs 前端**：
- 不依赖 Qt6::Quick、Qt6::Qml、Qt6::Gui
- 使用 `QCoreApplication` 而非 `QGuiApplication`
- 使用 `add_executable` 而非 `qt_add_executable`
- 无 windeployqt 部署步骤

**分层依赖关系**：
```
main.cpp → service/ → domain/ → infrastructure/
           ↑ 业务逻辑   ↑ 数据模型   ↑ 数据库/线程池
```

| 层 | 编译目标 | 链接依赖 |
|----|---------|---------|
| App | `WeChatServer.exe` | wechat_services, wechat_server_domain, wechat_server_infra |
| Service | `wechat_services` | wechat_server_domain, wechat_server_infra |
| Domain | `wechat_server_domain` | wechat_server_infra, Qt6::Core |
| Infrastructure | `wechat_server_infra` | wechat_shared_logging, Qt6::Core, Qt6::Sql |

## 六、tests/ —— 测试

```
tests/
  CMakeLists.txt              # 根级测试入口（由 BUILD_TESTS=ON 激活）
```

前后端测试分别位于 `frontend/tests/` 和 `backend/tests/`。当前为最小脚手架，待功能实现后扩展。

## 七、docs/ —— 技术文档

```
docs/
  index.md                    # 文档索引（导航 + 依赖关系图）
  system-architecture.md      # 系统架构（分层、线程模型、数据流）
  directory-structure.md     # 本文档
  proto-design.md             # Proto 服务定义
  grpc-integration.md         # gRPC 集成方案
  build-guide.md              # 构建指南
  environment-setup.md        # 环境配置
```
