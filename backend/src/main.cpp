#include <QCoreApplication>
#include <QDebug>

// backend 服务端入口 —— headless 进程，后续集成 gRPC Server

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setApplicationName("WeChatServer");
    app.setOrganizationName("AKingDsq");

    qInfo() << "WeChat Server starting on port 50051...";

    // TODO: 集成 gRPC Server
    // WeChatGrpcServer server("0.0.0.0", 50051);
    // server.start();

    return app.exec();
}
