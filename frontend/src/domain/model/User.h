// 用户数据模型

#ifndef USER_H
#define USER_H

#include <QString>

struct User
{
    QString userId;
    QString username;
    QString nickname;
    QString avatarUrl;
    int status = 0; // 0=offline, 1=online, 2=away
};

#endif // USER_H
