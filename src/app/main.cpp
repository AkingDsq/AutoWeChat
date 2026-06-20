#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#include "logging/LogApi.h"
#include "viewModel/ApplicationControllorViewModel.h"

// #include <QtQml/QQmlExtensionPlugin>
// Q_IMPORT_QML_PLUGIN(ems_qmlPlugin)

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("AutoWeChat");
    app.setOrganizationName("AKingDsq");

    ApplicationControllorViewModel *appControllor = new ApplicationControllorViewModel(&app);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("App", appControllor);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ems_qml", "Main");

    if (engine.rootObjects().isEmpty())
    {
        return -1;
    }

    return app.exec();
}
