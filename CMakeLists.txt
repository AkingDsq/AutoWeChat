cmake_minimum_required(VERSION 3.21)

project(AutoWeChat VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 全局开启 Qt 自动编译
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 基础 Qt 组件（shared 日志库需要 Core）
find_package(Qt6 REQUIRED COMPONENTS Core)

# 构建选项
option(BUILD_FRONTEND "构建 WeChat 客户端 GUI 应用" ON)
option(BUILD_BACKEND "构建 WeChat 服务端应用" ON)
option(BUILD_TESTS "构建测试" OFF)

# 共享库（日志等）
add_subdirectory(shared)

# proto/ 暂不参与编译，待 gRPC/protobuf 手动集成后启用
# add_subdirectory(proto)

# 前端 Qt QML GUI 客户端
if(BUILD_FRONTEND)
    add_subdirectory(frontend)
endif()

# 后端 headless gRPC 服务端
if(BUILD_BACKEND)
    add_subdirectory(backend)
endif()

# 测试
if(BUILD_TESTS)
    enable_testing()
    include(CTest)
    add_subdirectory(tests)
endif()
