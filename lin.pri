#Linux Deploy
#Deploy Command Line Example

#1) Situarse en la carpeta principal. cd ~

#2) Edit default.desktop

#3)  ~/linuxdeployqt-continuous-x86_64.AppImage /home/ns/unik/build_linux/unik -qmldir=/home/ns/unik -qmake=/home/ns/Qt/5.15.2/gcc_64/bin/qmake -verbose=3


#4 optional) Copy full plugins and qml folder for full qtquick support.
#Copy <QT-INSTALL>/gcc_64/qml and <QT-INSTALL>/gcc_64/plugins folders manualy to the executable folder location.
#cp -r ~/Qt/5.15.2/gcc_64/qml ~/unik/build_linux/
#cp -r ~/Qt/5.15.2/gcc_64/plugins ~/unik/build_linux/

#Make Unik AppImage (The AppImage version is maked automatically from ./build_linux/default.desktop file)
#5) ~/linuxdeployqt-continuous-x86_64.AppImage /home/ns/unik/build_linux/unik -qmldir=/home/ns/unik -qmake=/home/ns/Qt/5.15.2/gcc_64/bin/qmake -verbose=3 -bundle-non-qt-libs -no-plugins -appimage

#6 optional) Copy nss3 files into
#cp -r /usr/lib/x86_64-linux-gnu/nss <executable path>/

# Para la configuración Release
CONFIG(release, debug|release):{
    DESTDIR = /home/ns/nsp/zool/build_lin
}

#Building Quazip from Ubuntu 16.10
#Compile quazip.pro and install with sudo make install from the $$OUT_PWD
INCLUDEPATH += $$PWD/quazip
LIBS += -lz
LIBS+=-L/usr/local/zlib/lib
INCLUDEPATH+=/usr/local/zlib/include
HEADERS += $$PWD/quazip/*.h
SOURCES += $$PWD/quazip/*.cpp
SOURCES += $$PWD/quazip/*.c
