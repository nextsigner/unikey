#include "ul.h"

UL::UL(QObject *parent) : QObject(parent)
{

}

void UL::cd(QString folder)
{
    QDir::setCurrent(folder);
    _engine->addImportPath(QDir::currentPath());
    _engine->addPluginPath(QDir::currentPath());
    qInfo()<<"Set current dir: "<<QDir::currentPath();
}

QString UL::currentFolderPath()
{
    QDir f(QDir::currentPath());
    return f.currentPath();
}

QString UL::currentFolderName()
{
    QDir f(QDir::currentPath());
    return f.dirName();
}
void UL::deleteFile(QByteArray f)
{
    QFile arch(f);
    arch.remove();
}

bool UL::setFile(QByteArray fileName, QByteArray fileData)
{
    return setFile(fileName, fileData, "UTF-8");
}

bool UL::setFile(QByteArray fileName, QByteArray fileData, QByteArray codec)
{
    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly)) {
        lba="";
        lba.append("Cannot open file for writing: ");
        lba.append(file.errorString().toUtf8());
        //u.log(lba);
        return false;
    }
    QTextStream out(&file);
    out.setCodec(codec);
    out << fileData;
    file.close();
    return true;
}

QString UL::getFile(QByteArray n)
{
    QString r;
    QFile file(n);
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text)){
        return "error";
    }
    return file.readAll();
}

bool UL::folderExist(const QByteArray folder)
{
    return  QDir(folder.constData()).exists();
}

QList<QString> UL::getFileList(QByteArray folder)
{
    QList<QString> list;

    //QDir directory("/media/ns/WD/vnRicardo");
    QDir directory(folder);
    QStringList images = directory.entryList(QStringList() << "*.mp4" << "*.mkv",QDir::Files);
    foreach(QString filename, images) {
    //do whatever you need to do
        list.append(filename);
    }
    return list;
}

bool UL::mkdir(const QString path)
{
    QDir dir0(path);
    if (!dir0.exists()) {
        dir0.mkpath(".");
    }
    return dir0.exists();
}

QList<QString> UL::getFolderFileList(const QByteArray folder)
{
    QList<QString> ret;
    QDir d(folder);
    for (int i=0;i<d.entryList().length();i++) {
        ret.append(d.entryList().at(i));
    }
    return  ret;
}

void UL::log(QByteArray d)
{
    QString d2;
    d2.append(d);
    if(!_engine->rootContext()->property("setInitString").toBool()){
        initStdString.append(d2);
        initStdString.append("\n");
    }
    setUkStd(d2);
}

void UL::sleep(int ms)
{
    QThread::sleep(ms);
}

QString UL::getPath(int path)
{
    QString r=".";
    if(path==0){//App location Name
        r = QFileInfo(QCoreApplication::applicationFilePath()).fileName();
    }
#ifdef Q_OS_WIN
    if(path==1){//App location
        r = qApp->applicationDirPath();
    }
#endif
#ifdef Q_OS_OSX
    if(path==1){//App location
        r = qApp->applicationDirPath();
    }
#endif
#ifdef Q_OS_LINUX
    if(path==1){//App location
        r = QDir::currentPath();
    }
#endif
    if(path==2){//Temp location
        r = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
        //qInfo()<<"getPath(2): "<<r;
    }
    if(path==3){//Doc location
#ifndef Q_OS_ANDROID
        r = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
#else
        //r="/sdcard/Documents";
        QStringList systemEnvironment = QProcess::systemEnvironment();
        bool sdcard=false;
        for (int i = 0; i < systemEnvironment.size(); ++i) {
            QString cad;
            cad.append(systemEnvironment.at(i));
            if(cad.contains("EXTERNAL_STORAGE=/sdcard")){
                sdcard=true;
            }
        }
        qInfo()<<"uap systemEnvironment: "<<systemEnvironment;
        qInfo()<<"uap sdcard: "<<sdcard;
        if(sdcard){
            r="/sdcard/Documents";
        }else{
            r="/storage/emulated/0/Documents";
        }
        QDir doc(r);
        if(!doc.exists()){
            qInfo()<<"[1] /sdcard/Documents no exists";
            doc.mkdir(".");
            /*if(!doc.exists()){
                r="/storage/emulated/0/Documents";
                doc.setCurrent(r);
                doc.mkdir(".");
                qInfo()<<"[2] /storage/emulated/0/Documents no exists";
            }else{
                qInfo()<<"[2] /storage/emulated/0/Documents exists";
            }*/
        }else{
            qInfo()<<"[1] /sdcard/Documents exists";
        }
#endif

    }
    if(path==4){//AppData location
        r = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    }
    if(path==5){//Current Dir
        r = QDir::currentPath();
    }
    if(path==6){//Current Desktop
        r = QStandardPaths::standardLocations(QStandardPaths::DesktopLocation).at(0);
    }
    if(path==7){//Current Home
        r = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0);
    }
    QDir dir(r);
    if (!dir.exists()) {
        if(debugLog){
            lba="";
            lba.append("Making folder ");
            lba.append(r.toUtf8());
            log(lba);
        }
        dir.mkpath(".");
    }else{
        if(debugLog){
            lba="";
            lba.append("Folder ");
            lba.append(r.toUtf8());
            lba.append(" exist.");
        }
    }
    return r;
}

