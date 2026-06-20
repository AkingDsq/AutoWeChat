# proto/ —— Protocol Buffers 定义目录
# 当前仅存放 .proto 源文件，不参与编译
# 待 gRPC/protobuf 手动集成后，启用下方代码生成配置：
#
# find_package(protobuf CONFIG REQUIRED)
# find_package(gRPC CONFIG REQUIRED)
#
# set(PROTO_FILES
#     common.proto
#     auth.proto
#     chat.proto
#     contact.proto
# )
#
# protobuf_generate(TARGET wechat_proto LANGUAGE cpp PROTOS ${PROTO_FILES})
# add_library(wechat_proto STATIC ${PROTO_SRCS} ${PROTO_HDRS} ${GRPC_SRCS} ${GRPC_HDRS})
# target_link_libraries(wechat_proto PUBLIC protobuf::libprotobuf gRPC::grpc++)

message(STATUS "proto/ 暂不参与构建，待 gRPC/protobuf 手动集成后启用")
