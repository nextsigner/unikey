#ifndef UL_H
#define UL_H

#include <QObject>

//-->UL
#include <QGuiApplication>
#include <QScreen>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickItem>


//Librerías Varias
#include <QTimer>
#include <QRegularExpression>
#include <QTextStream>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QBuffer>
#include <QDebug>
#include <QMimeDatabase>
#include <QPdfWriter>
#include <QPainter>
#include <QProcess>
#include <QSettings>
#include <QtWidgets/QDesktopWidget>

//Librerias Android
#ifdef Q_OS_ANDROID
#include <QtAndroidExtras/QtAndroid>
#include <QtAndroidExtras/QAndroidJniObject>
#endif

#include <quazip.h>
#include <quazipfile.h>


//Libreria QtQuick
#include <QQuickWindow>
#include <QQuickItemGrabResult>

//Librerías NetworkAccesManager
#include <QtNetwork/QNetworkInterface>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkCacheMetaData>
#include <QtNetwork/QAbstractNetworkCache>
#include <QUrl>
#include <QUrlQuery>
#include <QEventLoop>
//#include "recvthread.h" //TcpClient

//Librerías Sqlite
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlError>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlRecord>

//Librelias Multimedia
//#include <QMediaPlayer>

//Librerias Json
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>

#include <QDateTime>
#include <QStandardPaths>
#include <QThread>


#include "unikqprocess.h"
#include "row.h"
//#include "unikimageprovider.h"

//-->Librerias Chat Server
//#include "qwebchannel.h"
//#include "chatserver.h"
//#include "websocketclientwrapper.h"
//#include "websockettransport.h"
//#include <QtWebSockets/QWebSocketServer>
//<--Librerias Chat Server

//#include <QTextToSpeech>

//ENCDEC DEF
#define rA1 "9cc9"
#define rA2 "1dd1"
#define rB1 "9dd9"
#define rB2 "1cc1"
#define rC1 "6dd6"
#define rC2 "2cc2"

#define rpA1 "3cc3"
#define rpA2 "2dd2"
#define rpB1 "2aa2";
#define rpB2 "3cc3";
#define rpC1 "6006"
#define rpC2 "4cc4"

//#include "uniksqlitecrypto.h"

#ifdef UNIK_COMPILE_LINUX_RPI
#include "mmapGpio.h"
#endif

//<--UL


class UL : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int porc READ getPorc  NOTIFY porcChanged)
    Q_PROPERTY(QString uploadState READ getUploadState WRITE setUploadState NOTIFY uploadStateChanged)
    Q_PROPERTY(bool runCL READ getRunCL WRITE setRunCL NOTIFY runCLChanged)
    Q_PROPERTY(bool debugLog READ getDebugLog WRITE setDebugLog NOTIFY debugLogChanged)
    Q_PROPERTY(QString ukStd READ getUkStd() WRITE setUkStd NOTIFY ukStdChanged)
    Q_PROPERTY(QString stdErr READ getStdErr WRITE setStdErr NOTIFY stdErrChanged)
    Q_PROPERTY(QString initStdString READ getInitStdString WRITE setInitStdString)
    Q_INVOKABLE void setStdErr(QString s){
        stdErr = s;
        emit stdErrChanged();
    }
    Q_INVOKABLE QString getInitStdString(){
        return initStdString;
    }
    Q_INVOKABLE void setInitStdString(QString s){
        initStdString = s;
    }

    Q_INVOKABLE void setDebugLog(bool b){
        debugLog = b;
        emit debugLogChanged();
    }
    Q_INVOKABLE bool getDebugLog(){
        return debugLog;
    }
    Q_PROPERTY(QString uWarning READ getUWarning WRITE setUWarning NOTIFY uWarningChanged)
public:
    explicit UL(QObject *parent = nullptr);

    QByteArray lba;

    QQmlApplicationEngine *_engine;
    void setEngine(QQmlApplicationEngine *e){
        _engine = e;
        //connect(_engine, SIGNAL(quit()), this, SLOT(engineQuited()));
    }
    Q_INVOKABLE void clearComponentCache(){
        _engine->clearComponentCache();
    }
    Q_INVOKABLE void addImportPath(const QByteArray p){
        _engine->addImportPath(p);
    }
    //<--Engine

    //-->UkStd
    QString uploadState;
    QString ukStd;
    QString stdErr;
    bool runCL;

    Q_INVOKABLE QString getUWarning(){
        return uWarning;
    }
    Q_INVOKABLE void setUWarning(QString uw){
        uWarning.clear();
        uWarning.append(uw);
        emit uWarningChanged();
    }
    Q_INVOKABLE int getPorc(){
        return porc;
    }
    Q_INVOKABLE void setPorc(int p, int mode){
        porc = p;
        emit porcChanged();
        if(porc>0){
            QByteArray porcent;
            if(mode==0){
                porcent.append("downloaded ");
            }
            if(mode==1){
                porcent.append("uploaded ");
            }
            porcent.append("%");
            porcent.append(QString::number(porc).toUtf8());
            log(porcent);
            }
    }
    Q_INVOKABLE QString getUploadState(){
        return uploadState;
    }
    Q_INVOKABLE void setUploadState(QString us){
        uploadState = us;
        emit uploadStateChanged();
    }
    QString getUkStd(){
        return ukStd;
    }
    void setUkStd(const QString s){
        setUkStd(s, false);
    }

    void setUkStd(const QString s, bool htmlEscaped){
        QString u="";
        if(htmlEscaped){
            u.append(s.toHtmlEscaped());
        }else{
            u.append(s);
        }
        u.append("\n");
        ukStd=u;
        if(debugLog){
            qDebug()<<s;
        }
        emit ukStdChanged();
    }
    Q_INVOKABLE QString getStdErr(){
        return stdErr;
    }