QString UL::encData(QByteArray d, QString user, QString key)
{
    QString ret;
    QByteArray upkData;
    QByteArray r="6226";
    QByteArray r2="6226";
    QByteArray ru;
    QString cdt = QDateTime::currentDateTime().toString("z");
    if(QString(cdt.at(0))=="1"||QString(cdt.at(0))=="2"||QString(cdt.at(0))=="3"){
        //funciona
        //r="9cc9";
        r=rA1;
        //r2="1dd1";
        r2=rA2;
    }else if(QString(cdt.at(0))=="1"||QString(cdt.at(0))=="2"||QString(cdt.at(0))=="3"){
        //funciona
        //        r="9dd9";
        //        r2="1cc1";
        r=rB1;
        r2=rB2;
    }else{
        //funciona
        //        r="6dd6";
        //        r2="2cc2";
        r=rC1;
        r2=rC2;
    }
    QByteArray segUser;
    segUser.append(user.toUtf8());
    for (int i = 0; i < 40-user.size()-1; ++i) {
        segUser.append("|");
    }
    segUser.append("-");
    QByteArray segKey;
    segKey.append(key.toUtf8());
    for (int i = 0; i < 20-key.size(); ++i) {
        segKey.append("|");
    }
    QByteArray suH=segUser.toHex();
    QByteArray suHC;
    for (int i = 0; i < suH.size(); ++i) {
        QString uc0;
        uc0.append(suH.at(i));
        if(uc0.contains(r.at(0))){
            suHC.append(r.at(1));
        }else if(uc0.contains(r.at(2))){
            suHC.append(r.at(3));
        }else if(uc0.contains(r2.at(0))){
            suHC.append(r2.at(1));
        }else if(uc0.contains(r2.at(2))){
            suHC.append(r2.at(3));
        }else{
            suHC.append(uc0.toUtf8());
        }
    }

    QByteArray skH=segKey.toHex();
    QByteArray skHC;
    for (int i = 0; i < skH.size(); ++i) {
        QString uc0;
        uc0.append(skH.at(i));
        if(uc0.contains(r.at(0))){
            skHC.append(r.at(1));
        }else if(uc0.contains(r.at(2))){
            skHC.append(r.at(3));
        }else if(uc0.contains(r2.at(0))){
            skHC.append(r2.at(1));
        }else if(uc0.contains(r2.at(2))){
            skHC.append(r2.at(3));
        }else{
            skHC.append(uc0.toUtf8());
        }
    }
    ru.append(suHC);
    ru.append(skHC);
    QString nru;
    nru.append(ru);
    QString cru1 = nru;//.replace("7c7c7c7c7c7c7c7c7c7c", "783d33333b793d31307c");
    QString cru2;
    if(cru1.contains("7c7c7c7c7c7c7c7c7c7c")){
        cru2 = cru1.replace("7c7c7c7c7c7c7c7c7c7c", "783d33333b793d31307c");
    }else if(cru1.contains("7c7c7c7c7c")){
        cru2 = cru1.replace("7c7c7c7c7c", "7a3d313b7c");
    }else{
        cru2=cru1;
    }

    QByteArray ru2;
    ru2.append(cru2.toUtf8());
    QString ret0="";
    ret0.append(r);
    ret0.append(r2);
    ret0.append(ru2);
    QString c;
    c.append(d);
    QByteArray codeUtf8;
    codeUtf8.append(c.toUtf8());
    QString code;
    code.append(codeUtf8.toHex());
    QByteArray encode;
    for (int i = 0; i < code.size(); ++i) {
        QString uc0 = code.at(i);
        if(uc0.contains(r.at(0))){
            encode.append(r.at(1));
        }else if(uc0.contains(r.at(2))){
            encode.append(r.at(3));
        }else if(uc0.contains(r2.at(0))){
            encode.append(r2.at(1));
        }else if(uc0.contains(r2.at(2))){
            encode.append(r2.at(3));
        }else{
            encode.append(uc0.toUtf8());
        }
    }
    ret0.append("||||||");
    ret0.append("I");
    ret0.append(encode);
    ret0.append("O");
    ret0.append(ru);
    return compData(ret0);
}

