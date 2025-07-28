#include "ul.h"

UL::UL(QObject *parent) : QObject(parent)
{

}

void UL::cd(const QString &path)
{
    QDir dir; // QDir con el directorio de trabajo actual

    // Verifica si la ruta existe y es un directorio
    QDir targetDir(path);
    if (!targetDir.exists() || !targetDir.isReadable()) { // También verificamos si es legible
        qWarning() << "No se puede cambiar al directorio:" << path << "- El directorio no existe o no es accesible.";
        //emit currentDirectoryChanged(path, false);
        return;
    }

    // Intenta cambiar el directorio de trabajo actual
    if (dir.setCurrent(path)) {
        qDebug() << "Directorio de trabajo cambiado a:" << dir.currentPath();
        //emit currentDirectoryChanged(dir.currentPath(), true);
    } else {
        qWarning() << "Error al cambiar el directorio de trabajo a:" << path;
        //emit currentDirectoryChanged(path, false);
    }
}
bool UL::deleteFolder(const QString &path)
{
    QDir dir(path);

    // Verifica si el directorio existe
    if (!dir.exists()) {
        qWarning() << "El directorio no existe:" << path;
        //emit directoryRemoved(path, false); // Emite la señal con fallo
        return false;
    }

    // Intenta eliminar el directorio y su contenido recursivamente
    // (Esto funciona tanto en Linux como en Windows)
    if (dir.removeRecursively()) {
        qDebug() << "Directorio eliminado exitosamente:" << path;
        //emit directoryRemoved(path, true); // Emite la señal con éxito
        return true;
    } else {
        qWarning() << "Error al eliminar el directorio:" << path;
        // Puedes agregar más detalles sobre el error si es necesario
        // QDirF:Recursively() puede fallar por permisos, archivos abiertos, etc.
        //emit directoryRemoved(path, false); // Emite la señal con fallo
        return false;
    }
}

QString UL::currentFolderPath()
{
    QString currentPath = QDir::currentPath(); // Obtiene el directorio de trabajo actual

    qDebug() << "Directorio de trabajo actual:" << currentPath;
    //emit currentFolderPathRetrieved(currentPath); // Emite la señal con la ruta (opcional)

    return currentPath;
}