//    Q_INVOKABLE void setStdErr(QString s){
//        stdErr = s;
//        emit stdErrChanged();
//    }
    Q_INVOKABLE bool getRunCL(){
        return runCL;
    }
    Q_INVOKABLE void setRunCL(bool b){
        runCL = b;
        emit runCLChanged();
    }
    //<--UkStd

    //-->Variables
    QString initStdString;
    bool debugLog;
    QStringList uErrors;
    QString uWarning;
    int porc;
    //<--Variables

    //Funciones de Sistema de Archivos
    Q_INVOKABLE void cd(QString folder);
    Q_INVOKABLE QString currentFolderPath();
    Q_INVOKABLE QString currentFolderName();
    Q_INVOKABLE void deleteFile(QByteArray f);
    Q_INVOKABLE bool setFile(QByteArray fileName, QByteArray fileData);
    Q_INVOKABLE bool setFile(QByteArray fileName, QByteArray fileData, QByteArray codec);
    Q_INVOKABLE QString getFile(QByteArray n);
    Q_INVOKABLE bool folderExist(const QByteArray folder);
    Q_INVOKABLE bool fileExist(QByteArray fileName);
    Q_INVOKABLE QList<QString> getFileList(QByteArray folder);
    Q_INVOKABLE bool mkdir(const QString path);
    Q_INVOKABLE QList<QString> getFolderFileList(const QByteArray folder);
    Q_INVOKABLE void log(QByteArray d);
    Q_INVOKABLE void log(QByteArray d, bool htmlEscaped);
    Q_INVOKABLE void sleep(int ms);
    Q_INVOKABLE QString getPath(int path);
    Q_INVOKABLE QString encData(QByteArray d, QString user, QString key);
    Q_INVOKABLE QString decData(QByteArray d0, QString user, QString key);
    Q_INVOKABLE QQuickWindow *mainWindow(int n);
    Q_INVOKABLE void setProperty(const QString name, const QVariant &value);
    Q_INVOKABLE QVariant getProperty(const QString name);
    Q_INVOKABLE int getEngineObjectsCount();
    Q_INVOKABLE bool isRPI();

    //Funciones Network
    QByteArray getHttpFile(QByteArray url);
    void httpReadyRead();
    bool downloadZipFile(QByteArray url, QByteArray ubicacion);
    void getZipFileSizeForDownload(QByteArray url);
    void setUZipFileSize();

    void sendFile(QString file, QString phpReceiver);
    void uploadProgress(qint64 bytesSend, qint64 bytesTotal);
    void downloadProgress(qint64 bytesSend, qint64 bytesTotal);
    void sendFinished();
    bool startWSS(QByteArray ip,  int port, QByteArray serverName);


signals:
    void log();
    void uWarningChanged();
    void porcChanged();
    void uploadStateChanged();
    void ukStdChanged();
    void stdErrChanged();
    void debugLogChanged();
    void runCLChanged();

private slots:
    QString encPrivateData(QByteArray d, QString user, QString key);
    QString decPrivateData(QByteArray d0, QString user, QString key);

    QString compData(QString d);
    QString desCompData(QString d);

    void downloadZipProgress(qint64 bytesSend, qint64 bytesTotal);

private:
    QSqlDatabase db;
    QSqlDatabase firstDB;
    QSqlDatabase secondDB;
    QStringList lsim;//=QStringList()<<"g"<<"h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z";
    QStringList lnum;//=QStringList("11,33,66,77,88,99,20,30,40,60,70,80,90,12,21,57,82,92,84,72");
    QString h;

    //UnikSqliteCrypto dbc;

   QString uZipUrl;
   QString uZipLocalLocation;
   qint64 uZipSize;
   int uZipSizeReg;
   bool doResume;
   bool httpRequestAborted;
   bool retried;
   int bytesWritten;
   QNetworkReply *reply2;
   QNetworkAccessManager *qnam;
   QFile *file;
   QByteArray dzip;

    //QQuickItem itemLogView;

    QProcess *proc;

    QNetworkReply *respuentaSendDatos;
    QImage *frame;

    //Variables de Imagen
    //UnikImageProvider *uip;

    //Variables Multimedia
    //QMediaPlayer *mPlayer;
    QBuffer *mBuffer;
    QByteArray databuf;



#ifndef Q_OS_ANDROID
#ifdef __arm__
    mmapGpio *rpiGpio;
#endif
#endif


};

#endif // UL_H
