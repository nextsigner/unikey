#Linux Deploy
#Deploy Command Line Example
#wine cmd.exe
#1) cd C:\Qt\Qt5.14.2\5.14.2\mingw73_32\bin

#2) windeployqt.exe --qmldir "Z:\home\ns\nsp\unikey" "C:\build_win\unikey.exe"

#3) optional) Copy full plugins and qml folder for full qtquick support.
#Copy C:\Qt\Qt5.14.2\5.14.2\mingw73_32\qml and C:\Qt\Qt5.14.2\5.14.2\mingw73_32\plugins folders manualy to the executable folder location.
#copy C:\Qt\Qt5.14.2\5.14.2\mingw73_32\qml C:\build_win
#copy C:\Qt\Qt5.14.2\5.14.2\mingw73_32\plugins C:\build_win

#4) copy unikey\logo.ico C:\build_win\logo.ico



equals(PROYECTO, "unikey") {
    message("Cargando configuracion para unikey...")
    #DESTDIR = F:\zooldev\unikey-build
    DESTDIR = F:\zooldev\unikey-build-dep
    #DESTDIR = Z:\media\ns\Archivos\zooldev\unikey-build
    RC_FILE = $$PWD/res_$$PROYECTO/unikey.rc
} else:equals(PROYECTO, "zool") {
    message("Cargando configuracion para zool...")
    DESTDIR = F:\zooldev\zool-build-dep
    RC_FILE = $$PWD/res_$$PROYECTO/zool.rc
} else:equals(PROYECTO, "unik") {
    message("Cargando configuracion para unik...")
    include(unik_config.pri)
} else {
    message("Valor desconocido para PROYECTO: $$PROYECTO. No se cargara ningun archivo de configuracion especifico.")
}

# Indicar dónde están los encabezados
INCLUDEPATH += $$PWD\libs\swiseph

# Incluir todos los archivos fuente de la librería
# Usamos un comodín para no listar uno por uno
SOURCES += $$PWD\libs\swisseph\*.c

# Incluir las cabeceras
HEADERS += $$PWD\libs\swisseph\*.h

# En Windows, a veces es necesario evitar advertencias de funciones antiguas
win32: DEFINES += _CRT_SECURE_NO_WARNINGS

