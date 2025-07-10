#include "qmlerrorlogger.h"
#include <QDebug>
#include <QCoreApplication>
#include <QMutex>

static QmlErrorLogger* s_instance = nullptr;
static QMutex s_instanceMutex;

// Función global para manejar los mensajes de Qt
void myMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    Q_UNUSED(context);

    // Solo nos interesan los errores y advertencias del motor QML
    if (type == QtWarningMsg || type == QtCriticalMsg || type == QtFatalMsg) {
        // Usa un mutex para garantizar la seguridad del hilo
        QMutexLocker locker(&s_instanceMutex);
        if (s_instance) {
            // El mensaje se añade a la lista del logger
            s_instance->appendMessage(msg);
        }
    }
    // Opcionalmente, puedes reenviar el mensaje al manejador por defecto para que también se muestre en la consola
    QTextStream ts(stderr);
    ts << qFormatLogMessage(type, context, msg) << endl;
}

QmlErrorLogger::QmlErrorLogger(QObject *parent) : QObject(parent)
{
    // Establecer esta clase como la instancia para el manejador de mensajes
    QMutexLocker locker(&s_instanceMutex);
    s_instance = this;

    // Configurar el manejador de mensajes personalizado
    qInstallMessageHandler(myMessageOutput);
}

QVariantList QmlErrorLogger::messages() const
{
    return m_messages;
}

void QmlErrorLogger::appendMessage(const QString &message)
{
    m_messages.append(message);
    emit messagesChanged();
}
