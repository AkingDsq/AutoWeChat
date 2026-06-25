# AutoWeChat Project Instructions

本文档用于指导 AI 编码代理在 AutoWeChat 项目内快速、安全地开展工作。

如果项目结构有变化必须同步更新本文档和/docs中技术说明文件。

所有回答都必须使用中文回复。

## 项目定位

- 项目名称：AutoWeChat
- 项目类型：Qt6/C++ 桌面应用 + headless 后端服务
- 主要架构：MVVM + 分层架构 + 前后端分离
- 依赖方向（前端）：QML → app/viewModel → domain/model → infrastructure
- 依赖方向（后端）：main.cpp → service → domain/model → infrastructure
- 通信协议：gRPC + Protocol Buffers

## 技术栈

| 层 | 技术 | 版本 |
|---|------|------|
| 前端 UI | Qt QML (Quick Controls) | 6.10.0 |
| 前端逻辑 | C++ ViewModel (MVVM) | C++17 |
| 通信 | gRPC + Protobuf | 1.78.1 (third_party 预编译) |
| 后端 | Qt QCoreApplication (headless) | 6.10.0 |
| 数据库 | SQLite (Phase 1) | via QSqlDatabase |
| 构建 | CMake | 3.21+ |
| 编译器 | MSVC 2022 | 19.4x |

## 文件结构

```
AutoWeChat/
  CMakeLists.txt              # 根 CMake，C++17，统一管理子项目
  CMakePresets.json           # 构建预设 (MSVC 2022 Debug/Release)
  shared/                     # 前后端共享代码
    logging/                  # 线程安全日志库 (wechat_shared_logging)
  proto/                      # .proto 定义 + wechat_proto 静态库
  frontend/                   # Qt6 QML GUI 客户端
    src/
      qml/                    # QML 界面代码
      app/viewmodel/          # ViewModel 层 (Q_PROPERTY, Q_INVOKABLE)
      domain/model/           # 数据模型 (User, Message, ...)
      infrastructure/         # gRPC 客户端 / 本地存储
  backend/                    # headless 后端服务
    src/
      main.cpp                # QCoreApplication 入口
      service/                # 业务服务层
      domain/model/           # 服务端数据模型
      infrastructure/         # 数据库 / 线程池
  tests/                      # 测试代码
  docs/                       # 技术说明文档
  resources/                  # 资源文件
```

## 分层边界与编码约束

### 分层职责
- QML(View) 只做展示与交互，不承载业务规则。与后端数据交互必须严格遵守MVVM模式，使用ViewModel进行Q_PROPERTY数据双向绑定或Q_INVOKABLE调用后端函数。
- APP(ViewModel) 负责与界面交互，不直接处理业务逻辑。使用Q_PROPERTY声明数据双向绑定或Q_INVOKABLE声明QML可调用函数。
- Domain(Model) 负责业务模型与核心流程语义。
- Infrastructure 负责渲染、IO、网络通信、日志等基础设施。

### 编码约束
- 所有ViewModel类必须以ViewModel结尾，且在ApplicationControllerViewModel中声明统一暴露给QML。
- 所有Model类必须以Model结尾，且不直接暴露给QML。
- 在关键代码中适当添加中文注释，尤其是流程编排、状态管理、数据结构定义等核心部分。
- 在头文件中注意使用注释或空行进行代码划分，保持清晰的结构层次。属性与方法分开排列即使等级相同，且根据功能进行分组。
- 所有头文件引入类时必须使用向前声明原则，避免在头文件中直接包含其他模块的头文件，加快编译速度。
- 不要引入过多的函数，属性，信号，尽量不要在函数中嵌套过多函数，除非有代码复用的需求。
- 代码必须具有健壮性，使用智能指针避免悬空指针、资源泄漏等问题，在使用指针前必须进行空值检查。

