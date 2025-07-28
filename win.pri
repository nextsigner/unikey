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



# Para la configuración Release
CONFIG(release, debug|release):{
    #message(Arch3 $$QT_ARCH)
    #message(Arch2 $$QMAKE_TARGET)
    equals(QT_ARCH, i386) {
        message(Compilando para Windows 32bit)
        DESTDIR = F:\build_win_32
    }
    equals(QT_ARCH, x86_64) {
        message(Compilando para Windows 64bit)
        DESTDIR = F:\zooldev\unikey-build
    }
}


equals(PROYECTO, "unikey") {
    message("Cargando configuracion para unikey...")
    #DESTDIR = Z:\media\ns\Archivos\zooldev\unikey-build
    DESTDIR = C:\unikey-build
    RC_FILE = $$PWD/res_$$PROYECTO/unikey.rc
} else:equals(PROYECTO, "zool") {
    message("Cargando configuracion para zool...")
    DESTDIR = F:\zooldev\zool-win-64\build
    RC_FILE = $$PWD/res_$$PROYECTO/zool.rc
} else:equals(PROYECTO, "unik") {
    message("Cargando configuracion para unik...")
    include(unik_config.pri)
} else {
    message("Valor desconocido para PROYECTO: $$PROYECTO. No se cargara ningun archivo de configuracion especifico.")
}
