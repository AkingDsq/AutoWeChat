#ifndef LOGVIEWMODEL_H
#define LOGVIEWMODEL_H

#include <QObject>
#include <QString>
#include <memory>

class LoggerService;
class LogViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString allLogs READ allLogs NOTIFY allLogsChanged)
public:
    explicit LogViewModel(QObject *parent = nullptr);

    QString allLogs() const;
    void setLogger(const std::shared_ptr<LoggerService> &logger);

    Q_INVOKABLE void clearLogs();

signals:
    void allLogsChanged();

private:
    void reloadFromLogger();

private:
    std::shared_ptr<LoggerService> m_logger;
    QMetaObject::Connection m_logAddedConnection;
    QMetaObject::Connection m_logsClearedConnection;
};

#endif // LOGVIEWMODEL_H
