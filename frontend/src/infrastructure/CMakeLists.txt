# 前端 infrastructure  —— 网络层、存储层等基础设施

add_library(wechat_client_infra STATIC)

target_include_directories(wechat_client_infra PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src/domain/model
)

target_link_libraries(wechat_client_infra PUBLIC
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    wechat_shared_logging
    wechat_proto
)
