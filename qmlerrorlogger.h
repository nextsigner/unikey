#ifndef QMLERRORLOGGER_H
#define QMLERRORLOGGER_H

#include <QObject>
#include <QVariantList>

class QmlErrorLogger : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList messages READ messages NOTIFY messagesChanged)

public:
    explicit QmlErrorLogger(QObject *parent = nullptr);
    QVariantList messages() const;

signals:
    void messagesChanged();

public slots:
    void appendMessage(const QString &message);

private:
    QVariantList m_messages;
};

#endif // QMLERRORLOGGER_H
