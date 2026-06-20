# 前端测试

project(WeChatClientTests)

find_package(Qt6 REQUIRED COMPONENTS Test)

# 包含主项目源文件目录（只读）
include_directories(${CMAKE_SOURCE_DIR}/src)

# 配置测试报告输出目录
set(TEST_REPORT_DIR ${CMAKE_BINARY_DIR}/test-reports)
file(MAKE_DIRECTORY ${TEST_REPORT_DIR})

message(STATUS "WeChatClient 测试报告目录: ${TEST_REPORT_DIR}")
