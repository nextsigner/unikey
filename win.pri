#DEPLOY
#cd C:\Qt\Qt5.14.2\5.14.2\mingw73_32\bin
#windeployqt.exe --qmldir "Z:\home\ns\nsp\unikey" "C:\build_win\unikey.exe"


# Para la configuración Release
CONFIG(release, debug|release):{
    DESTDIR = C:\build_win
}

#Building Quazip from Windows 8.1
INCLUDEPATH += C:\quazip
DEFINES+=QUAZIP_STATIC
HEADERS += C:\quazip\*.h
SOURCES += C:\quazip\*.cpp
SOURCES += C:\quazip\*.c

