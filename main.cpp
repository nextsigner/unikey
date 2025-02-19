#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "unikargsproc.h"
#include "ul.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    UL u;

    //qmlRegisterType<UL>("unik.Unik", 1, 0, "Unik");
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

    //-->Load UAP
    UnikArgsProc uap;
    for (int i = 0; i < argc; ++i) {
        QByteArray a;
        a.append(argv[i]);
        uap.args.append(a);
        //>-version
        if(a=="-version"){
            qInfo()<<"Unik version: "<<nv;
            return 0;
        }
        //<-version
    }
    //-->LOAD UAP

    //---PROC UAP
    for (int i = 0; i < uap.args.length(); ++i) {
        QString arg;
        arg.append(uap.args.at(i));

        //-->Folder
        if(arg.contains("-folder=")){
            QStringList marg = arg.split("-folder=");
            if(marg.size()==2){
                u.cd(marg.at(1).toUtf8());
                //marg.at(1).toUtf8()
            }
        }
        //<--Folder
    }
    //-->PROC UAP


    //-->Set engine properties
    engine.rootContext()->setContextProperty("engine", &engine);
    engine.rootContext()->setContextProperty("unik", &u);

    engine.rootContext()->setContextProperty("unikLog", u.ukStd);
    //engine.rootContext()->setContextProperty("unikError", listaErrores);
    engine.rootContext()->setContextProperty("uap", &uap);
    //<--Set engine properties

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
