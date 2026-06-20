#include "ApplicationControllorViewModel.h"

ApplicationControllorViewModel::ApplicationControllorViewModel(QObject *parent)
    : QObject{parent}
{
    init();
}

void ApplicationControllorViewModel::init()
{
    m_logViewModel = new LogViewModel(this);
    // 初始化为无活动工程的状态。
    m_logViewModel->setLogger(nullptr);
}

LogViewModel *ApplicationControllorViewModel::logViewModel() const
{
    return m_logViewModel;
}