QString UL::decData(QByteArray d0, QString user, QString key)
{
    QString ret;
    QString pd=QString(d0);
    QByteArray d;
    d.append(desCompData(pd).toUtf8());

    QByteArray arch;
    QByteArray nom;
    int tipo=0;
    QByteArray r;
    QByteArray r2;
    QString passData;
    QByteArray passDataBA;
    bool passDataWrite=false;

    for(int i = 0; i < d.size(); ++i) {
        QString l;
        l.append(d.at(i));
        QByteArray enc;
        if(l.contains(r.at(0))){
            enc.append(r.at(1));
        }else if(l.contains(r.at(2))){
            enc.append(r.at(3));
        }else if(l.contains(r2.at(0))){
            enc.append(r2.at(1));
        }else if(l.contains(r2.at(2))){
            enc.append(r2.at(3));
        }else{
            enc.append(l.toUtf8());
        }
        if(l.contains("O"))
        {
            tipo=0;
        }else if(l.contains("I")){
            tipo=1;
            if(!passDataWrite){
                QByteArray decSegUK;
                for (int i2 = 0; i2 < passDataBA.size(); ++i2) {
                    QString l2;
                    l2.append(passDataBA.at(i2));
                    if(l2.contains(r.at(0))){
                        decSegUK.append(r.at(1));
                    }else if(l2.contains(r.at(2))){
                        decSegUK.append(r.at(3));
                    }else if(l2.contains(r2.at(0))){
                        decSegUK.append(r2.at(1));
                    }else if(l2.contains(r2.at(2))){
                        decSegUK.append(r2.at(3));
                    }else{
                        decSegUK.append(l2.toUtf8());
                    }
                }
                passData.append(QByteArray::fromHex(decSegUK));
                QString pd2 = passData.replace("x=33;r=60|","|");
                QString pd3 = pd2.replace("z=6;|","|");
                QStringList m0 = pd3.split("|-");
                if(m0.size()>1){
                    QString cu = m0.at(0);
                    QString ck = m0.at(1);
                    QString nuser = cu.replace("|", "");
                    QString nkey = ck.replace("|", "");
                    if(user!=nuser||key!=nkey){
                        return "";
                    }
                }else{
                    if(debugLog){
                        lba="";
                        lba.append("Error extract! pass data not found");
                        log(lba);
                    }
                    return "";
                }
            }
            passDataWrite=true;
        }else  if(i<4){
            r.append(l.toUtf8());
        }else  if(i>=4&&i<8){
            r2.append(l.toUtf8());
        }else  if(i>=8&&i<=67+60){
            passDataBA.append(l.toUtf8());
        }else{
            if(tipo==0){
                //nom.append(enc);
            }else{
                arch.append(enc);
            }
        }
    }
    QString nRet;
    nRet.append(QByteArray::fromHex(arch));
    return nRet;
}