## 结构变更时的 CMake 同步要求
- 新增 QML 组件：更新 frontend/src/qml/CMakeLists.txt
- 新增 Domain 代码：更新对应 domain/CMakeLists.txt
- 新增 Infrastructure 代码：更新对应 infrastructure/CMakeLists.txt
- 新增 ViewModel：更新 frontend/src/app/CMakeLists.txt
- 新增 Service：更新 backend/src/service/CMakeLists.txt
- 新增 .proto 文件：更新 proto/CMakeLists.txt 中的 PROTO_FILES 列表
- 新增文件后必须在对应的CMakeLists.txt中添加声明

## 构建与测试命令（Windows + MSVC 2022）

```bash
# windeployqt6 需要在构建前运行一次，以确保 Qt 相关的 DLL 和插件被正确复制到构建目录

# Debug 配置
cmake --preset windows-msvc2022-debug

# 构建 proto 库（验证 gRPC 集成，生成 .pb.h/.pb.cc 和 .grpc.pb.h/.grpc.pb.cc）
cmake --build build/windows-msvc2022-debug --config Debug --target wechat_proto --parallel

# 构建前端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatClient --parallel

# 构建后端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatServer --parallel

# 构建全部
cmake --build build/windows-msvc2022-debug --config Debug --parallel

# 开启测试并配置
cmake --preset windows-msvc2022-debug -DBUILD_TESTS=ON

# 构建全部测试聚合目标
cmake --build build/windows-msvc2022-debug --config Debug --target all_tests --parallel

# 运行测试
ctest --test-dir build/windows-msvc2022-debug -C Debug --output-on-failure
```

## 修改规则

规则必须严格遵守，以保证代码质量和项目维护性：
- 先确定理解需求和设计，再进行编码，避免频繁的重构和修改。如果有不理解的地方不要随便猜，先问，先理解，再决定怎么动手，不要随意变更。
- 用最少的代码改动实现功能，避免大范围修改，尤其是跨层级的修改，能50行解决就不要200行。
- 只修改必须改的部分，并且每一行的代码改动都要解释为什么改，改成什么样，为什么是这个样，为什么不是其他样。
- 在修改或新增功能时，必须首先进行CMake编译，确保编译通过后再进行测试用例的更新。
- 在任务全部完成后必须给出diff以便代码审查。

## 关键技术概念

### gRPC 通信模式
- **一元调用 (Unary)**：Login, Register, SendMessage, GetContacts
- **双向流 (Bidi Streaming)**：StreamMessages（实时消息推送 + 心跳保活）
- **服务端流**：GetHistory（批量拉取历史消息，可选）

### 多线程模型
- 前端：Qt 主线程 (QML/UI) + gRPC CompletionQueue 线程 + QThreadPool
- 后端：QCoreApplication 主线程 + gRPC 内部线程 + QThreadPool
- 跨线程安全：QMetaObject::invokeMethod + Qt::QueuedConnection

### gRPC 第三方库

- gRPC 1.78.1 预编译静态库位于 `third_party/grpc1.78.1/`（Debug + Release 双版本）
- cmake 包配置路径：`lib/cmake/grpc/`、`lib/cmake/protobuf/`
- `find_package(protobuf CONFIG)` 和 `find_package(gRPC CONFIG)` 自动发现
- 可用 cmake target：`gRPC::grpc++`、`protobuf::libprotobuf`、`gRPC::grpc_cpp_plugin`、`protobuf::protoc`
- `third_party/` 由 `.gitignore` 忽略，需单独获取

### gRPC 编码约束

- gRPC Service 实现类必须继承生成的 `Service::Service` 基类
- gRPC 客户端调用必须在专用线程（GrpcClientThread）执行，不得阻塞 Qt 主线程
- 跨线程回调必须使用 `QMetaObject::invokeMethod(receiver, func, Qt::QueuedConnection)`
- proto 文件中的注释会被 protoc 带入生成的 C++ 代码，MSVC 需要 `/utf-8` 编译选项（根 CMakeLists.txt 已配置）