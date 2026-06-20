# 共享库 —— frontend 和 backend 公用的代码
# 线程安全的日志库

add_library(wechat_shared_logging STATIC
    logging/LogApi.h logging/LogApi.cpp
    logging/LoggerService.h logging/LoggerService.cpp
)

target_include_directories(wechat_shared_logging PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(wechat_shared_logging PUBLIC
    Qt6::Core
)