QQuickWindow *UL::mainWindow(int n)
{
    if(!_engine->rootObjects().isEmpty()&&_engine->rootObjects().size()>=n){
        QObject *aw0 = _engine->rootObjects().at(n);
        QQuickWindow *window = qobject_cast<QQuickWindow*>(aw0);
        return window;
    }else{
        QObject *aw0 = _engine->rootObjects().at(0);
        QQuickWindow *window2 = qobject_cast<QQuickWindow*>(aw0);
        return window2;
    }
}

void UL::setProperty(const QString name, const QVariant &value)
{
    _engine->rootContext()->setProperty(name.toUtf8().constData(), value);
}

QVariant UL::getProperty(const QString name)
{
    return _engine->rootContext()->property(name.toUtf8());
}

int UL::getEngineObjectsCount()
{
    return _engine->rootObjects().count();
}

bool UL::isRPI()
{
#ifdef __arm__
#ifndef Q_OS_ANDROID
    return true;
#else
    return false;
#endif
#else
    return false;
#endif
}

QByteArray UL::getHttpFile(QByteArray url)
{
    QEventLoop eventLoop;
    QNetworkAccessManager mgr;
    QObject::connect(&mgr, SIGNAL(finished(QNetworkReply*)), &eventLoop, SLOT(quit()));
    QNetworkRequest req(QUrl(url.constData()));

    QNetworkReply *reply = mgr.get(req);
    connect(reply,SIGNAL(downloadProgress(qint64,qint64)), this, SLOT(downloadProgress(qint64,qint64)));
    eventLoop.exec();
    QByteArray err;
    if (reply->error() == QNetworkReply::NoError) {

        return reply->readAll();
        delete reply;
    }else if (reply->error() == QNetworkReply::ContentNotFoundError) {
        err.append("Error:404");
        return err;
        delete reply;
    }else{
        if(debugLog){
            lba="";
            lba.append("Failure ");
            lba.append(reply->errorString().toUtf8());
            log(lba);
        }
        err.append(reply->errorString().toUtf8());
        return err;
        delete reply;
    }
    return "";
}

void UL::httpReadyRead()
{
    //...
}

