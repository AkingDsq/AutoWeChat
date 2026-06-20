# 独立测试项目，不污染主构建
# 测试代码完全独立于生产代码，通过 BUILD_TESTS 选项控制

project(3DEleSimulationTests)

find_package(Qt6 REQUIRED COMPONENTS Test)
# 包含主项目源文件目录（只读，不修改）
include_directories(${CMAKE_SOURCE_DIR}/src)

# 配置测试报告输出目录
set(TEST_REPORT_DIR ${CMAKE_BINARY_DIR}/test-reports)
file(MAKE_DIRECTORY ${TEST_REPORT_DIR})

# 添加 GUI 测试
add_subdirectory(gui)

# 添加功能测试
add_subdirectory(functional)

# 测试目标汇总（便于一次性构建所有测试）
add_custom_target(all_tests DEPENDS
    gui_tests
    application_controller_viewmodel_tests
    sparameter_workflow_gui_tests
    functional_tests
    workflow_functional_tests
)

# 测试标签配置（便于选择性执行测试）
if(ENABLE_UNIT_TESTS)
    add_subdirectory(unit)
    add_dependencies(all_tests unit_tests)
endif()

message(STATUS "测试报告目录: ${TEST_REPORT_DIR}")
message(STATUS "GUI 测试: 已启用")
message(STATUS "功能测试: 已启用")
if(ENABLE_UNIT_TESTS)
    message(STATUS "单元测试: 已启用")
else()
    message(STATUS "单元测试: 未启用 (使用 ENABLE_UNIT_TESTS=ON 启用)")
endif()