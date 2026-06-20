# 前端 WeChat 客户端 GUI 应用

find_package(Qt6 REQUIRED COMPONENTS Quick Qml Gui)

# 设置 windeployqt 路径（Windows平台专用）
if(WIN32)
    set(WINDEPLOYQT "" CACHE FILEPATH "Path to windeployqt6 executable")

    if("${WINDEPLOYQT}" STREQUAL "")
        if(Qt6_HOST_BINS)
            set(WINDEPLOYQT "${Qt6_HOST_BINS}/windeployqt6.exe" CACHE FILEPATH "Path to windeployqt6 executable" FORCE)
            message(STATUS "Using Qt6_HOST_BINS for windeployqt: ${WINDEPLOYQT}")
        else()
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
                set(WINDEPLOYQT "windeployqt6" CACHE FILEPATH "Path to windeployqt6 executable" FORCE)
                message(WARNING "windeployqt6 not found in standard locations. Using 'windeployqt6' command (must be in PATH).")
            endif()
        endif()
    endif()

    message(STATUS "WINDEPLOYQT = ${WINDEPLOYQT}")
endif()

# Qt 6 CMake policies
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

add_subdirectory(src)