QString UL::encPrivateData(QByteArray d, QString user, QString key)
{
    QString ret;
    QByteArray upkData;
    QByteArray r="6226";
    QByteArray r2="6226";
    QByteArray ru;
    QString cdt = QDateTime::currentDateTime().toString("z");
    if(QString(cdt.at(0))=="1"||QString(cdt.at(0))=="2"||QString(cdt.at(0))=="3"){
        r=rpA1;
        r2=rpA2;
    }else if(QString(cdt.at(0))=="1"||QString(cdt.at(0))=="2"||QString(cdt.at(0))=="3"){
        r=rpB1;
        r2=rpB2;
    }else{
        r=rpC1;
        r2=rpC2;
    }
    QByteArray segUser;
    segUser.append(user);
    for (int i = 0; i < 40-user.size()-1; ++i) {
        segUser.append("|");
    }
    segUser.append("-");
    QByteArray segKey;
    segKey.append(key);
    for (int i = 0; i < 20-key.size(); ++i) {
        segKey.append("|");
    }
    QByteArray suH=segUser.toHex();
    QByteArray suHC;
    for (int i = 0; i < suH.size(); ++i) {
        QString uc0;
        uc0.append(suH.at(i));
        if(uc0.contains(r.at(0))){
            suHC.append(r.at(1));
        }else if(uc0.contains(r.at(2))){
            suHC.append(r.at(3));
        }else if(uc0.contains(r2.at(0))){
            suHC.append(r2.at(1));
        }else if(uc0.contains(r2.at(2))){
            suHC.append(r2.at(3));
        }else{
            suHC.append(uc0);
        }
    }

    QByteArray skH=segKey.toHex();
    QByteArray skHC;
    for (int i = 0; i < skH.size(); ++i) {
        QString uc0;
        uc0.append(skH.at(i));
        if(uc0.contains(r.at(0))){
            skHC.append(r.at(1));
        }else if(uc0.contains(r.at(2))){
            skHC.append(r.at(3));
        }else if(uc0.contains(r2.at(0))){
            skHC.append(r2.at(1));
        }else if(uc0.contains(r2.at(2))){
            skHC.append(r2.at(3));
        }else{
            skHC.append(uc0);
        }
    }
    ru.append(suHC);
    ru.append(skHC);
    QString nru;
    nru.append(ru);
    QString cru1 = nru;//.replace("7c7c7c7c7c7c7c7c7c7c", "783d33333b793d31307c");
    QString cru2;
    if(cru1.contains("7c7c7c7c7c7c7c7c7c7c")){
        cru2 = cru1.replace("7c7c7c7c7c7c7c7c7c7c", "783d33333b793d31307c");
    }else if(cru1.contains("7c7c7c7c7c")){
        cru2 = cru1.replace("7c7c7c7c7c", "7a3d313b7c");
    }else{
        cru2=cru1;
    }

    QByteArray ru2;
    ru2.append(cru2);

    QString ret0="";
    ret0.append(r);
    ret0.append(r2);
    ret0.append(ru2);
    QString c;
    c.append(d);
    QByteArray codeUtf8;
    codeUtf8.append(c.toUtf8());
    QString code;
    code.append(codeUtf8.toHex());
    QByteArray encode;
    for (int i = 0; i < code.size(); ++i) {
        QString uc0 = code.at(i);
        if(uc0.contains(r.at(0))){
            encode.append(r.at(1));
        }else if(uc0.contains(r.at(2))){
            encode.append(r.at(3));
        }else if(uc0.contains(r2.at(0))){
            encode.append(r2.at(1));
        }else if(uc0.contains(r2.at(2))){
            encode.append(r2.at(3));
        }else{
            encode.append(uc0);
        }
    }

    ret0.append("||||||");
    ret0.append("I");
    ret0.append(encode);
    ret0.append("O");
    ret0.append(ru);

    return compData(ret0);
}

QString UL::decPrivateData(QByteArray d0, QString user, QString key)
{
    QString ret;

    QString pd=QString(d0);
    QByteArray d;
    d.append(desCompData(pd));

    QByteArray arch;
    QByteArray nom;
    int tipo=0;
    QByteArray r;
    QByteArray r2;
    QString passData;
    QByteArray passDataBA;
    bool passDataWrite=false;

    for (int i = 0; i < d.size(); ++i) {
        QString l;
        l.append(d.at(i));
        QByteArray enc;
        if(l.contains(r.at(0))){
            enc.append(r.at(1));
        }else if(l.contains(r.at(2))){
            enc.append(r.at(3));
        }else if(l.contains(r2.at(0))){
            enc.append(r2.at(1));
        }else if(l.contains(r2.at(2))){
            enc.append(r2.at(3));
        }else{
            enc.append(l);
        }
        if(l.contains("O"))
        {
            tipo=0;
        }else if(l.contains("I")){
            tipo=1;
            if(!passDataWrite){
                QByteArray decSegUK;
                for (int i2 = 0; i2 < passDataBA.size(); ++i2) {
                    QString l2;
                    l2.append(passDataBA.at(i2));
                    if(l2.contains(r.at(0))){
                        decSegUK.append(r.at(1));
                    }else if(l2.contains(r.at(2))){
                        decSegUK.append(r.at(3));
                    }else if(l2.contains(r2.at(0))){
                        decSegUK.append(r2.at(1));
                    }else if(l2.contains(r2.at(2))){
                        decSegUK.append(r2.at(3));
                    }else{
                        decSegUK.append(l2);
                    }
                }
                passData.append(QByteArray::fromHex(decSegUK));
                QString pd2 = passData.replace("x=33;r=60|","|");
                QString pd3 = pd2.replace("z=6;|","|");
                QStringList m0 = pd3.split("|-");
                if(m0.size()>1){
                    QString cu = m0.at(0);
                    QString ck = m0.at(1);
                    QString nuser = cu.replace("|", "");
                    QString nkey = ck.replace("|", "");
                    if(user!=nuser||key!=nkey){
                        return "";
                    }
                }else{
                    if(debugLog){
                        lba="";
                        lba.append("Error extract! pass data not found.");
                        log(lba);
                    }
                    return "";
                }
            }
            passDataWrite=true;
        }else  if(i<4){
            if(l=="0"){
                r.append("d");
            }else if(l=="2"){
                r.append("9");
            }else if(l=="3"){
                r.append("9");
            }else{
                r.append(l);
            }
        }else  if(i>=4&&i<8){
            if(l=="4"){
                r2.append("c");
            }else if(l=="3"){
                r2.append("1");
            }else if(l=="2"){
                r2.append("1");
            }else{
                r2.append(l);
            }
        }else  if(i>=8&&i<=67+60){
            passDataBA.append(l);
        }else{
            if(tipo==0){
                //nom.append(enc);
            }else{
                arch.append(enc);
            }
        }
    }
    QString nRet;
    nRet.append(QByteArray::fromHex(arch));
    return nRet;
}

