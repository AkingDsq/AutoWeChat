# 后端 service  —— 业务逻辑服务（gRPC Service 实现）

add_library(wechat_services STATIC
    AuthServiceImpl.h AuthServiceImpl.cpp
)

target_include_directories(wechat_services PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(wechat_services PUBLIC
    Qt6::Core
    wechat_server_domain
    wechat_server_infra
    wechat_proto
)
