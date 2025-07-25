QT += qml quick
QT += sql network
QT += widgets quick3d


CONFIG += c++11

# mi_proyecto.pro

# Define tu variable (ejemplo)
PROYECTO = unikey
TARGET=$$PROYECTO
equals(PROYECTO, "unikey") {
    message("Cargando configuracion para unikey...")
    #include(unikey_config.pri)
} else:equals(PROYECTO, "zool") {
    message("Cargando configuracion para zool...")
    #include(zool_config.pri)
} else:equals(PROYECTO, "unik") {
    message("Cargando configuracion para unik...")
    #include(unik_config.pri)
} else {
    message("Valor desconocido para PROYECTO: $$PROYECTO. No se cargara ningun archivo de configuracion especifico.")
}


!linux:{
    message("Compilando en Windows")
    QT += widgets
    QT += webchannel
    include(win.pri)
} else {
    message("Compilando en GNU/Linux")
    QT += widgets
    #QT += webengine
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


# Ruta a la carpeta 'modules' dentro de tu proyecto
MODULES_SOURCE_DIR = $$PWD/modules

# Reglas de copia
# Verifica si la carpeta 'modules' existe antes de intentar copiarla
exists($$MODULES_SOURCE_DIR) {
    #QMAKE_POST_LINK += $$QMAKE_COPY_DIR \"$$MODULES_SOURCE_DIR\" \"$$DESTDIR/modules\"
} else {
    warning("La carpeta 'modules' no se encontró en $$MODULES_SOURCE_DIR. La copia no se realizará.")
}

# Si estás en Windows y necesitas un comando más robusto para copiar directorios:
win32 {
     #QMAKE_POST_LINK += $$quote(xcopy /E /I /Y "$$MODULES_SOURCE_DIR" "$$DESTDIR\\modules\\")
}

# Si estás en sistemas Unix/Linux/macOS:
unix {
     #QMAKE_POST_LINK += $$quote(cp -R "$$MODULES_SOURCE_DIR" "$$DESTDIR")
}