QString UL::compData(QString d)
{
    QString nd=d;
    for (int i = 0; i < lsim.size(); ++i) {
        QByteArray rs;
        rs.append(lsim.at(i));
        QByteArray rn;
        rn.append(lnum.at(i));
        QString ad = nd;
        nd=ad.replace(rn, rs);
    }
    return nd;
}

QString UL::desCompData(QString d)
{
    QString nd=d;
    for (int i = 0; i < lsim.size(); ++i) {
        QByteArray rs;
        rs.append(lsim.at(i));
        QByteArray rn;
        rn.append(lnum.at(i));
        QString ad = nd;
        nd=ad.replace(rs, rn);
    }
    return nd;
}

void UL::downloadZipProgress(qint64 bytesSend, qint64 bytesTotal)
{
    double porc;
    if(bytesTotal!=-1){
        if(uZipSize>=bytesTotal){
            porc = (((double)bytesSend)/(double)uZipSize)*100;
        }else {
            porc = (((double)bytesSend)/bytesTotal)*100;
        }
    }else if(uZipSize>0){
        porc = (((double)bytesSend)/(double)uZipSize)*100;
    }else{
        if(uZipSize>bytesTotal){
            porc = (((double)bytesSend)/(double)uZipSize)*100;
        }else {
            porc = (((double)bytesSend)/(double)bytesTotal)*100;
        }
    }
    //porc = (((double)bytesSend)/bytesTotal)*100;
    //qInfo()<<"------>"<<bytesTotal;
    QString d1;
    d1.append(QString::number(porc));
    QStringList sd1=d1.split(".");
    QByteArray nl;
    nl.append("download git ");
    nl.append(uZipUrl.toUtf8());
    nl.append(" %");
    nl.append(sd1.at(0).toUtf8());
    //nl.append(" Size: ");
    //nl.append(QString::number(uZipSize));
    log(nl);
}

