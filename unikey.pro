QT += qml quick
QT += sql network
QT += widgets quick3d


CONFIG += c++11

win64:{
    message("Compilando en Windows")
    QT += webenginewidgets
    QT += webchannel
    include(win.pri)
} else {
    message("Compilando en GNU/Linux")
    QT += webenginewidgets
    QT += webengine
    QT += webchannel
    include(lin.pri)
}

SOURCES += \
        main.cpp \
        qmlerrorlogger.cpp \
        row.cpp \
        ul.cpp \
        unikargsproc.cpp \
        unikqprocess.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    qmlclipboardadapter.h \
    qmlerrorlogger.h \
    row.h \
    ul.h \
    unikargsproc.h \
    unikqprocess.h


# Define la ruta de tu imagen de origen
LOGO_SOURCE = $$PWD/logo.png

# Define el directorio de destino
LOGO_DEST = $$DESTDIR

# Añade una regla para copiar el archivo
# Usa QMAKE_POST_LINK para que la copia se realice después de que el ejecutable haya sido enlazado
QMAKE_POST_LINK += $$QMAKE_COPY \"$$replace(LOGO_SOURCE, /, $$QMAKE_DIR_SEP)\" \"$$replace(LOGO_DEST, /, $$QMAKE_DIR_SEP)\"
