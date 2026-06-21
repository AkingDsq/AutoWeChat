# 系统架构

> 文档版本: v1.1 | 最后更新: 2026-06-21
>
> 相关文档导航:
> - [文档索引](index.md) — 项目概述、技术栈
> - [需求分析](requirements-analysis.md) — 功能需求、用例图
> - [前端设计](frontend-design.md) — 组件树、MVVM 交互
> - [后端设计](backend-design.md) — ER图、Service接口
> - [Proto 服务设计](proto-design.md) — gRPC 服务定义
> - [gRPC 集成方案](grpc-integration.md) — 客户端/服务端实现
> - [测试指南](testing-guide.md) — 测试策略、覆盖矩阵
> - [环境配置](environment-setup.md) — IDE、构建命令

---

## 一、系统架构概览

AutoWeChat 采用 **前后端分离 + MVVM 分层** 架构。前端为 Qt6 QML GUI 桌面应用，后端为 headless QCoreApplication 服务端，两者通过 gRPC 协议通信。

```mermaid
graph TD
    subgraph "前端 WeChatClient (Qt6 QML)"
        QML["QML View<br/>StackView 页面导航"]
        VM["C++ ViewModel 层<br/>Q_PROPERTY / Q_INVOKABLE"]
        DM["Domain Model 层<br/>User, Message, Contact"]
        INFRA_F["Infrastructure 层<br/>gRPC Client / LocalDB"]
        QML --> VM
        VM --> DM
        VM --> INFRA_F
    end

    subgraph "后端 WeChatServer (QCoreApplication)"
        GRPC_S["gRPC Server<br/>监听 0.0.0.0:50051"]
        SVC["Service 层<br/>Auth / Chat / Contact"]
        INFRA_B["Infrastructure 层<br/>Database / ThreadPool"]
        GRPC_S --> SVC
        SVC --> INFRA_B
    end

    subgraph "共享层"
        SHARED["shared/logging<br/>线程安全日志库"]
        PROTO["proto/<br/>.proto 定义"]
    end

    INFRA_F <-.->|"gRPC (TCP)"| GRPC_S
    INFRA_F --> SHARED
    INFRA_B --> SHARED
    SVC --> PROTO
    INFRA_F --> PROTO
```

**图2 系统架构总览**：该图展示了 AutoWeChat 的四层分布式架构。前端遵循 MVVM 模式，QML 通过 Q_PROPERTY 和 Q_INVOKABLE 与 ViewModel 交互。后端为无头 QCoreApplication 进程，通过 gRPC Server 对外暴露服务。共享日志库被前后端同时链接，proto 定义作为前后端通信契约。

## 二、MVVM 分层设计（前端）

### 2.1 分层职责

| 层 | 目录 | 职责 | 依赖方向 |
|----|------|------|---------|
| **View** | `frontend/src/qml/` | QML 声明式 UI，StackView 页面导航，数据绑定 | → ViewModel |
| **ViewModel** | `frontend/src/app/viewmodel/` | Q_PROPERTY 暴露数据，Q_INVOKABLE 暴露操作，协调 Model 和 View | → Model, Infrastructure |
| **Model** | `frontend/src/domain/model/` | 纯数据结构（User, Message, Contact），不含业务逻辑 | — |
| **Infrastructure** | `frontend/src/infrastructure/` | gRPC 客户端、本地数据库、网络监控 | — |

### 2.2 MVVM 数据流

```mermaid
sequenceDiagram
    participant QML as QML View
    participant VM as ViewModel (C++)
    participant GRPC as gRPC Client Thread
    participant Server as gRPC Server

    QML->>VM: 用户操作 (Q_INVOKABLE)
    VM->>GRPC: 发起 gRPC 调用 (异步)
    GRPC-->>VM: 回调通知 (QMetaObject::invokeMethod)
    VM->>VM: 更新 Q_PROPERTY 属性
    VM-->>QML: 属性绑定自动刷新 UI
```

**图3 MVVM 数据流时序图**：该图展示了从前端用户操作到后端服务响应的完整数据流。用户操作通过 Q_INVOKABLE 触发 ViewModel 方法，ViewModel 异步发起 gRPC 调用到专用线程。响应通过 QMetaObject::invokeMethod 安全回主线程，更新 Q_PROPERTY 后 QML 自动刷新。

