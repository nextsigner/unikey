import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Window {
    id: app
    visible: false
    //visibility: "Maximized"
    width: 640
    height: 480
    title: "UniKey"
    color: c1

    property int fs: Screen.width*0.02
    property color c1: 'black'
    property color c2: 'white'

    property string cp

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
                spacing: app.fs*0.25
                width: xApp.width-app.fs
                anchors.horizontalCenter: parent.horizontalCenter
                Item{width: 1; height: app.fs*0.1}
                Text{
                    text: '<h3>UniKey</h3>'
                    font.pixelSize: app.fs
                    color: app.c2
                }
                Text{
                    text: '<b>Carpeta actual:</b> '+cp
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
                Item{width: 1; height: app.fs*2}
                Text{
                    text: '<b>Salida:</b>'
                    font.pixelSize: app.fs
                    color: app.c2
                    width: col.width
                    wrapMode: Text.WordWrap
                }
                Rectangle{
                    width: col.width
                    height: app.fs*10
                    color: 'transparent'
                    border.width: 1
                    border.color: 'white'
                    clip: true
                    Flickable{
                        id: flk
                        width: parent.width-app.fs
                        height: parent.height
                        contentWidth: log.contentWidth
                        contentHeight: log.contentHeight
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text{
                            id: log
                            color: app.c2
                            width: col.width-app.fs
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                            anchors.horizontalCenter: parent.horizontalCenter
                            onTextChanged: {
                                if(log.contentHeight>flk.height){
                                    flk.contentY=log.contentHeight-flk.height
                                }
                            }
                        }
                    }
                }
                Row{
                    spacing: app.fs
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
                                    botDeleteQmlFileExample.visible=true
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
                            unik.setProperty('fromUnikey', true)
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
                                    botLanzarQml.visible=false
                                    botDeleteQmlFileExample.visible=false
                                    botCrearMainQmlDeEjemplo.visible=true
                                }else{
                                    unik.log('Ha ocurrido un problema. Se intentó borrar el archivo de ejemplo '+fp+' sin éxito.')
                                }
                            }
                        }
                    }
                    Button{
                        text: 'Salir'
                        onClicked: {
                            Qt.quit()
                        }
                    }
                    Button{
                        //id: botDeleteQmlFileExample
                        text: 'Probar'
                        visible: false
                        property int v: 0
                        onClicked: {
                            v++
                            unik.log('ña dñalk sdlak ñasldk ñalks ñlk a\nña dñalk sdlak ñasldk ñalks ñlk a\nv:'+v)
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        while(!unik){
            log.text+='.'
        }
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
        c+='    Column{\n'
        c+='        spacing: app.fs\n'
        c+='        anchors.centerIn: parent\n'
        c+='        Text{\n'
        c+='            text: "Esta es una ventana de aplicación de ejemplo creada por Unikey.\n\nEdita este archivo main.qml y ejecuta nuevamente Unikey para ver los cambios.\n\nPresiona la tecla ESCAPE para cerrar esta aplicación de ejemplo."\n'
        c+='            width: app.fs*30\n'
        c+='            font.pixelSize: app.fs\n'
        c+='            color: "white"\n'
        c+='            wrapMode: Text.WordWrap\n'
        c+='            anchors.horizontalCenter: parent.horizontalCenter\n'
        c+='        }\n'
        c+='    }\n'
        c+='    Shortcut{\n'
        c+='        sequence: "Esc"\n'
        c+='     onActivated: {\n'
        c+='        if(unik.getProperty("fromUnikey")){\n'
        c+='            app.close()\n'
        c+='        }else{\n'
        c+='            Qt.quit()\n'
        c+='        }\n'
        c+='    }\n'
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
        let args=Qt.application.arguments
        cp = unik.currentFolderPath()
        let fp=cp+'/main.qml'
        unik.log('Carpeta actual: '+cp)

        let argIndexGit=getArgsIndex('git')
        let argIndexFolder=getArgsIndex('folder')
        if(argIndexFolder>=0){
            let a=args[argIndexFolder]
            unik.log('Ejecutando Unikey con el argumento '+a)
            let m0=a.split('=')
            unik.log('Chequeando si existe la carpeta '+m0[1])
            if(unik.folderExist(m0[1])){
                unik.log('Ingresando a la carpeta '+m0[1])
                unik.cd(m0[1])
                unik.log('Carpeta actual: '+unik.currentFolderPath())
                cp=m0[1]
                fp=cp+'/main.qml'
            }else{
                unik.log('Error!\nEl argumento '+a+' no se podrá procesar porque la carpeta '+m0[1]+' no existe!')
                unik.log('Se continúa en la carpeta actual: '+unik.currentFolderPath())
                app.visibility="Maximized"
            }
        }
        if(argIndexGit>=0){
            let a=args[argIndexGit]
            unik.log('Ejecutando Unikey con el argumento '+a)
            let m0=a.split('=')
            if(argIndexFolder>=0){
                let a=args[argIndexFolder]
                //unik.log('Ejecutando Unikey con el argumento '+a)
                let m0=a.split('=')
                unik.log('El repositorio git se descargará en la carpeta '+m0[1])
                if(unik.folderExist(m0[1])){
                    unik.log('Ingresando a la carpeta '+m0[1])
                    unik.cd(m0[1])
                    unik.log('Carpeta actual: '+unik.currentFolderPath())
                    cp=m0[1]
                    //fp=cp+'/main.qml'
                }else{
                    unik.log('La carpeta '+m0[1]+' no existe.')
                    unik.log('Creando la carpeta '+m0[1]+'')
                    unik.mkdir(m0[1])
                    if(unik.folderExist(m0[1])){
                        unik.log('La carpeta '+m0[1]+' fue creada con éxito.')
                        cp=m0[1]
                    }
                }
            }
            unik.log('Descargando '+a+' en la carpeta '+cp)
            let downloaded=unik.downloadGit(m0[1], 'main', cp)
            let gp0=m0[1].split('/')
            let gp=gp0[gp0.length-1]
            if(downloaded){
                unik.log('Listo. Se ha descargado '+a+' en la carpeta '+cp)
                //Git Project

                unik.log('Los archivos se descargaron en '+cp+'/'+gp)
                let fl=unik.getFolderFileList(cp+'/'+gp)
                unik.log('Archivos:\n ')
                for(var i=0;i<fl.length;i++){
                    if(fl[i]==='.' || fl[i]==='..' )continue
                    if(unik.isFolder(cp+'/'+gp+'/'+fl[i])){
                        unik.log('./'+fl[i])
                        let fl2=unik.getFolderFileList(cp+'/'+gp+'/'+fl[i])
                        for(var i2=0;i2<fl2.length;i2++){
                            if(fl2[i2]==='.' || fl2[i2]==='..' )continue
                            if(unik.isFolder(cp+'/'+gp+'/'+fl[i]+'/'+fl2[i2])){
                                //unik.log('&nbsp;&nbsp;/'+fl[i]+'/'+fl2[i2])
                                let fl3=unik.getFolderFileList(cp+'/'+gp+'/'+fl[i]+'/'+fl2[i2])
                                for(var i3=0;i3<fl3.length;i3++){
                                    if(fl3[i3]==='.' || fl3[i3]==='..' )continue
                                    if(unik.isFolder(cp+'/'+gp+'/'+fl[i]+'/'+fl2[i2]+'/'+fl3[i3])){
                                        unik.log('&nbsp;&nbsp;&nbsp;&nbsp;/'+fl[i]+'/'+fl2[i2]+'/'+fl3[i3])
                                    }else{
                                        unik.log('&nbsp;&nbsp;&nbsp;&nbsp;'+fl3[i3]+'\n')
                                    }
                                }
                            }else{
                                unik.log('&nbsp;&nbsp;'+fl2[i2]+'\n')
                            }
                        }
                    }else{
                        unik.log(''+fl[i]+'\n')
                    }
                }
                unik.cd(cp+'/'+gp)
                fp=cp+'/'+gp+'/main.qml'
                //engine.load(fp)
            }else{
                unik.log('Error! Ocurrió un error al descargar '+m0[1])
                unik.log('Hay un problema con la conexión de internet o el repositorio no existe.')
                unik.log('Ten en cuenta que Unikey está programado para descargar desde la rama "main", no "master".')
                app.visibility="Maximized"
            }
        }

        //let t1=''
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
            }else{
                unik.clearComponentCache()
                unik.setProperty('unik', unik)
                engine.load(fp)
                app.close()
            }
        }else{
            unik.log('Esta carpeta NO contiene un archivo main.qml')
            unik.log('Es posible que estes viendo estos mensajes porque no tienes un archivo main.qml en esta carpeta.<br><br>El archivo main.qml es necesario para que Unikey inicie una aplicación del tipo QtQuick.')
            botCrearMainQmlDeEjemplo.visible=true
            app.visibility="Maximized"
        }
    }
    function getArgsIndex(arg){
        let args=Qt.application.arguments
        let ret=-1
        for(var i=0;i<args.length;i++){
            let a=args[i]
            if(a.indexOf('-'+arg+'=')>=0){
                ret=i
                break
            }
        }
        return ret
    }
}
