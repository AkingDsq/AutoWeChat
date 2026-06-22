project(WeChatClient)

# 定义可执行文件
qt_add_executable(${PROJECT_NAME}
    WIN32
    main.cpp
    viewModel/ApplicationControllorViewModel.h viewModel/ApplicationControllorViewModel.cpp
    viewModel/LogViewModel.h viewModel/LogViewModel.cpp
)

target_sources(${PROJECT_NAME} PRIVATE
    ../../resources/resources.qrc
)

# 设置头文件搜索路径
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Quick
    Qt6::Qml
    wechat_qmlplugin
    wechat_domain
    wechat_client_infra
)

# 安装可执行文件到 bin
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# 安装后运行 windeployqt
install(CODE "
    set(INSTALLED_EXE \"\$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/${PROJECT_NAME}.exe\")
    message(STATUS \"运行 windeployqt: ${WINDEPLOYQT}\")
    execute_process(COMMAND ${WINDEPLOYQT} \"\${INSTALLED_EXE}\"
                    WORKING_DIRECTORY \"${CMAKE_INSTALL_PREFIX}/bin\"
                    RESULT_VARIABLE DEPLOY_RESULT)
    if(NOT DEPLOY_RESULT EQUAL 0)
        message(WARNING \"windeployqt 执行失败\")
    endif()
")

# 构建后运行 windeployqt，将 Qt DLL 复制到可执行文件所在目录
add_custom_command(TARGET WeChatClient POST_BUILD
    COMMAND ${WINDEPLOYQT} "$<TARGET_FILE:WeChatClient>" --qmldir "${CMAKE_SOURCE_DIR}"
    COMMENT "Running windeployqt to copy Qt6 DLLs to build directory"
)
