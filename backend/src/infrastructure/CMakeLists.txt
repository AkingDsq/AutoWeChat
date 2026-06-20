# 后端 infrastructure  —— 数据库、线程池等基础设施

add_library(wechat_server_infra STATIC)

target_include_directories(wechat_server_infra PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(wechat_server_infra PUBLIC
    Qt6::Core
    Qt6::Sql
    wechat_shared_logging
)
