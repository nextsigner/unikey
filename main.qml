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

    property string uExampleCode: ''

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
//                Flickable{
//                    width: col.width
//                    height: app.fs*10
//                    contentHeight: log.contentHeight
                Text{
                    id: log
                    text: '<b>Salida:</b><br>'
                    color: app.c2
                    width: col.width
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                }
                //}
                Button{
                    id: botCrearMainQmlDeEjemplo
                    text: 'Crear un ejemplo'
                    visible: false
                    onClicked: {
                        let cp = unik.currentFolderPath()
                        let fp=cp+'/main.qml'
                        unik.log('Creando el archivo main.qml en la carpeta ['+cp+']')
                        if(!unik.fileExist(fp)){
                            unik.setFile(fp, app.uExampleCode)
                            if(unik.fileExist(fp)){
                                unik.log('El archivo '+fp+' se ha creado correctamente.')
                                botLanzarQml.visible=true
                                botCrearMainQmlDeEjemplo.visible=false
                            }else{
                                unik.log('El archivo '+fp+' NO se ha creado correctamente.')
                            }
                        }else{
                            unik.log('El archivo '+fp+' ya existe!<br>No se ha creado nuevamente.')
                        }
                    }
                }
                Button{
                    id: botLanzarQml
                    text: 'Lanzar la aplicación'
                    visible: false
                    onClicked: {
                        let cp = unik.currentFolderPath()
                        let fp=cp+'/main.qml'
                        engine.load(fp)
                    }
                }
                Button{
                    id: botDeleteQmlFileExample
                    text: 'Eliminar main.qml de ejemplo'
                    visible: false
                    onClicked: {
                        let cp = unik.currentFolderPath()
                        let fp=cp+'/main.qml'
                        let fileData=unik.getFile(fp)
                        if(fileData===app.uExampleCode){
                            unik.deleteFile(fp)
                            if(!unik.fileExist(fp)){
                                unik.log('El archivo '+fp+' de ejemplo ha sido eliminado.')
                            }else{
                                unik.log('Ha ocurrido un problema. Se intentó borrar el archivo de ejemplo '+fp+' sin éxito.')
                            }
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        let c='import QtQuick 2.7\n'
        c+='import QtQuick.Controls 2.0\n'
        c+='import QtQuick.Window 2.0\n'
        c+='ApplicationWindow{\n'
        c+='    id: app\n'
        c+='    visible: true\n'
        c+='    visibility: "Maximized"\n'
        c+='    title: "App Ejemplo Unikey"\n'
        c+='    color: "black"\n'
        c+='    property int fs: Screen.width*0.02\n'
        c+='    Text{\n'
        c+='        text: "Esta es una ventana de aplicación de ejemplo creada por Unikey.\n\nEdita este archivo main.qml y ejecuta nuevamente Unikey para ver los cambios.\n\nPresiona la tecla ESCAPE para cerrar esta aplicación de ejemplo."\n'
        c+='        width: app.fs*30\n'
        c+='        font.pixelSize: app.fs\n'
        c+='        color: "white"\n'
        c+='        wrapMode: Text.WordWrap\n'
        c+='        anchors.centerIn: parent\n'
        c+='    }\n'
        c+='    Shortcut{\n'
        c+='        sequence: "Esc"\n'
        c+='     onActivated: Qt.quit()\n'
        c+='    }\n'
        c+='}\n'
        app.uExampleCode=c
        showStatusData()
    }

    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
    function showStatusData(){
        let cp = unik.currentFolderPath()
        let fp=cp+'/main.qml'
        unik.log('Carpeta actual: '+cp)
        let t1=''
        if(unik.fileExist(fp)){
            unik.log('Esta carpeta contiene un archivo main.qml')
            botLanzarQml.visible=true
            let fileData=unik.getFile(fp)
            //unik.log("["+fileData+"]")
            //unik.log("["+app.uExampleCode+"]")
            if(app.uExampleCode===fileData){
                unik.log('Se ha detectado que el archivo '+fp+' al parecer es un archivo de ejemplo de Unikey.')
                botLanzarQml.text='Lanzar la aplicación de Ejemplo'
                botDeleteQmlFileExample.visible=true
            }
        }else{
            unik.log('Esta carpeta NO contiene un archivo main.qml')
            unik.log('Es posible que estes viendo estos mensajes porque no tienes un archivo main.qml en esta carpeta.<br><br>El archivo main.qml es necesario para que Unikey inicie una aplicación del tipo QtQuick.')
            botCrearMainQmlDeEjemplo.visible=true
        }
    }
}