bool UL::downloadZipFile(QByteArray url, QByteArray ubicacion)
{
    log("downloading zip file from: "+url);
    uZipUrl=QString(url);
    uZipLocalLocation="";
    uZipLocalLocation.append(ubicacion);
    uZipSize=-1;
    getZipFileSizeForDownload(url);
    int v=0;
    while (uZipSize<=0) {
        //qInfo()<<"uZipSize V: "<<v;
        if(v>1000){
            break;
        }
        v++;
    }

#ifndef Q_OS_OSX
#ifndef Q_OS_ANDROID
#ifndef Q_OS_WIN
#ifndef Q_OS_LINUX
    QEventLoop eventLoop0;
    QNetworkAccessManager mgr0;
    QObject::connect(&mgr0, SIGNAL(finished(QNetworkReply*)), &eventLoop0, SLOT(quit()));
    QNetworkRequest req0(QUrl(url.constData()));
    QNetworkReply *reply0 = mgr0.get(req0);
    uZipSizeReg=0;
    connect(
                reply0, &QNetworkReply::metaDataChanged,
                [=]( ) {
        uZipSize=reply0->header(QNetworkRequest::ContentLengthHeader).toInt();
        reply0->deleteLater();
        if(uZipSize<=0){
            return downloadZipFile(url, ubicacion);
        }else {
            if(uZipSize>uZipSizeReg){
                uZipSizeReg=uZipSize;
            }else {
                reply0->close();
            }
        }
    }
    );
#endif
#endif
#endif
#endif


    QEventLoop eventLoop;
    QNetworkAccessManager mgr;
    QObject::connect(&mgr, SIGNAL(finished(QNetworkReply*)), &eventLoop, SLOT(quit()));
    QNetworkRequest req(QUrl(url.constData()));
    QNetworkReply *reply = mgr.get(req);
    connect(reply,SIGNAL(downloadProgress(qint64,qint64)), this, SLOT(downloadZipProgress(qint64,qint64)));
    //QNetworkReply *reply = mgr.get(req);
    // QThread::sleep(3000);
    eventLoop.exec();
    if (reply->error() == QNetworkReply::NoError) {
        QFile other(ubicacion);
        other.open(QIODevice::WriteOnly);
        other.write(reply->readAll());
        other.flush();
        other.close();
        return true;
    }else{
        if(debugLog){
            QByteArray log100;
            log100.append("Failure ");
            log100.append(reply->errorString().toUtf8());
            log(log100);
        }
        reply->deleteLater();
        return false;
        delete reply;
    }
    return false;
}

void UL::getZipFileSizeForDownload(QByteArray url)
{
    //uZipSize=-1;
    QNetworkRequest req;
    //QNetworkAccessManager mgr3;
    qnam = new QNetworkAccessManager(this);
    req.setUrl(QUrl(url.constData()));
    reply2 = qnam->head(req);
    connect(reply2,SIGNAL(finished()),this,SLOT(setUZipFileSize()));
}

void UL::setUZipFileSize()
{
    uZipSize = reply2->header(QNetworkRequest::ContentLengthHeader).toUInt();
    reply2->deleteLater();
    qnam->deleteLater();
    //qInfo()<<"Downloading "<<uZipSize;
    if(uZipSize==0){
        getZipFileSizeForDownload(uZipUrl.toUtf8());
    }
}

void UL::sendFile(QString file, QString phpReceiver)
{
    if(debugLog){
        lba="";
        lba.append("Starting sending data...");
        log(lba);
    }
    QNetworkAccessManager *am = new QNetworkAccessManager(this);
    QByteArray origen;
    origen.append(file.toUtf8());
    QStringList l = file.split("/");
    QByteArray destino;
    destino.append(l.at(l.size()-1).toUtf8());
    QStringList l2 = phpReceiver.split("/");
    if(l2.size()<2){
        return;
    }
    QString path(origen);
    QMimeDatabase dbMt;
    QMimeType type = dbMt.mimeTypeForFile(path);
    if(debugLog){
        lba="";
        lba.append("Mime type: ");
        lba.append(type.name().toUtf8());
        log(lba);
    }
    QByteArray urlReceiver;
    urlReceiver.append(phpReceiver.toUtf8());
    QNetworkRequest request(QUrl(urlReceiver.constData()));
    QString bound="margin";
    QByteArray data;
    data.append("--");
    data.append(bound.toUtf8());
    data.append("\r\n");
    data.append("Content-Disposition: form-data; name=\"action\"\r\n\r\n");
    data.append(l2.at(l2.size()-1).toUtf8());
    data.append("\r\n");
    data.append("--" + bound.toUtf8() + "\r\n");
    data.append("Content-Disposition: form-data; name=\"uploaded\"; filename=\""+destino+"\"\r\n");
    data.append("Content-Type: ");
    data.append(type.name());
    data.append("\r\n\r\n");
    if(debugLog){
        lba="";
        lba.append("Origen: ");
        lba.append(origen);
        lba.append(" Destino: ");
        lba.append(destino);
        lba.append(" Ruta: ");
        lba.append(path);
        log(lba);
    }
    QFile localFile(path);
    if (!localFile.open(QIODevice::ReadOnly)){
        if(debugLog){
            lba="";
            lba.append("Error while opening file.");
            log(lba);
        }
        return;
    }else{
        if(debugLog){
            lba="";
            lba.append("Opening file...");
            log(lba);
        }
    }
    data.append(localFile.readAll());
    data.append("\r\n");
    data.append("--" + bound + "--\r\n");
    request.setRawHeader(QString("Accept-Charset").toUtf8(), QString("ISO-8859-1,utf-8;q=0.7,*;q=0.7").toUtf8());
    request.setRawHeader(QString("Content-Type").toUtf8(),QString("multipart/form-data; boundary="+bound).toUtf8());
    request.setRawHeader(QString("Content-Length").toUtf8(), QString::number(data.length()).toUtf8());
    respuentaSendDatos  = am->post(request,data);
    //qDebug() << data.data();
    connect(respuentaSendDatos, SIGNAL(finished()), this, SLOT(sendFinished()));
    connect(respuentaSendDatos,SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(uploadProgress(qint64,qint64)));
}

