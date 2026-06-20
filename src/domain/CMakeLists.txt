# 定义库目标 (STATIC 静态库，方便链接)
add_library(domain STATIC

)

# 设置头文件搜索路径
target_include_directories(domain PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# 链接依赖
target_link_libraries(domain PUBLIC
    Qt6::Core
    Qt6::Gui
    infrastructure
)
