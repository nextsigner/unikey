import QtQuick 2.12
import QtQuick.Window 2.12

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
                anchors.horizontalCenter: parent.horizontalCenter
                Item{width: 1; height: app.fs}
                Text{
                    text: '<h1>UniKey</h1>'
                    font.pixelSize: app.fs
                    color: app.c2
                }
                Text{
                    text: '<b>Directorio actual:</b> '+unik.currentFolderPath()
                    font.pixelSize: app.fs
                    color: app.c2
                }
            }
        }
    }

    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
}