void UL::uploadProgress(qint64 bytesSend, qint64 bytesTotal)
{
    //double porc = (((double)bytesSend)/bytesTotal)*100;
    // int porc= (int)((bytesSend * 100) / bytesTotal);
    /*#ifdef Q_OS_LINUX

#ifdef Q_OS_ANDROID
    double porc = (((double)bytesSend)/bytesTotal)*100;
#else
    int porc= (int)((bytesSend * 100) / bytesTotal);
#endif

#endif
#ifdef Q_OS_WIN
    double porc = (((double)bytesSend)/bytesTotal)*100;
#endif
#ifdef Q_OS_OSX
    double porc = (((double)bytesSend)/bytesTotal)*100;
#endif
    QString d1;
    d1.append(QString::number(porc));
    QStringList sd1=d1.split(".");
    setPorc(QString(sd1.at(0)).toInt(), 1);*/
    double porc = (((double)bytesSend)/bytesTotal)*100;
    QString d1;
    d1.append(QString::number(porc));
    QStringList sd1=d1.split(".");
    QByteArray nl;
    nl.append("upload ");
    nl.append(uZipUrl);
    nl.append(" %");
    nl.append(sd1.at(0));
    log(nl);
}

void UL::downloadProgress(qint64 bytesSend, qint64 bytesTotal)
{
    //double porc = (((double)bytesSend)/bytesTotal)*100;
    //int porc= (int)((bytesSend * 100) / bytesTotal);
    /*qint32 bs=qint32(bytesSend);
    qint32 bt=qint32(bytesTotal);
#ifdef Q_OS_LINUX
#ifdef Q_OS_ANDROID
    double porc = (((double)bs)/bt)*100;
#else
    int porc= (int)((bytesSend * 100) / bytesTotal);
#endif
#endif
#ifdef Q_OS_WIN
    double porc = (((double)bytesSend)/bytesTotal)*100;
#endif
#ifdef Q_OS_OSX
    double porc = (((double)bytesSend)/bytesTotal)*100;
#endif
    QString d1;
    d1.append(QString::number(porc));
    QStringList sd1=d1.split(".");
    setPorc(QString(sd1.at(0)).toInt(), 0);*/
    double porc = (((double)bytesSend)/bytesTotal)*100;
    QString d1;
    d1.append(QString::number(porc));
    QStringList sd1=d1.split(".");
    QByteArray nl;
    nl.append("download ");
    nl.append(uZipUrl);
    nl.append(" %");
    nl.append(sd1.at(0));
    log(nl);
}
void UL::sendFinished()
{
    if(debugLog){
        lba="";
        lba.append("Sending data finished!\nResponse: ");
        lba.append(respuentaSendDatos->readAll());
        log(lba);
    }
    setUploadState(respuentaSendDatos->readAll());
}

