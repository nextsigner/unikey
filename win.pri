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
        DESTDIR = C:\build_win
    }
    equals(QT_ARCH, x86_64) {
        message(Compilando para Windows 64bit)
        DESTDIR = C:\build_win_64
    }
}

RC_FILE = unikey.rc

#Building Quazip from Windows 8.1
INCLUDEPATH += C:\quazip
DEFINES+=QUAZIP_STATIC
HEADERS += C:\quazip\*.h
SOURCES += C:\quazip\*.cpp
SOURCES += C:\quazip\*.c

