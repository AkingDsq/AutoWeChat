project(WeChatServer)

# headless 后端服务 —— QCoreApplication，无 GUI 依赖
add_executable(${PROJECT_NAME}
    main.cpp
)

add_subdirectory(infrastructure)
add_subdirectory(domain)
add_subdirectory(service)

# 设置头文件搜索路径
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    wechat_services
    wechat_server_domain
    wechat_server_infra
)

# 安装可执行文件到 bin
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
