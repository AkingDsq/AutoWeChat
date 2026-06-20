# 后端 domain  —— 服务端数据模型

add_library(wechat_server_domain STATIC
    model/User.h
)

target_include_directories(wechat_server_domain PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(wechat_server_domain PUBLIC
    Qt6::Core
    wechat_server_infra
)
