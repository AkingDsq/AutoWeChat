// AuthServiceImpl —— 认证服务骨架（待实现 gRPC AuthService）

#ifndef AUTHSERVICEIMPL_H
#define AUTHSERVICEIMPL_H

#include <QObject>

class AuthServiceImpl : public QObject
{
    Q_OBJECT
public:
    explicit AuthServiceImpl(QObject *parent = nullptr);
};

#endif // AUTHSERVICEIMPL_H
