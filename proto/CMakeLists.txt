# proto/ —— Protocol Buffers 定义与代码生成
#
# 本文件负责：
# 1. find_package protobuf 和 gRPC（从 third_party/grpc1.78.1 预编译包）
# 2. 调用 protoc 生成 .pb.h/.pb.cc（消息序列化代码）
# 3. 调用 protoc + grpc_cpp_plugin 生成 .grpc.pb.h/.grpc.pb.cc（gRPC 服务桩）
# 4. 将生成代码打包为 wechat_proto 静态库，供前后端链接

find_package(protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)

set(PROTO_FILES
    common.proto
    auth.proto
    chat.proto
    contact.proto
)

# 构建所有 proto 文件的绝对路径（用于 DEPENDS，解决 import 增量编译）
set(PROTO_ABS_FILES)
foreach(PROTO_FILE ${PROTO_FILES})
    list(APPEND PROTO_ABS_FILES "${CMAKE_CURRENT_SOURCE_DIR}/${PROTO_FILE}")
endforeach()

# ============================================================
# 1. 生成 protobuf C++ 代码 (.pb.h / .pb.cc)
# ============================================================
protobuf_generate(
    LANGUAGE cpp
    PROTOS ${PROTO_FILES}
    OUT_VAR PROTO_GENERATED
)

# ============================================================
# 2. 生成 gRPC C++ 服务桩代码 (.grpc.pb.h / .grpc.pb.cc)
# ============================================================
set(GRPC_GENERATED)
foreach(PROTO_FILE ${PROTO_FILES})
    get_filename_component(_basename ${PROTO_FILE} NAME_WE)
    set(_grpc_h "${CMAKE_CURRENT_BINARY_DIR}/${_basename}.grpc.pb.h")
    set(_grpc_cc "${CMAKE_CURRENT_BINARY_DIR}/${_basename}.grpc.pb.cc")
    list(APPEND GRPC_GENERATED ${_grpc_h} ${_grpc_cc})

    add_custom_command(
        OUTPUT ${_grpc_h} ${_grpc_cc}
        COMMAND protobuf::protoc
        ARGS
            --grpc_out=${CMAKE_CURRENT_BINARY_DIR}
            --plugin=protoc-gen-grpc=$<TARGET_FILE:gRPC::grpc_cpp_plugin>
            -I${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}/${PROTO_FILE}
        DEPENDS
            ${PROTO_ABS_FILES}
            protobuf::protoc
            gRPC::grpc_cpp_plugin
        COMMENT "Generating gRPC stub: ${_basename}.grpc.pb.h / .grpc.pb.cc"
        VERBATIM
    )
endforeach()

# ============================================================
# 3. 创建 wechat_proto 静态库
# ============================================================
add_library(wechat_proto STATIC
    ${PROTO_GENERATED}
    ${GRPC_GENERATED}
)

target_include_directories(wechat_proto PUBLIC
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(wechat_proto PUBLIC
    protobuf::libprotobuf
    gRPC::grpc++
)
