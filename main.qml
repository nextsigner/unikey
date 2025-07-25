import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.1
import ZipManager 4.0

Window {
    id: app
    visible: false
    //visibility: "Maximized"
    width: 640
    height: 480
    title: presetAppName
    color: c1

    property string ctx: ''
    property int fs: Screen.width*0.015
    property int botFs: fs*0.6
    property color c1: 'black'
    property color c2: 'white'

    property var appArgs: []

    property string cp

    property string uExampleCode: ''

    property bool enableQmlErrorLog: true
    property string uLogData: ''

    Settings{
        id: apps
        fileName: unik?apps.mainFolder+'/'+(''+presetAppName).toLowerCase()+'_app.cfg':''
        property bool dev: false
        property string mainFolder: ''
        property bool runFromGit: false
        property bool runOut: true
        property string uGitRep: 'https://github.com/nextsigner/unikey-apps'
        property string uFolder: unik.getPath(3)
        property bool enableCheckBoxShowGitRep: false
        property color fontColor: 'white'
        property color backgroundColor: 'black'
        property string uCtxUpdate: ''
    }


    Connections{
        target: unik
        property int i: 1
        onUkStdChanged:{
            log.text+=i+': '+unik.ukStd+'<br>'
            let fp=apps.mainFolder+'/log'
            let ld=i>1?unik.getFile(fp):''
            ld+=i+': '+unik.ukStd
            unik.setFile(fp, ld)
            i++
        }
    }
    Connections{
        target: qmlErrorLogger
        onMessagesChanged:{
            if(Qt.platform.os==='linux' && app.enableQmlErrorLog){
                app.visibility="Maximized"
                log.text+=''+qmlErrorLogger.messages[qmlErrorLogger.messages.length-1]+'<br>'
            }
        }
    }

    Item{
        id: xApp
        anchors.fill: parent
        Flickable{
            id: flickabler
            contentWidth: parent.width
            contentHeight: col.height+app.fs
            //anchors.fill: parent
            width: parent.width
            height: parent.height
            Column{
                id: col
                spacing: app.fs//*0.25
                width: xApp.width-app.fs
                anchors.horizontalCenter: parent.horizontalCenter
                Item{width: 1; height: app.fs*0.1}
                Text{
                    text: '<h3>'+presetAppName+'</h3>'
                    font.pixelSize: app.fs
                    color: app.c2
                }
                /*Text{
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
                Item{width: 1; height: app.fs*0.5}*/

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
                        contentHeight: log.contentHeight+app.fs
                        anchors.horizontalCenter: parent.horizontalCenter
                        ScrollBar.vertical: ScrollBar {
                            width: log.font.pixelSize
                            anchors.left: parent.right
                            policy: ScrollBar.AlwaysOn
                        }
                        Text{
                            id: log
                            color: app.c2
                            width: col.width-app.fs
                            //height: app.fs*6
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                            font.pixelSize: app.fs*0.65
                            anchors.horizontalCenter: parent.horizontalCenter
                            onTextChanged: {
                                if(log.contentHeight>flk.height){
                                    flk.contentY=log.contentHeight-flk.height
                                }
                            }
                            function lv(text){
                                app.uLogData+=text+'\n'
                                log.text+=''+text+'<br>'
                            }
                        }
                    }
                }

                Row{
                    spacing: app.botFs
                    anchors.horizontalCenter: parent.horizontalCenter
                    Button{
                        id: botCrearMainQmlDeEjemplo
                        text: 'Crear un ejemplo'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
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
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        onClicked: {
                            let cp = unik.currentFolderPath()
                            let fp=cp+'/main.qml'
                            unik.setProperty('from'+presetAppName, true)
                            if(Qt.platform.os==='linux'){
                                unik.setProperty("documentsPath", unik.getPath(3))
                                unik.addImportPath(cp+'/modules')
                                engine.load(fp)
                            }else{
                                unik.runOut('"'+unik.getPath(0)+'" -folder="'+cp+'"')
                            }
                            if(!apps.dep){
                                app.close()
                            }else{
                                apps.dev=true
                            }
                        }
                    }
                    Button{
                        id: botDeleteQmlFileExample
                        text: 'Eliminar main.qml de ejemplo'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
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
                                    if(!checkBoxShowGitRep.checked)botCrearMainQmlDeEjemplo.visible=true
                                }else{
                                    unik.log('Ha ocurrido un problema. Se intentó borrar el archivo de ejemplo '+fp+' sin éxito.')
                                }
                            }
                        }
                    }
                    Row{
                        Text{
                            text: '<b>Configurar Repositorio:</b>'
                            color: 'white'
                            font.pixelSize: app.fs
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        CheckBox{
                            id: checkBoxShowGitRep
                            checked: apps.enableCheckBoxShowGitRep
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: {
                                apps.enableCheckBoxShowGitRep=checked
                            }
                        }
                    }
                    Row{
                        Text{
                            text: '<b>Auto Actualizar</b><br><b>desde Git:</b>'
                            color: 'white'
                            font.pixelSize: app.fs
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        CheckBox{
                            id: checkBoxAAG
                            checked: apps.runFromGit
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: {
                                apps.runFromGit=checked
                            }
                        }
                    }
                    Row{
                        Text{
                            text: '<b>Depurar:</b>'
                            color: 'white'
                            font.pixelSize: app.fs
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        CheckBox{
                            id: checkBoxRunOut
                            checked: apps.runOut
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: {
                                apps.runOut=checked
                            }
                        }
                    }
                    Row{
                        Text{
                            text: '<b>Desarrollador:</b>'
                            color: 'white'
                            font.pixelSize: app.fs
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        CheckBox{
                            id: checkBoxDev
                            checked: apps.dev
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: {
                                apps.dev=checked
                            }
                        }
                    }
                }
                Row{
                    spacing: app.fs*0.25
                    anchors.horizontalCenter: parent.horizontalCenter
                    //visible: checkBoxShowGitRep.checked
                    Text{
                        id: txtTitMainFolder
                        text: '<b>Carpeta Principal:</b>'
                        font.pixelSize: app.fs
                        color: 'white'
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle{
                        width: xApp.width-txtTitMainFolder.contentWidth-botDefinirMainFolder.width-app.fs*1.75
                        height: app.fs*1.5
                        color: 'transparent'
                        border.width: 1
                        border.color: 'white'
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        TextInput{
                            id: tiMainFolder
                            text: apps.mainFolder
                            font.pixelSize: app.fs
                            width: parent.width-app.fs*0.5
                            height: parent.height-app.fs*0.5
                            color: 'white'
                            anchors.centerIn: parent
                            onTextChanged: {
                                if(!unik.folderExist(text)){
                                    unik.log('La carpeta ['+text+'] no existe.')
                                    tiMainFolder.color='red'
                                }else{
                                    tiMainFolder.color=apps.fontColor
                                }
                            }
                        }
                    }
                    Button{
                        id: botDefinirMainFolder
                        text: 'Definir'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            if(!unik.folderExist(text)){
                                apps.mainFolder=tiMainFolder.text
                            }else{

                            }
                        }
                    }
                }
                Row{
                    spacing: app.fs*0.25
                    anchors.horizontalCenter: parent.horizontalCenter
                    //visible: checkBoxShowGitRep.checked
                    Text{
                        id: txtTitGitRep
                        text: checkBoxShowGitRep.checked?'<b>Repositorio Git:</b>':'<b>Carpeta de Origen:</b>'
                        font.pixelSize: app.fs
                        color: 'white'
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle{
                        width: xApp.width-txtTitGitRep.contentWidth-botSaveGitRep.width-botProbarGitRep.width-app.fs*1.75
                        height: app.fs*1.5
                        color: 'transparent'
                        border.width: 1
                        border.color: 'white'
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        visible: checkBoxShowGitRep.checked
                        TextInput{
                            id: tiGitRep
                            text: apps.uGitRep
                            font.pixelSize: app.fs
                            width: parent.width-app.fs*0.5
                            height: parent.height-app.fs*0.5
                            color: 'white'
                            anchors.centerIn: parent
                            onTextChanged: {
                                if(zipManager.curlPath!=='')zipManager.mkUqpRepExist(text)
                            }

                        }
                    }
                    Rectangle{
                        width: xApp.width-txtTitGitRep.contentWidth-botSaveGitRep.width-botProbarGitRep.width-app.fs*1.75
                        height: app.fs*1.5
                        color: 'transparent'
                        border.width: 1
                        border.color: 'white'
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !checkBoxShowGitRep.checked
                        TextInput{
                            id: tiFolder
                            text: apps.uFolder
                            font.pixelSize: app.fs
                            width: parent.width-app.fs*0.5
                            height: parent.height-app.fs*0.5
                            color: 'white'
                            anchors.centerIn: parent
                            onTextChanged: {
                                if(!unik.folderExist(text)){
                                    unik.log('La carpeta ['+text+'] no existe.')
                                    tiFolder.color='red'
                                }else{
                                    tiFolder.color=apps.fontColor
                                }
                            }

                        }
                    }
                    Button{
                        id: botProbarGitRep
                        text: 'Probar'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            runMix('probe')
                        }
                    }
                    Button{
                        id: botSaveGitRep
                        text: 'Instalar'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            runMix('install')
                        }
                    }
                }
                Column{
                    id: colZM
                    ZipManager{
                        id: zipManager
                        width: apps.dev?xApp.width-app.fs:xApp.width*0.6
                        parent: apps.dev?colZM:colSplash
                        visible: true
                        dev: apps.dev
                        //version: '1.1.1'
                        onCPorcChanged:{
                            if(cPorc>=0.01){
                                app.visibility='Maximized'
                            }
                        }
                        onLog: unik.log(data)
                        onDownloadFinished: {
                            //Retorna: downloadFinished(string url, string folderPath, string zipFileName)
                            unik.log('Se descargó: '+zipFileName)
                            unik.log('Origen: '+url)
                            unik.log('Destino: '+folderPath)
                        }
                        onUnzipFinished: {
                            //Retorna: unzipFinished(string url, string folderPath, string zipFileName)
                            unik.log('Se ha descomprimido: '+zipFileName)
                        }
                        onResponseRepExist:{
                            if(res.indexOf('404')>=0){
                                tiGitRep.color='red'
                                unik.log('El repositorio ['+url+'] no existe.')
                            }else{
                                tiGitRep.color=apps.fontColor
                                unik.log('El repositorio ['+url+'] está disponible en internet.')
                                unik.log('Para probarlo presiona ENTER')
                                unik.log('Para instalarlo presiona Ctrl+ENTER')
                            }
                        }
                        onResponseRepVersion:{
                            procRRV(res, url, tipo)
                        }
                        //                        onResponseRepExist:{
                        //                            if(res.indexOf('404')>=0){
                        //                                tiGitRep.color='red'
                        //                                unik.log('El repositorio ['+url+'] no existe.')
                        //                            }else{
                        //                                tiGitRep.color=apps.fontColor
                        //                                unik.log('El repositorio ['+url+'] está disponible en internet.')
                        //                                unik.log('Para probarlo presiona ENTER')
                        //                                unik.log('Para instalarlo presiona Ctrl+ENTER')
                        //                            }
                        //                        }
                        //                    }

                    }
                }
                Row{
                    spacing: app.botFs
                    anchors.right: parent.right
                    Button{
                        text: 'Restablecer Configuración por Defecto'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        onClicked: {
                            restoreDefaultCfg()
                        }
                        Timer{
                            running: true
                            repeat: true
                            interval: 1000
                            onTriggered: {
                                if(unik.fileExist(unik.getPath(1)+'/default.cfg')){
                                    parent.visible=true
                                }else{
                                    parent.visible=false
                                }
                            }
                        }
                    }
                    Button{
                        text: 'Eliminar Configuración'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            let aname=(''+presetAppName).toLowerCase()
                            unik.deleteFile(apps.mainFolder+'/'+aname+'.cfg')
                            unik.log('Archivo de configuración eliminado.')
                        }
                    }
                    Button{
                        text: 'Reiniciar cargando configuración'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            unik.setFile(apps.mainFolder+'/log', app.uLogData)
                            unik.restartApp()
                        }
                    }
                    Button{
                        text: 'Reiniciar sin cargar configuración'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            unik.setFile(apps.mainFolder+'/log', app.uLogData)
                            unik.restartApp('-nocfg')
                        }
                    }
                    Button{
                        text: 'Salir'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            Qt.quit()
                        }
                    }
                }


            }
        }
    }
    Rectangle{
        color: apps.backgroundColor
        anchors.fill: parent
        visible: !apps.dev
        Column{
            spacing: app.fs*0.5
            width: parent.width*0.6
            anchors.centerIn: parent
            Text{
                text: '<h3>'+presetAppName+'</h3>'
                font.pixelSize: app.fs
                color: app.c2
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Column{
                id: colSplash
                spacing: app.fs*0.5
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text{
                text: 'Presionar Ctrl+d para ver más detalles'
                font.pixelSize: app.fs*0.5
                color: app.c2
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    Component.onCompleted: {
        zipManager.curlPath = Qt.platform.os==='windows'?'"'+unik.getPath(1).replace(/\"/g, '')+'/curl-8.14.1_2-win64-mingw/bin/curl.exe"':'curl'
        unik.log('Curl Path: '+zipManager.curlPath)
        zipManager.app7ZipPath = Qt.platform.os==='windows'?'"'+unik.getPath(1).replace(/\"/g, '')+'/7-Zip32/7z.exe"':'7z'
        unik.log('7z Path: '+zipManager.app7ZipPath)
        zipManager.uFolder = '"'+unik.getPath(3)+'"'
        //        while(!unik){
        //            log.text+='.'
        //        }
        if(apps.mainFolder==='')apps.mainFolder=unik.getPath(4)
        let aname=(''+presetAppName).toLowerCase()
        var cfgDefaultPath='"'+apps.mainFolder.replace(/\"/g, '')+'/'+aname+'.cfg"'
        if(!unik.fileExist(cfgDefaultPath)){
            console.log('Resaurando ['+cfgDefaultPath+']')
            restoreDefaultCfg(cfgDefaultPath)
            unik.log('Se ha restaurado la configuración por defecto: '+cfgDefaultPath)
        }
        if(apps.mainFolder==='')apps.mainFolder=unik.getPath(4)

        //Setear CTX
        app.ctx=getCtx()
        unik.log('Args: '+Qt.application.arguments)
        unik.log('Contexto: '+app.ctx)
        //app.visibility='Maximized'
        //apps.dev=true

        //RUN CTXs
        if(app.ctx==='nocfg'){
            app.visibility='Maximized'
            apps.dev=true
            return
        }
        if(app.ctx==='cfg-ugit'){
            runCtxCfgUGit()
            return
        }
        if(app.ctx==='ugit'){
            runCtxUGit()
            return
        }
        if(app.ctx==='cfg-git'){
            runCtxCfgGit()
            return
        }
        if(app.ctx==='cfg-folder'){
            runCtxCfgFolder()
            return
        }
        if(app.ctx==='git'){
            runCtxGit()
            return
        }
        if(app.ctx==='folder'){
            runCtxFolder()
            return
        }




        return





        zipManager.uFolder = unik.getPath(3)
        tiGitRep.focus=true
        tiGitRep.selectAll()

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
        c+='        if(unik.getProperty("from'+presetAppName+'")){\n'
        c+='            app.close()\n'
        c+='        }else{\n'
        c+='            Qt.quit()\n'
        c+='        }\n'
        c+='    }\n'
        c+='    }\n'
        c+='}\n'
        app.uExampleCode=c
        init()
    }

    Shortcut{
        sequence: 'Ctrl+d'
        onActivated: {
            apps.dev=!apps.dev
        }
    }
    Shortcut{
        sequence: 'Ctrl+i'
        onActivated: {
            unik.setFile(apps.mainFolder+'/log', app.uLogData)
            app.uLogData=''
            init()
        }
    }
    Shortcut{
        sequence: 'Ctrl+R'
        onActivated: {
            unik.setFile(apps.mainFolder+'/log', app.uLogData)
            unik.restartApp()
        }
    }
    Shortcut{
        sequence: 'Esc'
        onActivated: {
            if(zipManager.uStdOut!=='Cancelado.'){
                zipManager.cancelar()
                zipManager.uStdOut='Cancelado.'
            }else{
                Qt.quit()
            }
        }
    }
    Shortcut{
        sequence: 'Enter'
        onActivated: runReturnOrEnter(false)
    }
    Shortcut{
        sequence: 'Return'
        onActivated: runReturnOrEnter(false)
    }
    Shortcut{
        sequence: 'Ctrl+Enter'
        onActivated: runReturnOrEnter(true)
    }
    Shortcut{
        sequence: 'Ctrl+Return'
        onActivated: runReturnOrEnter(true)
    }
    function runReturnOrEnter(ctrl){
        if(!ctrl){
            runMix('probe')
        }else{
            runMix('install')
        }
    }
    function runMix(tipo){
        if(tipo==='probe'){
            if(apps.enableCheckBoxShowGitRep){
                zipManager.mkUqpRepVersion(tiGitRep.text, 'probe')
            }else{
                unik.log('Probando ['+tiFolder.text+']...')
                if(unik.folderExist(tiFolder.text)){
                    unik.log('Revisando la carpeta ['+tiFolder.text+']...')
                    if(!unik.fileExist(tiFolder.text+'/main.qml')){
                        unik.log('Error! La carpeta ['+tiFolder.text+'] no contiene un archivo [main.qml].')
                        return
                    }else{
                        unik.log('Existe un archivo ['+tiFolder.text+'/main.qml]...')
                        let c=unik.getFile(tiFolder.text+'/main.qml')
                        unik.log('Código QML: '+c+'')
                    }
                    apps.uFolder=tiFolder.text
                    var cmd=unik.getPath(0)+' -nocfg -folder='+tiFolder.text
                    if(checkBoxRunOut.checked){
                        unik.log('Lanzando aparte ['+cmd+']')
                        unik.runOut(cmd)
                        if(!apps.dev){
                            app.close()
                        }else{
                            unik.log('Esta instancia de '+presetAppName+' no se ha cerrado porque estamos en modo desarrollador. Se ejecutó runOut("'+cmd+'")')
                        }
                    }else{
                        unik.run(cmd)
                        if(!apps.dev){
                            app.close()
                        }else{
                            unik.log('Esta instancia de '+presetAppName+' no se ha cerrado porque estamos en modo desarrollador. Se ejecutó runOut("'+cmd+'")')
                        }
                    }
                }else{
                    unik.log('Error! La carpeta ['+tiFolder.text+'] no existe!.')
                }
            }
        }else{
            if(apps.enableCheckBoxShowGitRep){
                zipManager.mkUqpRepVersion(tiGitRep.text, 'install')
            }else{
                unik.log('Probando ['+tiFolder.text+']...')
                if(unik.folderExist(tiFolder.text)){
                    unik.log('Revisando la carpeta ['+tiFolder.text+']...')
                    if(!unik.fileExist(tiFolder.text+'/main.qml')){
                        unik.log('Error! La carpeta ['+tiFolder.text+'] no contiene un archivo [main.qml].')
                        return
                    }else{
                        unik.log('Existe un archivo ['+tiFolder.text+'/main.qml]...')
                        let c=unik.getFile(tiFolder.text+'/main.qml')
                        unik.log('Código QML: '+c+'')
                    }
                    let j={}
                    j.args={}
                    j.args['folder']=tiFolder.text
                    let aname=(''+presetAppName).toLowerCase()
                    unik.setFile(apps.mainFolder+'/'+aname+'.cfg', JSON.stringify(j, null, 2))
                    apps.uFolder=tiFolder.text
                    mkAd(unik.getPath(0), '-folder='+tiFolder.text, apps.mainFolder)
                    let cmd=unik.getPath(0)
                    if(checkBoxRunOut.checked){
                        unik.log('Lanzando aparte ['+cmd+']')
                        unik.runOut(cmd)
                    }else{
                        unik.run(cmd)
                    }
                    if(!apps.dev){
                        app.close()
                    }else{
                        unik.log('Esta instancia de '+presetAppName+' no se ha cerrado porque estamos en modo desarrollador. Se ejecutó runOut("'+cmd+'")')
                    }
                }else{
                    unik.log('Error! La carpeta ['+tiFolder.text+'] no existe!.')
                }
            }
        }
    }
    function getCtx(){
        let ret=''
        let count=getArgsUnikeyCount()
        unik.log('Cantidad de argumentos UniKey: '+count)
        let argIndexFolder=getArgsIndex(Qt.application.arguments, 'folder')
        let argIndexUGit=getArgsIndex(Qt.application.arguments, 'ugit')
        let argIndexGit=getArgsIndex(Qt.application.arguments, 'git')
        let argIndexNoCfg=getArgsIndex(Qt.application.arguments, 'nocfg')
        if(argIndexFolder>=0 && count===1){
            ret='folder'
        }
        if(argIndexUGit>=0 && count===1){
            ret='ugit'
        }
        if(argIndexGit>=0 && count===1){
            ret='git'
        }
        if(argIndexNoCfg>=0 && count===1){
            ret='nocfg'
        }
        if(argIndexFolder>=0 && argIndexGit>=0 && count===2){
            ret='git-folder'
        }
        if(argIndexFolder>=0 && argIndexNoCfg>=0 && count===2){
            ret='nocfg-folder'
        }
        if(argIndexGit>=0 && argIndexNoCfg>=0 && count===2){
            ret='nocfg-git'
        }
        if(argIndexFolder>=0 && argIndexGit>=0 && argIndexNoCfg>=0 && count===3){
            ret='nocfg-git-folder'
        }
        if(ret===''){
            let aname=(''+presetAppName).toLowerCase()
            unik.log('apps.mainFolder: '+apps.mainFolder)
            let nCfgFilePath='"'+apps.mainFolder+'/'+aname+'.cfg"'
            let js=unik.getFile(nCfgFilePath).replace(/\n/g, '')
            if(js==='error'){
                js=unik.getFile(nCfgFilePath.replace(/\"/g, '')).replace(/\n/g, '')
            }
            unik.log('js: '+js)
            let j=JSON.parse(js)
            if(j.args['ugit']){
                ret='cfg-ugit'
            }else if(j.args['runFromGit']){
                ret='cfg-git'
            }else{
                if(j.args['runFromFolder']!==""){
                    ret='cfg-folder'
                }
            }


        }
        return ret
    }
    function getArgsUnikeyCount(){
        let count=0
        let a=['folder', 'git', 'nocfg', 'ugit']
        for(var i=0;i<a.length;i++){
            for(var i2=0;i2<Qt.application.arguments.length;i2++){
                //unik.log('-->'+Qt.application.arguments[i2])
                if((''+Qt.application.arguments[i2])===''+a[i] || (''+Qt.application.arguments[i2]).indexOf('-'+a[i])===0){
                    count++
                }
            }
        }
        return count
    }
    function init(){
        //unik.log('Folder AppData: '+apps.mainFolder)
        let argsFinal=[]
        cp = unik.currentFolderPath()
        let fp=cp+'/main.qml'
        unik.log('Parámetros recibidos: '+Qt.application.arguments.toString())
        unik.log('Carpeta actual: '+cp)

        let m0

        let argIndexNoCfg=getArgsIndex(Qt.application.arguments, 'nocfg')
        if(apps.dev)unik.log('argIndexNoCfg: '+argIndexNoCfg)
        //log.text='aaa: '+argIndexNoCfg

        if(argIndexNoCfg<0){ //Carga CFG
            let cAppData=apps.mainFolder
            unik.log('Carpeta de datos: '+cAppData)
            let j
            let cfgSeted=false
            let aname=(''+presetAppName).toLowerCase()
            if(unik.fileExist(cAppData+'/'+aname+'.cfg')){
                unik.log('Procesando archivo de configuración de '+presetAppName+'...')
                let jsonString = unik.getFile(cAppData+'/'+aname+'.cfg').replace(/\n/g, '')
                try {
                    j = JSON.parse(jsonString);
                    let aname=(''+presetAppName).toLowerCase()
                    unik.log('Iniciando con configuración de '+aname+'.cfg:\n'+JSON.stringify(j, null, 2))
                    //unik.log('Iniciando con configuración de '+aname+'.cfg:\n'+JSON.stringify(j.args, null, 2))
                    if(j.args && j.args['git']){
                        argsFinal.push('-git='+j.args['git'])
                    }else{
                        if(j.args && j.args['folder']){
                            argsFinal.push('-folder='+j.args['folder'])
                        }
                    }
                    cfgSeted=true
                } catch (error) {
                    let aname=(''+presetAppName).toLowerCase()
                    unik.log('Falló la carga de '+aname+'.cfg:\n'+jsonString)
                    console.error("Error! Hay un error en el archivo de configuración "+cAppData+'/'+aname+'.cfg', error);
                }
            }

        }else{
            let aname=(''+presetAppName).toLowerCase()
            unik.log('Se omite la revisión del archivo '+aname+'.cfg...')
        }

        if(argsFinal.length===0){
            app.appArgs=Qt.application.arguments
        }else{
            app.appArgs=argsFinal
        }



        let argIndexGit=getArgsIndex(app.appArgs, 'git')
        let argIndexFolder=getArgsIndex(app.appArgs, 'folder')
        if(argIndexFolder>=0){
            let a=app.appArgs[argIndexFolder]
            unik.log('Ejecutando '+presetAppName+' con el argumento '+a)
            let m0=a.split('=')
            unik.log('Chequeando si existe la carpeta '+m0[1])
            if(unik.folderExist(m0[1])){
                unik.log('Ingresando a la carpeta '+m0[1])
                unik.cd(m0[1])
                unik.addImportPath(m0[1]+'/modules')
                unik.log('Carpeta actual: '+unik.currentFolderPath())
                cp=m0[1]
                fp=cp+'/main.qml'
                engine.load(fp)
                return
            }else{
                unik.log('Error!\nEl argumento '+a+' no se podrá procesar porque la carpeta '+m0[1]+' no existe!')
                unik.log('Se continúa en la carpeta actual: '+unik.currentFolderPath())
                app.visibility="Maximized"
            }
        }
        if(argIndexGit>=0 && apps.runFromGit){
            let a=app.appArgs[argIndexGit]
            unik.log('Ejecutando '+presetAppName+' con el argumento '+a)
            m0=a.split('=')
            unik.log('Ejecutando auto actualización...')
            unik.log('Última carpeta de archivos: '+apps.uFolder)
            apps.uGitRep=m0[1]
            tiGitRep.text=apps.uGitRep
            unik.log('Descargando '+m0[1]+'...')
            app.visible=true
            app.visibility="Maximized"

            zipManager.mkUqpRepVersion(tiGitRep.text, 'probe')
        }else if(argIndexGit>=0 && !apps.runFromGit){
            let a=app.appArgs[argIndexGit]
            unik.log('Cargando url git desde configuración...')
            apps.enableCheckBoxShowGitRep=true
            m0=a.split('=')
            //unik.log('Ejecutando auto actualización...')
            apps.uGitRep=m0[1]
            tiGitRep.text=apps.uGitRep
            unik.log('Descargando '+m0[1]+'...')
            app.visible=true
            app.visibility="Maximized"
            //zipManager.mkUqpRepVersion(tiGitRep.text, 'probe')
        }else{
            if(argIndexFolder>=0){
                let a=app.appArgs[argIndexFolder]
                //unik.log('Ejecutando Unikey con el argumento '+a)
                m0=a.split('=')
                unik.log('El repositorio git se descargará en la carpeta '+m0[1])
                if(unik.folderExist(m0[1])){
                    unik.log('Ingresando a la carpeta '+m0[1])
                    unik.cd(m0[1])
                    unik.addImportPath(m0[1]+'/modules')
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
                unik.setProperty("documentsPath", unik.getPath(3))
                unik.addImportPath(cp+'/modules')
                console.log('Cargando fp: '+fp)
                app.enableQmlErrorLog=false

                if(Qt.platform.os==='linux'){
                    unik.addImportPath(fp+'/modules')
                    engine.load(fp)
                }else{
                    unik.runOut('"'+unik.getPath(0)+'" -folder="'+fp+'"')
                }
                if(!apps.dep){
                    app.close()
                }else{
                    apps.dev=true
                }
            }
        }else{
            unik.log('Esta carpeta ['+fp.replace('/main.qml', '')+'] NO contiene un archivo main.qml')
            unik.log('Es posible que estes viendo estos mensajes porque no tienes un archivo main.qml en esta carpeta.<br><br>El archivo main.qml es necesario para que '+presetAppName+' inicie una aplicación del tipo QtQuick.')
            if(!checkBoxShowGitRep.checked)botCrearMainQmlDeEjemplo.visible=true
            app.visibility="Maximized"
        }
    }
    function getArgsIndex(args, arg){
        //let args=app.appArgs
        let ret=-1
        for(var i=0;i<args.length;i++){
            let a=args[i]
            if(a.indexOf('-'+arg+'=')>=0 || a.indexOf('-'+arg+'')>=0){
                ret=i
                break
            }
        }
        return ret
    }
    function getCodeloadZipUrl(githubUrl) {
        // 1. Extraer el nombre de usuario y el nombre del repositorio
        const parts = githubUrl.split("/");
        const username = parts[3];
        const repoName = parts[4];

        // 2. Obtener el timestamp actual
        const d = new Date(Date.now())
        const timestamp = d.getTime();

        // 3. Construir la URL de codeload con el timestamp
        const codeloadUrl = `https://codeload.github.com/${username}/${repoName}/zip/main?r=${timestamp}`;

        return codeloadUrl;
    }

    function runProbe(){
        apps.uGitRep=tiGitRep.text
        //zipManager.version='prueba'
        zipManager.isProbe=true
        zipManager.resetApp=true
        zipManager.setCfg=false
        //zipManager.launch=false
        zipManager.download(tiGitRep.text)
    }
    function runInstall(){
        apps.uGitRep=tiGitRep.text
        //zipManager.version='install'
        zipManager.isProbe=false
        zipManager.resetApp=true
        zipManager.setCfg=true
        //zipManager.launch=false
        zipManager.download(tiGitRep.text)
    }

    function getAdCode(exePath, args, wd){
        let m0=exePath.split('/')
        let argsName=args.replace(/-/g, '_').replace(/\//g, '_').replace(/\=/g, '')
        let fileName=''+m0[m0.length-1]+'_'+argsName//+'.lnk'
        let c=''
        if(Qt.platform.os==='windows'){
            c='Const TARGET_PATH = "'+exePath+'"
            Const ARGUMENTS = "'+args+'"
            Const SHORTCUT_PATH = "%USERPROFILE%\Desktop\\'+fileName+'.lnk"
            Const DESCRIPTION = "Acceso directo a Zool con configuración deshabilitada"
            Const WORKING_DIRECTORY = "'+wd+'\"
            Const ICON_PATH = "'+exePath+'"

            Set WshShell = WScript.CreateObject("WScript.Shell")

            Dim strShortcutPath
            strShortcutPath = WshShell.ExpandEnvironmentStrings(SHORTCUT_PATH)

            Set oShellLink = WshShell.CreateShortcut(strShortcutPath)

            oShellLink.TargetPath = TARGET_PATH
            oShellLink.Arguments = ARGUMENTS
            oShellLink.Description = DESCRIPTION
            oShellLink.WorkingDirectory = WORKING_DIRECTORY
            oShellLink.IconLocation = ICON_PATH

            oShellLink.Save

            WScript.Echo "Acceso directo \''+fileName+'\' creado en " & strShortcutPath & " con el parámetro " & ARGUMENTS & "."

            Set oShellLink = Nothing
            Set WshShell = Nothing'
        }else{
            c='#!/usr/bin/env xdg-open
[Desktop Entry]
Encoding=UTF-8
Name='+fileName+'
Comment=Creado por '+presetAppName+'
Exec='+exePath+' '+args+'
Icon='+unik.getPath(1)+'/logo.png
Categories=Application
Type=Application
Terminal=false'
        }

        return c
    }
    function mkAd(exePath, args, wd){
        let m0=exePath.split('/')
        let argsName=args.replace(/-/g, '_').replace(/\//g, '_').replace(/\=/g, '_')
        let fileName=''+m0[m0.length-1]+'_'+argsName//+'.lnk'
        let c=getAdCode(exePath, args, wd)
        if(Qt.platform.os==='linux'){
            let desktopIconFilePath=unik.getPath(6)+'/'+fileName+'.desktop'
            unik.log('Creando acceso directo en el Escritorio: '+desktopIconFilePath)
            unik.setFile(desktopIconFilePath, c)
        }else{
            unik.setFile(unik.getPath(2)+'/'+fileName+'.vbs', c)
            c=''

            c=''
            let onCompleteCode=c

            c='uqpRepExist'
            let idName=c


            c='wscript "'+unik.getPath(2)+'/'+fileName+'.vbs"'
            let cmd=c

            c='        unik.log(logData)\n'
            let onLogDataCode=c


            c='        //Nada\n'
            let onFinishedCode=c


            let cf=zipManager.getUqpCode(idName, cmd, onLogDataCode, onFinishedCode, onCompleteCode)

            if(app.dev)unik.log('cf '+idName+': '+cf)

            let comp=Qt.createQmlObject(cf, zipManager.uqpsContainer, 'uqp-code-'+idName)
        }

    }
    //Procesar Response Repository Version
    function procRRV(res, url, tipo){
        //unik.log('onResponseRepVersion res: '+res)
        //unik.log('onResponseRepVersion url: '+url)
        //unik.log('onResponseRepVersion tipo: '+tipo)
        let nCtx=''
        let nRes=res.replace('\n', '')
        let version=''
        if(tipo==='probe'){
            version='prueba'
            if(nRes.split('.').length>=3){
                nCtx=nRes+'_'+url+'_'+tipo
                apps.uCtxUpdate=nCtx
                version='probe_'+nRes
                unik.log('El repositorio '+tiGitRep.text+' tiene disponible la versión '+nRes)
            }else{
                unik.log('El repositorio '+tiGitRep.text+' NO tiene un archivo "version" disponible.')
            }
            zipManager.version=version
            runProbe()
        }else{
            //Instalando...
            version=tipo
            if(nRes.split('.').length>=3){
                //Existe un dato de version
                nCtx=nRes+'_'+url+'_'+tipo
                unik.log('El repositorio '+tiGitRep.text+' tiene disponible la versión '+nRes)
                //Check si el nuevo contexto es igual al anterior
                if(apps.uCtxUpdate===nCtx){
                    //Estamos en un contexto similar al anterior
                    unik.log('No se puede instalar este repositorio '+url+' porque ya está instalada la versión '+nRes)

                    //Check si existe carpeta del contexto similar
                    //Si la carpeta no existe se reinstalará el mismo contexto
                    let lastVersionInstaled='0.0.0.0'
                    if(apps.uCtxUpdate.indexOf(url)>=0 && apps.uCtxUpdate.indexOf('_')>=0){
                        let m100=apps.uCtxUpdate.split(url)
                        lastVersionInstaled=m100[0]
                        unik.log('La última versión de este repositorio '+url+' instalada fué '+lastVersionInstaled)
                        //Check si la última version instalada es diferente a la última disponible
                        var m101=url.replace('/main/version').split('/')
                        var repName=m101[m101.length-1]
                        var fullFolderToInstall=apps.mainFolder+'/'+repName+'_'+nRes
                        var fullFolderToInstall2=apps.mainFolder+'/'+repName+'_'+nRes+'/'+repName+'-main'
                        var fullFileMainToInstall=apps.mainFolder+'/'+repName+'_'+nRes+'/'+repName+'-main/main.qml'
                        var fullFileVersionInstalled='"'+apps.mainFolder+'/'+repName+'_'+nRes+'/'+repName+'-main/version"'
                        var fullFileVersionInstalledData=unik.getFile(fullFileVersionInstalled).replace(/\n/g, '')
                        if( lastVersionInstaled===nRes || fullFileVersionInstalledData===nRes){
                            //La última version instalada es igual
                            //Se procede a ejecutar por carpeta



                            if(unik.folderExist(fullFolderToInstall) && unik.folderExist(fullFolderToInstall2) && unik.fileExist(fullFileMainToInstall)){
                                if(app.ctx==='ugit' || app.ctx==='cfg-ugit' ){
                                    let uGitCmd='"'+unik.getPath(0)+'" -folder='+fullFolderToInstall2
                                    unik.log('uGitCmd: '+uGitCmd)
                                    unik.runOut(uGitCmd)
                                }else{
                                    unik.runOut(unik.getPath(0)+' -nocfg -folder='+fullFolderToInstall2)
                                    if(!apps.dev){
                                        app.close()
                                    }else{
                                        unik.log('Esta instancia de '+presetAppName+' no se ha cerrado porque estamos en modo desarrollador. Se ejecutó runOut("'+cmd+'")')
                                    }
                                }
                                return
                            }
                        }else{
                            //La última version instalada NO es igual
                            //Se continua hacia runInstall()                                    }

                        }
                    }
                }else{
                    //Estamos en un nuevo contexto
                    version=nRes
                    apps.uCtxUpdate=nCtx
                }
            }else{
                //Repositorio sin version
                unik.log('El repositorio '+tiGitRep.text+' NO tiene un archivo "version" disponible.')
                if(app.ctx==='ugit'){
                    unik.log('Contexto ugit: No hay un archivo de version. version: '+version)

                    return
                }
            }

            zipManager.version=version
            runInstall()
        }

    }
    function restoreDefaultCfg(cfgDefaultPath){
        /*
            EJEMPLO DE JSON POR DEFECTO
            {
                "args":{
                    "mainFolder": "/home/ns"
                    "git":"https://github.com/nextsigner/qml-pacman",
                    "dev": false,
                    "dep": false,
                    "runFromGit": true,
                    "runFromFolder": "zool"
                }
            }
            */
        let aname=(''+presetAppName).toLowerCase()
        let nCfgFilePath=apps.mainFolder+'/'+aname+'.cfg'
        let defaultCfgPath='"'+unik.getPath(1)+'/default.cfg"'
        unik.log('Cargando configuración por defecto desde: '+defaultCfgPath)
        let js=unik.getFile(defaultCfgPath).replace(/\n/g, '')
        if(js==='error'){
            js=unik.getFile(defaultCfgPath.replace(/\"/g, '')).replace(/\n/g, '')
        }
        unik.log(''+js)
        unik.log('Buscando '+defaultCfgPath)
        if(unik.fileExist(defaultCfgPath)){


            let j=JSON.parse(js)
            unik.log('Configuración por defecto: '+JSON.stringify(j, null, 2))

            if(j.args['dev'])apps.dev=j.args['dev']
            if(j.args['runFromGit'])apps.runFromGit=j.args['runFromGit']
            if(j.args['runFromFolder'])apps.runFromFolder=j.args['runFromFolder']
            if(j.args['dep'])apps.runOut=j.args['dep']
            if(j.args['mainFolder'])apps.mainFolder=j.args['mainFolder']

            unik.log('Definiendo configuración por defecto: '+nCfgFilePath)
            unik.setFile(nCfgFilePath, JSON.stringify(j, null, 2))
        }else{
            unik.log('Configuración por defecto no existe!: '+defaultCfgPath)
            let j={}
            j.args={}
            j.args['mainFolder']=unik.getPath(4)
            j.args['git']="https://github.com/nextsigner/unikey-apps"
            j.args['dev']=false
            j.args['runFromGit']=true
            j.args['runFromFolder']=""
            j.args['dep']=false
            let jsData=JSON.stringify(j, null, 2)
            unik.setFile(nCfgFilePath, jsData)
            unik.setFile(defaultCfgPath, jsData)

            apps.uGitRep="https://github.com/nextsigner/unikey-apps"
            apps.dev=false
            apps.runFromGit=true
            apps.runFromFolder=""
            apps.runOut=false
        }

    }

    //Aprobado en GNU/Linux
    function runCtxCfgUGit(){
        apps.dev=false
        app.visibility="Maximized"
        let aname=(''+presetAppName).toLowerCase()
        let nCfgFilePath=apps.mainFolder+'/'+aname+'.cfg'
        let js=unik.getFile(nCfgFilePath).replace(/\n/g, '')
        if(js==='error'){
            js=unik.getFile(nCfgFilePath.replace(/\"/g, '')).replace(/\n/g, '')
        }
        //unik.log('js: '+js)
        let j=JSON.parse(js)
        if(j.args['dev']){
            apps.dev=j.args['dev']
        }else{
            apps.dev=false
        }
        apps.uGitRep=j.args['ugit']
        //unik.log('runCtxCfgUGit() url: '+apps.uGitRep)
        zipManager.mkUqpRepVersion(j.args['ugit'], 'updated')
    }
    //Aprobado en GNU/Linux
    function runCtxCfgGit(){
        apps.dev=false
        app.visibility="Maximized"
        let aname=(''+presetAppName).toLowerCase()
        let nCfgFilePath=apps.mainFolder+'/'+aname+'.cfg'
        let js=unik.getFile(nCfgFilePath).replace(/\n/g, '')
        if(js==='error'){
            js=unik.getFile(nCfgFilePath.replace(/\"/g, '')).replace(/\n/g, '')
        }
        //unik.log('js: '+js)
        let j=JSON.parse(js)

        apps.uGitRep=j.args['git']
        zipManager.isProbe=false
        zipManager.resetApp=true
        zipManager.setCfg=false
        zipManager.download(j.args['git'])


    }
    //Aprobado en GNU/Linux
    function runCtxCfgFolder(){
        let aname=(''+presetAppName).toLowerCase()
        let nCfgFilePath=apps.mainFolder+'/'+aname+'.cfg'
        let js=unik.getFile(nCfgFilePath).replace(/\n/g, '')
        if(js==='error'){
            js=unik.getFile(nCfgFilePath.replace(/\"/g, '')).replace(/\n/g, '')
        }
        unik.log('js: '+js)
        let j=JSON.parse(js)
        let folder=j.args['folder']
        if(unik.folderExist(folder) && unik.fileExist(folder+'/main.qml')){
            unik.addImportPath(folder+'/modules')
            unik.cd(folder)
            unik.log('Cargando: '+''+folder+'/main.qml')
            unik.runOut('"'+unik.getPath(0)+'" -folder='+folder)
            //engine.load(folder+'/main.qml')

        }
    }
    //Aprobado en GNU/Linux
    function runCtxUGit(){
        apps.dev=false
        app.visibility='Maximized'
        let urlGit=''
        let args=Qt.application.arguments
        for(var i=0;i<args.length;i++){
            if(args[i].indexOf('-ugit=')>=0){
                let m0=args[i].split('-ugit=')
                urlGit=m0[1]
            }
            if(args[i].indexOf('-dev=')>=0){
                apps.dev=true
            }
        }
        apps.uGitRep=urlGit
        zipManager.mkUqpRepVersion(urlGit, 'updated')
    }
    //Aprobado en GNU/Linux
    function runCtxGit(){
        apps.dev=false
        app.visibility="Maximized"
        let urlGit=''
        let args=Qt.application.arguments
        for(var i=0;i<args.length;i++){
            if(args[i].indexOf('-git=')>=0){
                let m0=args[i].split('-git=')
                urlGit=m0[1]
            }
        }
        apps.uGitRep=urlGit
        zipManager.isProbe=false
        zipManager.resetApp=true
        zipManager.setCfg=false
        zipManager.download(urlGit)


    }
    //Aprobado en GNU/Linux
    function runCtxFolder(){
        let folder=''
        let args=Qt.application.arguments
        for(var i=0;i<args.length;i++){
            if(args[i].indexOf('-folder=')>=0){
                let m0=args[i].split('-folder=')
                folder=m0[1]
            }
        }
        if(unik.folderExist(folder) && unik.fileExist(folder+'/main.qml')){
            if(Qt.platform.os==='linux'){
                unik.addImportPath(folder+'/modules')
                unik.cd(folder)
                unik.log('Cargando: '+''+folder+'/main.qml')
                engine.load(folder+'/main.qml')
            }else{
                unik.runOut('"'+unik.getPath(0)+'" -folder="'+folder+'"')
            }
            if(!apps.dep){
                app.close()
            }else{
                apps.dev=true
            }

        }
    }
}
