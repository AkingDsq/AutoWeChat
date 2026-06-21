# AutoWeChat

使用 **Qt6 QML + C++ + gRPC** 复刻微信桌面应用，深度学习 C++ 多线程编程与网络编程。

## 技术栈

| 层 | 技术 | 版本 |
|---|------|------|
| 前端 UI | Qt QML (Quick Controls) | 6.10.0 |
| 前端逻辑 | C++ ViewModel (MVVM) | C++17 |
| 通信协议 | gRPC + Protocol Buffers | 1.78.1 (third_party 预编译) |
| 后端平台 | Qt QCoreApplication (headless) | 6.10.0 |
| 数据库 | SQLite (Phase 1) | via QSqlDatabase |
| 构建 | CMake + MSVC 2022 | 3.21+ / 19.4x |

## 快速开始

### 环境要求

- Windows 10/11
- Visual Studio 2022 (MSVC)
- CMake 3.21+
- Qt 6.10.0 (MSVC 2022 64-bit, 安装路径 `E:/Qt/6.10.0/msvc2022_64`)

### 克隆项目

```bash
git clone <repo-url> AutoWeChat
cd AutoWeChat
```

### 获取第三方库

项目依赖 gRPC 1.78.1 预编译包（Debug + Release 双版本），需放置在 `third_party/grpc1.78.1/` 目录下。该目录由 `.gitignore` 忽略，不纳入版本控制。

> 从内部共享位置下载 `grpc1.78.1-win-msvc2022-x64.zip`，解压到 `third_party/grpc1.78.1/`

验证第三方库完整性：

```bash
ls third_party/grpc1.78.1/bin/protoc.exe
ls third_party/grpc1.78.1/lib/cmake/grpc/gRPCConfig.cmake
```

### 配置 & 构建

```bash
# 1. CMake 配置（自动检测 third_party/grpc1.78.1）
cmake --preset windows-msvc2022-debug

# 2. 构建 proto 库（验证 gRPC 集成）
cmake --build build/windows-msvc2022-debug --config Debug --target wechat_proto --parallel

# 3. 构建前端客户端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatClient --parallel

# 4. 构建后端服务端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatServer --parallel

# 5. 构建全部（可选）
cmake --build build/windows-msvc2022-debug --config Debug --parallel
```

### 运行

```bash
# 启动后端服务（headless，监听 0.0.0.0:50051）
./build/windows-msvc2022-debug/backend/src/Debug/WeChatServer.exe

# 启动前端客户端（GUI）
./build/windows-msvc2022-debug/frontend/src/app/Debug/WeChatClient.exe
```

### Release 构建

```bash
cmake --preset windows-msvc2022-release
cmake --build build/windows-msvc2022-release --config Release --parallel
```

### 测试

```bash
cmake --preset windows-msvc2022-debug -DBUILD_TESTS=ON
cmake --build build/windows-msvc2022-debug --config Debug --parallel
ctest --test-dir build/windows-msvc2022-debug -C Debug --output-on-failure
```

## 项目结构

```
AutoWeChat/
  CMakeLists.txt              # 根构建文件（C++17, gRPC 路径, 子项目管理）
  CMakePresets.json           # 构建预设 (MSVC 2022 Debug/Release)
  third_party/grpc1.78.1/    # gRPC 预编译静态库 (.gitignore 忽略)
  shared/logging/             # 共享日志库（线程安全）
  proto/                      # Protocol Buffers 服务定义 + wechat_proto 库
  frontend/                   # Qt6 QML GUI 客户端 (WeChatClient)
    src/
      qml/                    # QML 界面 (Module: WeChatClient)
      app/viewmodel/          # C++ ViewModel (MVVM)
      domain/model/           # 数据模型
      infrastructure/         # gRPC 客户端 / 本地存储
  backend/                    # headless gRPC 服务端 (WeChatServer)
    src/
      service/                # 业务服务实现
      domain/model/           # 服务端数据模型
      infrastructure/         # 数据库 / 线程池
  docs/                       # 技术文档
  tests/                      # 测试
```

## 文档

完整技术文档见 [docs/](docs/) 目录：

| 文档 | 说明 |
|------|------|
| [文档索引](docs/index.md) | 项目概述、技术栈、文档依赖关系图 |
| [需求分析](docs/requirements-analysis.md) | 功能需求表、用例图、验收标准、RTM |
| [系统架构](docs/system-architecture.md) | 分层设计、MVVM、线程模型、目录结构 |
| [前端设计](docs/frontend-design.md) | 组件树、路由、MVVM 交互、状态管理 |
| [后端设计](docs/backend-design.md) | ER图、类图、Service接口、安全鉴权 |
| [Proto 服务设计](docs/proto-design.md) | gRPC 服务定义、消息结构 |
| [gRPC 集成方案](docs/grpc-integration.md) | CompletionQueue、双向流、回调桥接 |
| [环境配置](docs/environment-setup.md) | IDE、Qt 安装、构建命令、常见问题 |
| [测试指南](docs/testing-guide.md) | 测试策略、覆盖矩阵、运行命令 |

## 实施阶段

| Phase | 内容 | 状态 |
|-------|------|------|
| Phase 0 | 文件结构与 CMake 配置 + gRPC 静态库集成 | 🧑‍💻 进行中 |
| Phase 1 | 登录 + 联系人 + 一对一文字聊天 | 待实现 |
| Phase 2 | 群聊 + 文件传输 | 规划中 |
| Phase 3 | 朋友圈 + 音视频通话 | 远期 |
