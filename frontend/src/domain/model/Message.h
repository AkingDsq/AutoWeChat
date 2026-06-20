// 消息数据模型

#ifndef MESSAGE_H
#define MESSAGE_H

#include <QDateTime>
#include <QString>

struct TextMessage
{
    QString messageId;
    QString senderId;
    QString receiverId;
    QString content;
    QDateTime timestamp;
    int messageType = 0; // 0=text, 1=image, 2=file
    int status = 0;      // 0=sending, 1=sent, 2=delivered, 3=read, -1=failed
};

#endif // MESSAGE_H