QString UL::currentFolderName()
{
    QDir f(QDir::currentPath());
    return f.dirName();
}
bool UL::deleteFile(QByteArray f)
{
    QFile arch(f);
    return arch.remove();
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

bool UL::folderExist(const QString &path)
{
    QDir dir(path);
    bool exists = dir.exists(); // <-- Aquí es donde se verifica la existencia

    if (exists) {
        log("La carpeta existe:");
    } else {
        log("La carpeta NO existe, creando con mkdir()...");
    }
    //emit folderExistenceChecked(path, exists); // Emite la señal con el resultado (opcional)
    return exists;
}
bool UL::fileExist(QByteArray fileName)
{
    QFile a(fileName);
    if(!a.exists()){
        QFile a2(QString(fileName).replace("\"", ""));
        if(a2.exists()){
            return a2.exists();
        }
    }
    return a.exists();
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

bool UL::mkdir(const QString &path)
{
    QDir dir(path);

    // Verifica si el directorio ya existe
    if (dir.exists()) {
        qWarning() << "El directorio ya existe:" << path;
        //emit directoryCreated(path, false); // Emite la señal con fallo (ya existe)
        return false;
    }

    // Intenta crear el directorio.
    // QDir::mkpath() es preferible a QDir::mkdir() porque crea todos los directorios
    // intermedios necesarios si no existen (similar a 'mkdir -p' en Linux).
    if (dir.mkpath(path)) {
        qDebug() << "Directorio creado exitosamente:" << path;
        //emit directoryCreated(path, true); // Emite la señal con éxito
        return true;
    } else {
        qWarning() << "Error al crear el directorio:" << path;
        // Esto podría fallar por permisos insuficientes o si la ruta es inválida.
        //emit directoryCreated(path, false); // Emite la señal con fallo
        return false;
    }
}

bool UL::isFolder(const QString &folder)
{
          QFileInfo archivoInfo(folder);
          return archivoInfo.isDir();
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

void UL::restart(const QStringList &args, const QString &newWorkingDirectory)
{
    QString applicationPath = QCoreApplication::applicationFilePath();
        QString finalWorkingDirectory = newWorkingDirectory;

        qDebug() << "Intentando reiniciar aplicación...";
        qDebug() << "Ruta de la aplicación:" << applicationPath;
        qDebug() << "Argumentos:" << args.join(" ");

        if (!newWorkingDirectory.isEmpty()) {
            QDir newDir(newWorkingDirectory);
            if (!newDir.exists() || !newDir.isReadable()) {
                qWarning() << "El nuevo directorio de trabajo especificado no existe o no es accesible:" << newWorkingDirectory;
                //emit restartAttempted(false, "El directorio de trabajo no existe o no es accesible.");
                return;
            }
            finalWorkingDirectory = QDir::cleanPath(newDir.absolutePath());
            qDebug() << "Nuevo directorio de trabajo (final):" << finalWorkingDirectory;
        } else {
            finalWorkingDirectory = QCoreApplication::applicationDirPath();
            qDebug() << "No se especificó nuevo directorio de trabajo, usando el actual:" << finalWorkingDirectory;
        }

        // Usamos QProcess::startDetached() que es no bloqueante y adecuado para esto.
        bool started = QProcess::startDetached(applicationPath, args, finalWorkingDirectory);

        if (started) {
            qDebug() << "Proceso de reinicio iniciado exitosamente.";
            //emit restartAttempted(true, "Reinicio exitoso.");

            // *** CAMBIO CLAVE AQUÍ ***
            // Retrasar el cierre de la aplicación actual para dar tiempo al nuevo proceso a independizarse.
            // Unos pocos milisegundos suelen ser suficientes.
            QTimer::singleShot(5000, QCoreApplication::instance(), &QCoreApplication::quit);
            // Opcional: Si necesitas un retardo más garantizado (aunque bloqueante para la UI en este hilo)
            // QThread::msleep(200); // Bloquea el hilo actual por 200 ms
            // QCoreApplication::quit(); // Luego, cierra la aplicación
        } else {
            qWarning() << "Fallo al iniciar el proceso de reinicio.";
            //emit restartAttempted(false, "Fallo al iniciar el proceso de reinicio.");
        }
}
void UL::restartApp()
{

#ifndef Q_OS_ANDROID
#ifndef Q_OS_IOS
    qApp->quit();
    //QProcess::startDetached(qApp->arguments()[0], qApp->arguments());
    QProcess::startDetached(qApp->arguments()[0], QStringList());
#endif
#else
    //qApp->quit();
    //QProcess::startDetached(qApp->arguments()[0], qApp->arguments());

    auto activity = QtAndroid::androidActivity();
    auto packageManager = activity.callObjectMethod("getPackageManager", "()Landroid/content/pm/PackageManager;");

    auto activityIntent = packageManager.callObjectMethod("getLaunchIntentForPackage",
                                                          "(Ljava/lang/String;)Landroid/content/Intent;",
                                                          activity.callObjectMethod("getPackageName",
                                                                                    "()Ljava/lang/String;").object());

    auto pendingIntent = QAndroidJniObject::callStaticObjectMethod("android/app/PendingIntent", "getActivity",
                                                                   "(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;",
                                                                   activity.object(), jint(0), activityIntent.object(),
                                                                   QAndroidJniObject::getStaticField<jint>("android/content/Intent",
                                                                                                           "FLAG_ACTIVITY_CLEAR_TOP"));

    auto alarmManager = activity.callObjectMethod("getSystemService",
                                                  "(Ljava/lang/String;)Ljava/lang/Object;",
                                                  QAndroidJniObject::getStaticObjectField("android/content/Context",
                                                                                          "ALARM_SERVICE",
                                                                                          "Ljava/lang/String;").object());

    alarmManager.callMethod<void>("set",
                                  "(IJLandroid/app/PendingIntent;)V",
                                  QAndroidJniObject::getStaticField<jint>("android/app/AlarmManager", "RTC"),
                                  jlong(QDateTime::currentMSecsSinceEpoch() + 1500), pendingIntent.object());

    qApp->quit();
#endif
    //emit restartingApp();
}

void UL::restartApp(QString args)
{
    qApp->quit();
    QStringList al = args.split(",");
    qDebug()<<"Restarting executable "<<qApp->applicationFilePath();
#ifdef Q_OS_LINUX
    QProcess::startDetached(qApp->applicationFilePath(), al);
#else
    QProcess::startDetached(qApp->arguments()[0], al);
#endif
}

bool UL::run(QString commandLine){
    return run(commandLine, false, 0);
}

bool UL::run(QString commandLine, bool waitingForFinished, int milliseconds)
{
#ifndef Q_OS_ANDROID
    proc = new QProcess(this);
    connect(proc, SIGNAL(readyReadStandardOutput()),this, SLOT(salidaRun()));
    connect(proc, SIGNAL(readyReadStandardError()),this, SLOT(salidaRunError()));
    proc->start(commandLine);
    //proc->start("sh",QStringList() << "-c" << "ls");
    if(waitingForFinished){
        if (!proc->waitForFinished(milliseconds)){
            qDebug() << "timeout .. ";
        }
    }
    if(proc->isOpen()){
        setRunCL(true);
        QString msg;
        msg.append("Run: ");
        msg.append(commandLine);
        setUkStd(msg);
        return true;
    }else{
        QString msg;
        msg.append("No Run: ");
        msg.append(commandLine);
        setUkStd(msg);
        setRunCL(false);
    }
#endif
    return false;
}

void UL::writeRun(QString data)
{
    proc->write(data.toUtf8());
}

bool UL::runOut(QString lineaDeComando)
{
#ifndef Q_OS_ANDROID
    proc = new QProcess(this);
    connect(proc, SIGNAL(readyReadStandardOutput()),this, SLOT(salidaRun()));
    connect(proc, SIGNAL(readyReadStandardError()),this, SLOT(salidaRunError()));
    proc->startDetached(lineaDeComando);
    if(proc->isOpen()){
        setRunCL(true);
        qInfo()<<"Ejecutando "<<lineaDeComando;
        return true;
    }else{
        qInfo()<<"No se està ejecutando "<<lineaDeComando;
        setRunCL(false);
    }
#endif
    return false;
}

void UL::salidaRun()
{
    log(proc->readAllStandardOutput());
}

void UL::salidaRunError()
{
    log(proc->readAllStandardError());
}

void UL::finalizaRun(int e)
{
    QByteArray s;
    s.append("command line finished with status ");
    s.append(QString::number(e));
    log(s);
    proc->close();
}

void UL::log(QByteArray d)
{
    log(d, false);
}

void UL::log(QByteArray d, bool htmlEscaped)
{
    QString d2;
    d2.append(d);
    if(!_engine->rootContext()->property("setInitString").toBool()){
        initStdString.append(d2);
        initStdString.append("\n");
    }
    setUkStd(d2, htmlEscaped);
}

void UL::sleep(int ms)
{
    QThread::sleep(ms);
}

QString UL::getPath(int path)
{
    QString r=".";
    if(path==0){//App location Name
        r="";
        r.append(qApp->applicationDirPath());
        r.append("/");
        r.append(QFileInfo(QCoreApplication::applicationFilePath()).fileName());
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
        //r = QDir::currentPath();
        r = qApp->applicationDirPath();
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
        //r = QDir::currentPath();
        r="X:/Users/Default/AppData/Roaming/UniKey/zoolv4/zoolv4-main";
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

