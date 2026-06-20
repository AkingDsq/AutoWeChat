# 定义库目标 (STATIC 静态库，方便链接)
add_library(infrastructure STATIC
    logging/LoggerService.h logging/LoggerService.cpp
    logging/LogApi.h logging/LogApi.cpp
)

# 设置头文件搜索路径
target_include_directories(infrastructure PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src/domain/model
)

# 链接依赖 (Core 只依赖 Qt基础库)
target_link_libraries(infrastructure PUBLIC
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
)