## 三、多线程模型

### 3.1 前端线程模型

```mermaid
graph TD
    subgraph "Qt 主线程 (Thread 0)"
        QT_MAIN["QML 渲染 + 事件循环<br/>所有 ViewModel 属性更新"]
    end

    subgraph "gRPC 工作线程 (Thread 1)"
        GRPC_THREAD["GrpcClientThread<br/>CompletionQueue::Next() 循环<br/>所有网络 I/O"]
    end

    subgraph "QThreadPool"
        POOL["本地 SQLite 读写<br/>图片解码 / 文件 I/O<br/>CPU 密集型计算"]
    end

    QT_MAIN -->|"QMetaObject::invokeMethod<br/>Qt::QueuedConnection"| GRPC_THREAD
    GRPC_THREAD -->|"GrpcCallbackBridge<br/>QMetaObject::invokeMethod"| QT_MAIN
    QT_MAIN -->|"QtConcurrent::run"| POOL
    POOL -->|"QFutureWatcher::finished"| QT_MAIN
```

**图4 前端线程模型**：该图展示了前端的 3 个线程池设计。主线程负责 QML 渲染和所有 ViewModel 操作，gRPC 线程运行 CompletionQueue 处理网络 I/O，QThreadPool 处理本地任务。跨线程通信统一使用 QMetaObject::invokeMethod + Qt::QueuedConnection，保证线程安全。

### 3.2 后端线程模型

```mermaid
graph TD
    subgraph "主线程"
        MAIN["QCoreApplication<br/>gRPC Server 监听"]
    end

    subgraph "gRPC 内部线程"
        GRPC_INTERNAL["处理 RPC 请求分发<br/>同步/异步 Service 实现"]
    end

    subgraph "QThreadPool"
        DB_POOL["数据库操作<br/>密码哈希<br/>文件操作"]
    end

    MAIN --> GRPC_INTERNAL
    GRPC_INTERNAL -->|"QtConcurrent::run"| DB_POOL
    DB_POOL -->|"结果回传"| GRPC_INTERNAL
```

**图5 后端线程模型**：该图展示了后端的线程架构。主线程运行 QCoreApplication 事件循环和 gRPC Server 监听。gRPC 内部线程池处理 RPC 请求分发。业务逻辑中的数据库操作和 CPU 密集型任务提交到 QThreadPool 异步执行。

### 3.3 线程安全规则

| 场景 | 机制 | 说明 |
|------|------|------|
| Worker → Main 回调 | `QMetaObject::invokeMethod(receiver, func, Qt::QueuedConnection)` | gRPC 响应 → ViewModel 更新 |
| Main → Worker 派发 | `QMetaObject::invokeMethod(worker, func, Qt::QueuedConnection)` | 用户操作 → gRPC 调用 |
| 共享数据保护 | `QMutex` + `QMutexLocker` | 日志条目、Session 管理 |
| 读多写少保护 | `QReadWriteLock` | 联系人列表缓存 |
| 一次性异步任务 | `QtConcurrent::run()` + `QFutureWatcher` | 图片加载、文件哈希 |
| 数据库连接 | 每线程独立 `QSqlDatabase` 连接 | SQLite 线程安全要求 |

## 四、数据流图（0 层 DFD）

```mermaid
flowchart LR
    U[("用户")]

    subgraph "WeChatClient 前端"
        P1["P1: UI 交互处理"]
        P2["P2: gRPC 客户端调度"]
        D1[("LocalDB<br/>SQLite 缓存")]
    end

    subgraph "WeChatServer 后端"
        P3["P3: gRPC 请求路由"]
        P4["P4: 业务逻辑处理"]
        D2[("ServerDB<br/>用户/消息/联系人")]
    end

    U -->|"点击/输入"| P1
    P1 -->|"数据绑定"| P2
    P2 -->|"gRPC 请求"| P3
    P3 -->|"路由"| P4
    P4 <-->|"CRUD"| D2
    P4 -->|"gRPC 响应"| P2
    P2 -->|"更新 ViewModel"| P1
    P1 -->|"UI 刷新"| U
    P1 <-->|"缓存"| D1
```

