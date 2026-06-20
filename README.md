# AutoWeChat

使用 **Qt6 QML + C++ + gRPC** 复刻微信桌面应用，深度学习 C++ 多线程编程与网络编程。

## 技术栈

| 层 | 技术 |
|---|------|
| 前端 UI | Qt 6.10 QML (Quick Controls) |
| 前端逻辑 | C++17 ViewModel (MVVM) |
| 通信协议 | gRPC + Protocol Buffers |
| 后端平台 | Qt6 QCoreApplication (headless) |
| 数据库 | SQLite (Phase 1) |
| 构建 | CMake 3.21+ / MSVC 2022 |

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

### 配置 & 构建

```bash
# Debug 配置
cmake --preset windows-msvc2022-debug

# 构建前端客户端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatClient --parallel

# 构建后端服务端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatServer --parallel
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

## 项目结构

```
AutoWeChat/
  CMakeLists.txt              # 根构建文件
  CMakePresets.json           # 构建预设 (MSVC 2022)
  shared/logging/             # 共享日志库（线程安全）
  proto/                      # Protocol Buffers 服务定义
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

- [文档索引](docs/index.md)
- [系统架构](docs/system-architecture.md) — MVVM 分层、线程模型、数据流
- [Proto 服务设计](docs/proto-design.md) — gRPC 服务定义
- [gRPC 集成方案](docs/grpc-integration.md) — CompletionQueue、双向流
- [构建指南](docs/build-guide.md) — CMake 配置详解
- [环境配置](docs/environment-setup.md) — 工具链安装
- [目录结构](docs/directory-structure.md) — 模块职责

## 实施阶段

| Phase | 内容 | 状态 |
|-------|------|------|
| Phase 0 | 修复文件结构与 CMake 配置 | ✅ 完成 |
| Phase 1 | 登录 + 联系人 + 一对一文字聊天 | 待实现 |
| Phase 2 | 群聊 + 文件传输 | 规划中 |
| Phase 3 | 朋友圈 + 音视频通话 | 远期 |
