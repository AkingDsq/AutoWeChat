cmake_minimum_required(VERSION 3.21)

project(AutoWeChat VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 开启自动编译
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml Core Gui)

# 设置 windeployqt 路径（Windows平台专用）
if(WIN32)
    # 优先使用缓存变量，允许用户在配置时覆盖
    set(WINDEPLOYQT "" CACHE FILEPATH "Path to windeployqt6 executable")

    # 如果用户未指定，尝试自动查找
    if("${WINDEPLOYQT}" STREQUAL "")
        if(Qt6_HOST_BINS)
            # 使用 Qt6 提供的 host binaries 路径
            set(WINDEPLOYQT "${Qt6_HOST_BINS}/windeployqt6.exe" CACHE FILEPATH "Path to windeployqt6 executable" FORCE)
            message(STATUS "Using Qt6_HOST_BINS for windeployqt: ${WINDEPLOYQT}")
        else()
            # 尝试在常见Qt安装路径中查找
            find_program(WINDEPLOYQT_PROG
                NAMES windeployqt6 windeployqt
                PATHS
                    "$ENV{QT_DIR}/bin"
                    "$ENV{QT_PREFIX}/bin"
                    "C:/Qt/*/msvc2022_64/bin"
                    "D:/Qt/*/msvc2022_64/bin"
                    "E:/Qt/*/msvc2022_64/bin"
                DOC "Path to windeployqt6 executable"
            )

            if(WINDEPLOYQT_PROG)
                set(WINDEPLOYQT "${WINDEPLOYQT_PROG}" CACHE FILEPATH "Path to windeployqt6 executable" FORCE)
                message(STATUS "Found windeployqt: ${WINDEPLOYQT}")
            else()
                # 最终回退：使用windeployqt6命令（期望在PATH中）
                set(WINDEPLOYQT "windeployqt6" CACHE FILEPATH "Path to windeployqt6 executable" FORCE)
                message(WARNING "windeployqt6 not found in standard locations. Using 'windeployqt6' command (must be in PATH).")
            endif()
        endif()
    endif()

    message(STATUS "WINDEPLOYQT = ${WINDEPLOYQT}")
endif()


# Qt 6 CMake policies
qt_policy(SET QTP0001 NEW)  # 设置 QML 资源前缀，默认 :/qt/qml/（Qt6 推荐）
qt_policy(SET QTP0004 NEW)  # 需要 qmldir；使用 qt_add_qml_module 时自动生成

add_subdirectory(src)

# 测试模块配置（完全独立，不影响生产代码）
# 默认关闭，正式版打包时设置 BUILD_TESTS=OFF 即可排除测试代码
option(BUILD_TESTS "Build tests" OFF)
message(STATUS "BUILD_TESTS = ${BUILD_TESTS}")

if(BUILD_TESTS)
    enable_testing()
    include(CTest)

    # 可选：Google Test 支持（默认关闭，仅用于单元测试）
    # option(ENABLE_UNIT_TESTS "Enable Google Test for unit tests" OFF)

    # if(ENABLE_UNIT_TESTS)
    #     include(FetchContent)
    #     FetchContent_Declare(
    #         googletest
    #         GIT_REPOSITORY https://github.com/google/googletest.git
    #         GIT_TAG v1.14.0
    #     )

    #     if(WIN32)
    #         set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    #     endif()

    #     FetchContent_MakeAvailable(googletest)
    # endif()

    # 添加独立的测试目录
    add_subdirectory(tests)
endif()