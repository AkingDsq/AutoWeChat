find_package(Qt6 REQUIRED COMPONENTS Quick)

set(qmlFiles
    Main.qml

)

qt_add_library(ems_qml STATIC)
qt_add_qml_module(ems_qml
    URI "ems_qml"
    VERSION 1.0
    QML_FILES
        ${qmlFiles}
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/ems_qml"
)
target_link_libraries(ems_qml PRIVATE
    Qt6::Quick
    Qt6::Qml
)
