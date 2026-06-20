# 前端 domain  —— 数据模型

add_library(wechat_domain STATIC
    model/User.h
    model/Message.h
)

target_include_directories(wechat_domain PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(wechat_domain PUBLIC
    Qt6::Core
    Qt6::Gui
    wechat_client_infra
)
