find_package(Qt6 REQUIRED COMPONENTS Quick)

set(qmlFiles
    Main.qml
)

qt_add_library(wechat_qml STATIC)
qt_add_qml_module(wechat_qml
    URI "WeChatClient"
    VERSION 1.0
    QML_FILES
        ${qmlFiles}
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/wechat_qml"
)
target_link_libraries(wechat_qml PRIVATE
    Qt6::Quick
    Qt6::Qml
)
