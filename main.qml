import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Window {
    id: app
    visible: true
    visibility: "Maximized"
    width: 640
    height: 480
    title: "UniKey"
    color: c1
    property int fs: Screen.width*0.02
    property color c1: 'black'
    property color c2: 'white'

    Connections{
        target: unik
        onUkStdChanged:{
            log.text+=''+unik.ukStd+'<br>'
        }
    }

    Item{
        id: xApp
        anchors.fill: parent
        Flickable{
            contentWidth: parent.width
            contentHeight: col.height+app.fs
            anchors.fill: parent
            Column{
                id: col
                spacing: app.fs
                width: xApp.width-app.fs
                anchors.horizontalCenter: parent.horizontalCenter
                Item{width: 1; height: app.fs}
                Text{
                    text: '<h1>UniKey</h1>'
                    font.pixelSize: app.fs
                    color: app.c2
                }
                Text{
                    text: '<b>Carpeta actual:</b> '+(unik?unik.currentFolderPath():'...')
                    font.pixelSize: app.fs
                    color: app.c2
                }
                Text{
                    text: '<b>Parámetros recibidos:</b> '+Qt.application.arguments.toString()
                    font.pixelSize: app.fs
                    color: app.c2
                    width: col.width
                    wrapMode: Text.WordWrap
                }
                Text{
                    id: log
                    text: '<b>Salida:</b><br>'
                    color: app.c2
                    width: col.width
                    wrapMode: Text.WordWrap
                }
                Button{
                    text: 'Probar'
                    onClicked: {
                        unik.cd('/home/ns/nsp')
                        unik.log("adfafa")
                        log.text+=''+unik.currentFolderPath()
                    }
                }
            }
        }
    }

    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
}
