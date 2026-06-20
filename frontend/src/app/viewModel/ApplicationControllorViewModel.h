#ifndef APPLICATIONCONTROLLORVIEWMODEL_H
#define APPLICATIONCONTROLLORVIEWMODEL_H

#include "LogViewModel.h"
#include <QObject>

class IProjectManager;
class ISolver;
class ApplicationControllorViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(LogViewModel *logViewModel READ logViewModel CONSTANT)
public:
    explicit ApplicationControllorViewModel(QObject *parent = nullptr);

    LogViewModel *logViewModel() const;

private:
    void init();

private:
    LogViewModel *m_logViewModel = nullptr;
};

#endif // APPLICATIONCONTROLLORVIEWMODEL_H
