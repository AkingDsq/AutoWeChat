# 环境配置

> 文档版本: v1.0 | 最后更新: 2026-06-20
>
> 相关文档导航:
> - [文档索引](index.md) — 快速开始
> - [构建指南](build-guide.md) — 编译命令

---

## 一、开发环境要求

| 组件 | 版本 | 下载地址 | 说明 |
|------|------|---------|------|
| Windows | 10 / 11 | — | 开发与运行操作系统 |
| Visual Studio 2022 | 17.x Community | https://visualstudio.microsoft.com/ | 选择"使用 C++ 的桌面开发"工作负载 |
| CMake | 3.21+ | https://cmake.org/download/ | 勾选"Add CMake to system PATH" |
| Qt 6 | 6.10.0 | https://www.qt.io/download | 安装 MSVC 2022 64-bit 组件 |
| Git | 2.x | https://git-scm.com/ | 版本控制 |
| VS Code (可选) | latest | https://code.visualstudio.com/ | 推荐安装 CMake Tools 和 Qt 插件 |

## 二、Qt 安装

1. 下载 Qt Online Installer 或使用 Qt Maintenance Tool
2. 选择 Qt 6.10.0 → MSVC 2022 64-bit
3. 安装路径建议：`E:/Qt/6.10.0/msvc2022_64`
4. 将 `E:/Qt/6.10.0/msvc2022_64/bin` 添加到系统 PATH（可选，方便直接运行 Qt 工具）

验证安装：

```bash
# 检查 qmake 版本
E:/Qt/6.10.0/msvc2022_64/bin/qmake --version

# 检查 windeployqt
E:/Qt/6.10.0/msvc2022_64/bin/windeployqt6 --help
```

## 三、Visual Studio 2022 配置

1. 安装时选择 **"使用 C++ 的桌面开发"** 工作负载
2. 确保包含以下组件：
   - MSVC v143 - VS 2022 C++ x64/x86 生成工具
   - Windows 11 SDK (10.0.22621.0+)
   - 适用于 Windows 的 CMake 工具（或单独安装 CMake）
3. 安装后打开 "Developer Command Prompt for VS 2022" 验证：

```bash
cl --version   # 应显示 Microsoft (R) C/C++ Optimizing Compiler Version 19.4x
```

## 四、VS Code 配置（可选）

项目已配置 `.vscode/settings.json`：

```json
{
    "cmake.sourceDirectory": "D:/git/work/AutoWeChat"
}
```

推荐的 VS Code 扩展：
- **CMake Tools** (ms-vscode.cmake-tools)：CMake 集成、预设选择、一键构建
- **Qt for Python / Qt Tools**：QML 语法高亮与代码补全
- **clangd**：C++ 智能提示（替代默认 C++ 扩展）

### 使用 CMake Tools 构建

1. `Ctrl+Shift+P` → "CMake: Select Configure Preset" → 选择 "windows-msvc2022-debug"
2. `Ctrl+Shift+P` → "CMake: Build" 或点击底部状态栏 Build 按钮
3. 构建目标可以在底部状态栏切换（WeChatClient / WeChatServer）

## 五、第三方依赖说明

项目当前不依赖任何第三方库（日志功能使用纯 Qt API）。以下依赖将在后续 Phase 中手动集成：

| 依赖 | Phase | 用途 |
|------|-------|------|
| gRPC C++ | Phase 1 | RPC 通信框架 |
| Protobuf | Phase 1 | 消息序列化 |
| SQLite3 (bundled with Qt) | Phase 1 | 数据持久化 |

第三方库通过手动 CMake 编译后，在 `third_party/` 目录中作为外部项目引入。集成方式详见 [gRPC 集成方案](grpc-integration.md)。

## 六、验证环境

```bash
# 1. 克隆项目
git clone <repo-url> AutoWeChat
cd AutoWeChat

# 2. CMake 配置
cmake --preset windows-msvc2022-debug

# 3. 构建前端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatClient --parallel

# 4. 构建后端
cmake --build build/windows-msvc2022-debug --config Debug --target WeChatServer --parallel

# 5. 运行前端
./build/windows-msvc2022-debug/frontend/src/app/Debug/WeChatClient.exe
```

如果前端窗口正常显示（960x540，标题 "AutoWeChat"），后端控制台输出 "WeChat Server starting on port 50051..."，则环境配置正确。
