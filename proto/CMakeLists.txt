# proto/ —— Protocol Buffers 定义目录

find_package(protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)

set(PROTO_FILES
    common.proto
    auth.proto
    chat.proto
    contact.proto
)

protobuf_generate(TARGET wechat_proto LANGUAGE cpp PROTOS ${PROTO_FILES})
add_library(wechat_proto STATIC ${PROTO_SRCS} ${PROTO_HDRS} ${GRPC_SRCS} ${GRPC_HDRS})
target_link_libraries(wechat_proto PUBLIC protobuf::libprotobuf gRPC::grpc++)