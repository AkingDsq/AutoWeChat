#include "LogViewModel.h"
#include "logging/LoggerService.h"

LogViewModel::LogViewModel(QObject *parent)
    : QObject(parent)
{
}

QString LogViewModel::allLogs() const
{
    if (!m_logger)
    {
        return QString();
    }

    return m_logger->allLogsText();
}

void LogViewModel::clearLogs()
{
    if (!m_logger)
    {
        return;
    }

    m_logger->clear();
}

void LogViewModel::setLogger(const std::shared_ptr<LoggerService> &logger)
{
    if (m_logger == logger)
    {
        return;
    }

    if (m_logAddedConnection)
    {
        disconnect(m_logAddedConnection);
        m_logAddedConnection = QMetaObject::Connection();
    }
    if (m_logsClearedConnection)
    {
        disconnect(m_logsClearedConnection);
        m_logsClearedConnection = QMetaObject::Connection();
    }

    m_logger = logger;

    if (m_logger)
    {
        m_logAddedConnection = connect(m_logger.get(), &LoggerService::logAdded, this, [this](const LogEntry &entry)
                                       {
                                           Q_UNUSED(entry);
                                           reloadFromLogger(); });
        m_logsClearedConnection = connect(m_logger.get(), &LoggerService::logsCleared, this, [this]()
                                          { reloadFromLogger(); });
    }

    reloadFromLogger();
}

void LogViewModel::reloadFromLogger()
{
    emit allLogsChanged();
}
