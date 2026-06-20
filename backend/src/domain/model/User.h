// 服务端用户模型

#ifndef USER_H
#define USER_H

#include <QString>

struct User
{
    QString userId;
    QString username;
    QString nickname;
    QString avatarUrl;
    int status = 0;
};

#endif // USER_H