**图6 0 层数据流图**：该图展示了从用户输入到后端数据存储再返回 UI 的完整数据流。前端通过本地 SQLite 缓存减少网络请求，gRPC 作为前后端唯一的通信通道。后端 Service 层负责业务逻辑编排，Repository 层执行数据持久化。

## 五、gRPC 通信模式

> gRPC 1.78.1 静态库已通过 `third_party/grpc1.78.1/` 集成，proto/CMakeLists.txt 自动生成 `.pb.h/.pb.cc` 和 `.grpc.pb.h/.grpc.pb.cc`。

| 模式 | RPC 方法 | 用途 |
|------|---------|------|
| 一元调用 (Unary) | `Login`, `Register`, `SendMessage`, `GetContacts` | 请求-响应式操作 |
| 双向流 (Bidi Streaming) | `StreamMessages` | 实时消息推送 + 心跳保活 |
| 服务端流 (Server Streaming) | `GetHistory`（可选） | 批量拉取历史消息 |

## 六、技术选型依据

| 决策 | 选择 | 原因 |
|------|------|------|
| 前端框架 | Qt6 QML | 声明式 UI，原生性能，C++ 深度集成 |
| 通信协议 | gRPC | 强类型契约，内置流式传输，跨语言 |
| 后端平台 | Qt6 QCoreApplication | 复用 QSqlDatabase、QThreadPool 等 Qt 基础设施 |
| 数据库 | SQLite | 零配置，单文件，适合学习项目 |
| 构建系统 | CMake 3.21+ | Qt6 官方推荐，跨平台 |
| 依赖管理 | 手动集成第三方 | 学习依赖构建流程，避免 vcpkg 黑盒 |

---

## 七、项目目录结构与模块职责

> 本节内容原为独立的目录结构文档，已合并于此。

### 7.1 项目根目录

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
| `CMakeLists.txt` | 根构建文件，设置 C++17，gRPC 路径，添加 shared / proto / frontend / backend 子项目 |
| `CMakePresets.json` | CMake 预设：MSVC 2022 x64 Debug/Release，Qt 路径 `E:/Qt/6.10.0/msvc2022_64` |

### 7.2 shared/ —— 共享库

```
shared/
  CMakeLists.txt              # add_library(wechat_shared_logging STATIC)
  logging/
    LogApi.h/cpp              # 全局日志 API（线程安全，QMutex + shared_ptr）
    LoggerService.h/cpp       # 日志服务（QObject，2000条缓冲 + 2MB文件轮转）
```

**职责**：存放 frontend 和 backend 共用的代码。当前仅包含线程安全的日志库。

### 7.3 proto/ —— Protocol Buffers 定义（已启用编译）

```
proto/
  CMakeLists.txt              # find_package(gRPC/protobuf) + 代码生成 + wechat_proto 库
  common.proto                # User, TextMessage 基础类型
  auth.proto                  # AuthService: Login, Register, Logout, ValidateToken
  chat.proto                  # ChatService: SendMessage, StreamMessages, GetHistory
  contact.proto               # ContactService: GetContacts, AddContact, DeleteContact, SearchUsers
```

**职责**：定义前后端通信的 gRPC 服务契约。CMake 配置自动生成 C++ 代码（`.pb.h/.pb.cc` + `.grpc.pb.h/.grpc.pb.cc`），打包为 `wechat_proto` 静态库供前后端链接。

### 7.4 frontend/ —— Qt QML GUI 客户端

```
frontend/
  CMakeLists.txt              # find_package Qt6 Quick Qml Gui，windeployqt 设置
  resources/resources.qrc     # Qt 资源文件
  src/
    CMakeLists.txt            # add_subdirectory: qml, infra, domain, app
    qml/
      CMakeLists.txt          # qt_add_qml_module "WeChatClient"，STATIC 库
      Main.qml                # 主窗口 ApplicationWindow (960x540)
      views/                  # 页面 QML（📋 待实现）
      components/             # 可复用 QML 组件（📋 待实现）
    app/
      CMakeLists.txt          # project(WeChatClient)，qt_add_executable
      main.cpp                # QGuiApplication 入口，加载 QML 模块
      viewmodel/
        ApplicationControllerViewModel.h/.cpp  # 根 ViewModel ✅
        LogViewModel.h/.cpp                   # 日志 ViewModel ✅
    domain/
      CMakeLists.txt          # add_library(wechat_domain STATIC)
      model/
        User.h                # 用户数据结构
        Message.h             # 文本消息数据结构
    infrastructure/
      CMakeLists.txt          # add_library(wechat_client_infra STATIC)
      grpc/                   # gRPC 客户端实现（📋 待实现）
      storage/                # 本地 SQLite 缓存（📋 待实现）
  tests/
    CMakeLists.txt            # WeChatClientTests 脚手架
```

