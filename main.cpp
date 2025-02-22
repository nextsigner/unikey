#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "unikargsproc.h"
#include "ul.h"
#include "qmlclipboardadapter.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    UL u;
    u.setEngine(&engine);
    //Clipboard function for GNU/Linux, Windows and Macos
#ifndef Q_OS_ANDROID
    QmlClipboardAdapter clipboard;
#endif

    qmlRegisterType<UL>("unik.Unik", 1, 0, "Unik");
    //<--Register Types
    qmlRegisterType<UnikQProcess>("unik.UnikQProcess", 1, 0, "UnikQProcess");


    //-->Set Unik Version
    QString nv;
    QByteArray fvp;
#ifdef Q_OS_ANDROID
    fvp.append("assets:");
#else
    fvp.append(qApp->applicationDirPath());
#endif
    fvp.append("/version");
    nv = u.getFile(fvp);
    nv = QString(nv).replace("\n", "");
    app.setApplicationVersion(nv);
    //<--Set Unik Version

    //-->Set engine properties
    engine.rootContext()->setContextProperty("engine", &engine);
    engine.rootContext()->setContextProperty("unik", &u);
    //<--Set engine properties

    QByteArray documentsPath;
    documentsPath.append(u.getPath(3).toUtf8());
    documentsPath.append("/unik");
    engine.rootContext()->setContextProperty("documentsPath", documentsPath);
    engine.rootContext()->setContextProperty("clipboard", &clipboard);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