| 层 | 编译目标 | 链接依赖 |
|----|---------|---------|
| QML | `wechat_qml` | Qt6::Quick, Qt6::Qml |
| App | `WeChatClient.exe` | wechat_qml, wechat_domain, wechat_client_infra, Qt6::Quick |
| Domain | `wechat_domain` | wechat_client_infra, Qt6::Core |
| Infrastructure | `wechat_client_infra` | wechat_shared_logging, wechat_proto, Qt6::Core, Qt6::Quick |

### 7.5 backend/ —— headless gRPC 服务端

```
backend/
  CMakeLists.txt              # find_package Qt6 Core Sql（无 GUI 依赖）
  src/
    CMakeLists.txt            # project(WeChatServer)，add_executable
    main.cpp                  # QCoreApplication 入口，待集成 gRPC Server
    service/
      CMakeLists.txt          # add_library(wechat_services STATIC)
      AuthServiceImpl.h/.cpp  # 认证服务骨架
    domain/
      CMakeLists.txt          # add_library(wechat_server_domain STATIC)
      model/User.h            # 服务端用户模型
    infrastructure/
      CMakeLists.txt          # add_library(wechat_server_infra STATIC)
      database/               # 数据库层（📋 待实现）
  tests/
    CMakeLists.txt            # WeChatServerTests 脚手架
```

| 层 | 编译目标 | 链接依赖 |
|----|---------|---------|
| App | `WeChatServer.exe` | wechat_services, wechat_server_domain, wechat_server_infra |
| Service | `wechat_services` | wechat_server_domain, wechat_server_infra, wechat_proto |
| Domain | `wechat_server_domain` | wechat_server_infra, Qt6::Core |
| Infrastructure | `wechat_server_infra` | wechat_shared_logging, Qt6::Core, Qt6::Sql |

### 7.6 tests/ + docs/

```
tests/
  CMakeLists.txt              # 根级测试入口（BUILD_TESTS=ON 激活）
  frontend/tests/             # WeChatClientTests
  backend/tests/              # WeChatServerTests

docs/
  index.md                    # 文档索引（导航 + 依赖关系图）
  requirements-analysis.md    # 需求分析（功能需求、用例图、RTM）
  system-architecture.md      # 本文档
  frontend-design.md          # 前端设计
  backend-design.md           # 后端设计
  proto-design.md             # Proto 服务定义
  grpc-integration.md         # gRPC 集成方案
  environment-setup.md        # 环境配置 + 构建指南
  testing-guide.md            # 测试指南
```

### 7.7 CMake 构建目标依赖

```mermaid
graph TD
    CLIENT["WeChatClient.exe"] --> WQML["wechat_qml (QML)"]
    CLIENT --> WDOMAIN["wechat_domain"]
    CLIENT --> WCINFRA["wechat_client_infra"]
    WDOMAIN --> WCINFRA
    WCINFRA --> SHARED["wechat_shared_logging"]
    WCINFRA --> PROTO_LIB["wechat_proto"]

    SERVER["WeChatServer.exe"] --> WSVC["wechat_services"]
    SERVER --> WSDOMAIN["wechat_server_domain"]
    SERVER --> WSINFRA["wechat_server_infra"]
    WSVC --> WSDOMAIN
    WSDOMAIN --> WSINFRA
    WSINFRA --> SHARED
    WSVC --> PROTO_LIB
```

**图7 CMake 目标依赖图**：该图展示了所有 CMake 目标的依赖关系。`wechat_shared_logging` 是两端共享的日志库。`wechat_proto` 同时被前端 `wechat_client_infra` 和后端 `wechat_services` 链接，提供 gRPC 消息类型和服务桩代码。
