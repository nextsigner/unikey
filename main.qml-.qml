import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.1
import unik.Unik 1.0
import ZipManager 1.0

Window {
    id: app
    visible: false
    //visibility: "Maximized"
    width: 640
    height: 480
    title: presetAppName
    color: c1

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
        fileName: unik?unik.getPath(4)+'/'+(''+presetAppName).toLowerCase()+'_app.cfg':''
        property bool dev: false
        property bool runFromGit: false
        property string runFromFolder: ''
        property bool runOut: true
        property string uGitRep: 'https://github.com/nextsigner/unikey-demo'
        property string uFolder: unik.getPath(3)
        property bool enableCheckBoxShowGitRep: false
        property color fontColor: 'white'
        property color backgroundColor: 'black'
        property string uCtxUpdate: ''
    }
    Unik{
        id: unik
        onUkStdChanged:{
            log.text+=''+unik.ukStd+'<br>'
        }
    }
    //    Connections{
    //        target: unik
    //        onUkStdChanged:{
    //            log.text+=''+unik.ukStd+'<br>'
    //        }
    //    }
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
                        Text{
                            id: log
                            color: app.c2
                            width: col.width-app.fs
                            //height: app.fs*6
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                            font.pixelSize: app.fs
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
                            log.lv('Creando el archivo main.qml en la carpeta ['+cp+']')
                            if(!unik.fileExist(fp)){
                                unik.setFile(fp, app.uExampleCode)
                                if(unik.fileExist(fp)){
                                    log.lv('El archivo '+fp+' se ha creado correctamente.')
                                    botLanzarQml.visible=true
                                    botDeleteQmlFileExample.visible=true
                                    botCrearMainQmlDeEjemplo.visible=false
                                }else{
                                    log.lv('El archivo '+fp+' NO se ha creado correctamente.')
                                }
                            }else{
                                log.lv('El archivo '+fp+' ya existe!<br>No se ha creado nuevamente.')
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
                            unik.setProperty("documentsPath", unik.getPath(3))
                            unik.addImportPath(cp+'/modules')
                            engine.load(fp)
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
                                    log.lv('El archivo '+fp+' de ejemplo ha sido eliminado.')
                                    botLanzarQml.visible=false
                                    botDeleteQmlFileExample.visible=false
                                    if(!checkBoxShowGitRep.checked)botCrearMainQmlDeEjemplo.visible=true
                                }else{
                                    log.lv('Ha ocurrido un problema. Se intentó borrar el archivo de ejemplo '+fp+' sin éxito.')
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
                                if(zipManager.curlPath!=='' && zipManager.app7ZipPath !==''){
                                    zipManager.mkUqpRepExist(text)
                                }
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
                                    log.lv('La carpeta ['+text+'] no existe.')
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
                        onLog: log.lv(data)
                        onDownloadFinished: {
                            //Retorna: downloadFinished(string url, string folderPath, string zipFileName)
                            log.lv('Se descargó: '+zipFileName)
                            log.lv('Origen: '+url)
                            log.lv('Destino: '+folderPath)
                        }
                        onUnzipFinished: {
                            //Retorna: unzipFinished(string url, string folderPath, string zipFileName)
                        }
                        onResponseRepExist:{
                            if(res.indexOf('404')>=0){
                                tiGitRep.color='red'
                                log.lv('El repositorio ['+url+'] no existe.')
                            }else{
                                tiGitRep.color=apps.fontColor
                                log.lv('El repositorio ['+url+'] está disponible en internet.')
                                log.lv('Para probarlo presiona ENTER')
                                log.lv('Para instalarlo presiona Ctrl+ENTER')
                            }
                        }
                        onResponseRepVersion:{
                            procRRV(res, url, tipo)
                        }
                        //                        onResponseRepExist:{
                        //                            if(res.indexOf('404')>=0){
                        //                                tiGitRep.color='red'
                        //                                log.lv('El repositorio ['+url+'] no existe.')
                        //                            }else{
                        //                                tiGitRep.color=apps.fontColor
                        //                                log.lv('El repositorio ['+url+'] está disponible en internet.')
                        //                                log.lv('Para probarlo presiona ENTER')
                        //                                log.lv('Para instalarlo presiona Ctrl+ENTER')
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
                            unik.deleteFile(unik.getPath(4)+'/'+aname+'.cfg')
                            log.lv('Archivo de configuración eliminado.')
                        }
                    }
                    Button{
                        text: 'Reiniciar cargando configuración'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            unik.setFile(unik.getPath(4)+'/log', app.uLogData)
                            unik.restartApp()
                        }
                    }
                    Button{
                        text: 'Reiniciar sin cargar configuración'
                        font.pixelSize: app.botFs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            unik.setFile(unik.getPath(4)+'/log', app.uLogData)
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
        log.lv('Curl Path: '+zipManager.curlPath)
        zipManager.app7ZipPath = Qt.platform.os==='windows'?'"'+unik.getPath(1).replace(/\"/g, '')+'/7-Zip32/7z.exe"':'7z'
        log.lv('7z Path: '+zipManager.app7ZipPath)
        zipManager.uFolder = apps.runFromFolder!==""?'"'+apps.runFromFolder.replace(/\"/g, '')+'"':'"'+unik.getPath(3)+'"'
//        while(!unik){
//            log.text+='.'
//        }
        let aname=(''+presetAppName).toLowerCase()
        var cfgDefaultPath='"'+unik.getPath(4).replace(/\"/g, '')+'/'+aname+'.cfg"'
        if(!unik.fileExist(cfgDefaultPath)){
            restoreDefaultCfg(cfgDefaultPath)
            log.lv('Se ha restaurado la configuración por defecto: '+cfgDefaultPath)
        }

        if(apps.runFromFolder!==""){
            if(unik.folderExist(unik.getPath(4)+'/'+apps.runFromFolder) && unik.fileExist(unik.getPath(4)+'/'+apps.runFromFolder+'/main.qml')){
                unik.addImportPath(unik.getPath(4)+'/'+apps.runFromFolder+'/modules')
                unik.cd(unik.getPath(4)+'/'+apps.runFromFolder)
                engine.load('"'+unik.getPath(4)+'/'+apps.runFromFolder+'/main.qml"')
                return
            }
            log.lv('Procesando...')
        }


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
            unik.setFile(unik.getPath(4)+'/log', app.uLogData)
            app.uLogData=''
            init()
        }
    }
    Shortcut{
        sequence: 'Ctrl+R'
        onActivated: {
            unik.setFile(unik.getPath(4)+'/log', app.uLogData)
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
        log.lv('runMix('+tipo+')...')
        if(tipo==='probe'){
            if(apps.enableCheckBoxShowGitRep){
                zipManager.mkUqpRepVersion(tiGitRep.text, 'probe')
            }else{
                log.lv('Probando ['+tiFolder.text+']...')
                if(unik.folderExist(tiFolder.text)){
                    log.lv('Revisando la carpeta ['+tiFolder.text+']...')
                    if(!unik.fileExist(tiFolder.text+'/main.qml')){
                        log.lv('Error! La carpeta ['+tiFolder.text+'] no contiene un archivo [main.qml].')
                        return
                    }else{
                        log.lv('Existe un archivo ['+tiFolder.text+'/main.qml]...')
                        let c=unik.getFile(tiFolder.text+'/main.qml')
                        log.lv('Código QML: '+c+'')
                    }
                    apps.uFolder=tiFolder.text
                    var cmd=unik.getPath(0)+' -nocfg -folder='+tiFolder.text
                    if(checkBoxRunOut.checked){
                        log.lv('Lanzando aparte ['+cmd+']')
                        unik.runOut(cmd)
                        if(!apps.dev){
                            app.close()
                        }else{
                            log.lv('Esta instancia de '+presetAppName+' no se ha cerrado porque estamos en modo desarrollador. Se ejecutó runOut("'+cmd+'")')
                        }
                    }else{
                        unik.run(cmd)
                        if(!apps.dev){
                            app.close()
                        }else{
                            log.lv('Esta instancia de '+presetAppName+' no se ha cerrado porque estamos en modo desarrollador. Se ejecutó runOut("'+cmd+'")')
                        }
                    }
                }else{
                    log.lv('Error! La carpeta ['+tiFolder.text+'] no existe!.')
                }
            }
        }else{
            if(apps.enableCheckBoxShowGitRep){
                zipManager.mkUqpRepVersion(tiGitRep.text, 'install')
            }else{
                log.lv('Probando ['+tiFolder.text+']...')
                if(unik.folderExist(tiFolder.text)){
                    log.lv('Revisando la carpeta ['+tiFolder.text+']...')
                    if(!unik.fileExist(tiFolder.text+'/main.qml')){
                        log.lv('Error! La carpeta ['+tiFolder.text+'] no contiene un archivo [main.qml].')
                        return
                    }else{
                        log.lv('Existe un archivo ['+tiFolder.text+'/main.qml]...')
                        let c=unik.getFile(tiFolder.text+'/main.qml')
                        log.lv('Código QML: '+c+'')
                    }
                    let j={}
                    j.args={}
                    j.args['folder']=tiFolder.text
                    let aname=(''+presetAppName).toLowerCase()
                    unik.setFile(unik.getPath(4)+'/'+aname+'.cfg', JSON.stringify(j, null, 2))
                    apps.uFolder=tiFolder.text
                    mkAd(unik.getPath(0), '-folder='+tiFolder.text, unik.getPath(4))
                    let cmd=unik.getPath(0)
                    if(checkBoxRunOut.checked){
                        log.lv('Lanzando aparte ['+cmd+']')
                        unik.runOut(cmd)
                    }else{
                        unik.run(cmd)
                    }
                    if(!apps.dev){
                        app.close()
                    }else{
                        log.lv('Esta instancia de '+presetAppName+' no se ha cerrado porque estamos en modo desarrollador. Se ejecutó runOut("'+cmd+'")')
                    }
                }else{
                    log.lv('Error! La carpeta ['+tiFolder.text+'] no existe!.')
                }
            }
        }
    }
    function init(){
        //log.lv('Folder AppData: '+unik.getPath(4))
        let argsFinal=[]
        cp = unik.currentFolderPath()
        let fp='"'+cp+'/main.qml"'
        log.lv('Parámetros recibidos: '+Qt.application.arguments.toString())
        log.lv('Carpeta actual: '+cp)

        let m0

        let argIndexNoCfg=getArgsIndex(Qt.application.arguments, 'nocfg')
        if(apps.dev)log.lv('argIndexNoCfg: '+argIndexNoCfg)
        //log.text='aaa: '+argIndexNoCfg

        if(argIndexNoCfg<0){
            let cAppData=unik.getPath(4)
            log.lv('Carpeta de datos: '+cAppData)
            let j
            let cfgSeted=false
            var aname=(''+presetAppName).toLowerCase()
            if(unik.fileExist('"'+cAppData+'/'+aname+'.cfg"')){
                log.lv('Procesando archivo de configuración de '+presetAppName+'...')
                let jsonString = unik.getFile('"'+cAppData+'/'+aname+'.cfg"').replace(/\n/g, '')
                try {
                    j = JSON.parse(jsonString);
                    let aname=(''+presetAppName).toLowerCase()
                    log.lv('Iniciando con configuración de '+aname+'.cfg:\n'+JSON.stringify(j, null, 2))
                    //log.lv('Iniciando con configuración de '+aname+'.cfg:\n'+JSON.stringify(j.args, null, 2))
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
                    log.lv('Falló la carga de '+aname+'.cfg:\n'+jsonString)
                    console.error("Error! Hay un error en el archivo de configuración "+cAppData+'/'+aname+'.cfg', error);
                }
            }

        }else{
            let aname=(''+presetAppName).toLowerCase()
            log.lv('Se omite la revisión del archivo '+aname+'.cfg...')
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
            log.lv('Ejecutando '+presetAppName+' con el argumento '+a)
            let m0=a.split('=')
            log.lv('Chequeando si existe la carpeta '+m0[1])
            if(unik.folderExist(m0[1])){
                log.lv('Ingresando a la carpeta '+m0[1])
                unik.cd(m0[1])
                log.lv('Carpeta actual: '+unik.currentFolderPath())
                cp=m0[1]
                fp=cp+'/main.qml'
            }else{
                log.lv('Error!\nEl argumento '+a+' no se podrá procesar porque la carpeta '+m0[1]+' no existe!')
                log.lv('Se continúa en la carpeta actual: '+unik.currentFolderPath())
                app.visibility="Maximized"
            }
        }
        if(argIndexGit>=0 && apps.runFromGit){
            let a=app.appArgs[argIndexGit]
            log.lv('Ejecutando '+presetAppName+' con el argumento '+a)
            m0=a.split('=')
            log.lv('Ejecutando auto actualización...')
            log.lv('Última carpeta de archivos: '+apps.uFolder)
            apps.uGitRep=m0[1]
            tiGitRep.text=apps.uGitRep
            log.lv('Descargando '+m0[1]+'...')
            app.visible=true
            app.visibility="Maximized"

            zipManager.mkUqpRepVersion(tiGitRep.text, 'probe')
        }else if(argIndexGit>=0 && !apps.runFromGit){
            let a=app.appArgs[argIndexGit]
            log.lv('Cargando url git desde configuración...')
            apps.enableCheckBoxShowGitRep=true
            m0=a.split('=')
            //log.lv('Ejecutando auto actualización...')
            apps.uGitRep=m0[1]
            tiGitRep.text=apps.uGitRep
            log.lv('Descargando '+m0[1]+'...')
            app.visible=true
            app.visibility="Maximized"
            //zipManager.mkUqpRepVersion(tiGitRep.text, 'probe')
        }else{
            if(argIndexFolder>=0){
                let a=app.appArgs[argIndexFolder]
                //log.lv('Ejecutando Unikey con el argumento '+a)
                m0=a.split('=')
                log.lv('El repositorio git se descargará en la carpeta '+m0[1])
                if(unik.folderExist(m0[1])){
                    log.lv('Ingresando a la carpeta '+m0[1])
                    unik.cd(m0[1])
                    unik.addImportPath(m0[1]+'/modules')
                    log.lv('Carpeta actual: '+unik.currentFolderPath())
                    cp=m0[1]
                    //fp=cp+'/main.qml'
                }else{
                    log.lv('La carpeta '+m0[1]+' no existe.')
                    log.lv('Creando la carpeta '+m0[1]+'')
                    unik.mkdir(m0[1])
                    if(unik.folderExist(m0[1])){
                        log.lv('La carpeta '+m0[1]+' fue creada con éxito.')
                        cp=m0[1]
                    }
                }
            }

        }

        //let t1=''
        if(unik.fileExist(fp)){
            log.lv('Esta carpeta contiene un archivo main.qml')
            botLanzarQml.visible=true
            let fileData=unik.getFile(fp)
            //log.lv("["+fileData+"]")
            //log.lv("["+app.uExampleCode+"]")
            if(app.uExampleCode===fileData){
                log.lv('Se ha detectado que el archivo '+fp+' al parecer es un archivo de ejemplo de Unikey.')
                botLanzarQml.text='Lanzar la aplicación de Ejemplo'
                botDeleteQmlFileExample.visible=true
            }else{
                unik.clearComponentCache()
                unik.setProperty('unik', unik)
                unik.setProperty("documentsPath", unik.getPath(3))
                unik.addImportPath(cp+'/modules')
                console.log('Cargando fp: '+fp)
                app.enableQmlErrorLog=false
                engine.load(fp)
                app.close()
            }
        }else{
            log.lv('Esta carpeta ['+fp.replace('/main.qml', '')+'] NO contiene un archivo main.qml')
            log.lv('Es posible que estes viendo estos mensajes porque no tienes un archivo main.qml en esta carpeta.<br><br>El archivo main.qml es necesario para que '+presetAppName+' inicie una aplicación del tipo QtQuick.')
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
        log.lv('Descargando: '+tiGitRep.text)
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
            log.lv('Creando acceso directo en el Escritorio: '+desktopIconFilePath)
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

            c='        log.lv(logData)\n'
            let onLogDataCode=c


            c='        //Nada\n'
            let onFinishedCode=c


            let cf=zipManager.getUqpCode(idName, cmd, onLogDataCode, onFinishedCode, onCompleteCode)

            if(app.dev)log.lv('cf '+idName+': '+cf.replace(/\n/g, '<br>'))

            let comp=Qt.createQmlObject(cf, zipManager.uqpsContainer, 'uqp-code-'+idName)
        }

    }
    //Procesar Response Repository Version
    function procRRV(res, url, tipo){
        //log.lv('onResponseRepVersion res: '+res)
        //log.lv('onResponseRepVersion url: '+url)
        //log.lv('onResponseRepVersion tipo: '+tipo)
        let nCtx=''
        let nRes=res.replace('\n', '')
        let version=''
        if(tipo==='probe'){
            version='prueba'
            if(nRes.split('.').length>=3){
                nCtx=nRes+'_'+url+'_'+tipo
                apps.uCtxUpdate=nCtx
                version='probe_'+nRes
                log.lv('El repositorio '+tiGitRep.text+' tiene disponible la versión '+nRes)
            }else{
                log.lv('El repositorio '+tiGitRep.text+' NO tiene un archivo "version" disponible.')
            }
            zipManager.version=version
            runProbe()
        }else{
            //Instalando...
            version='install'
            if(nRes.split('.').length>=3){
                //Existe un dato de version
                nCtx=nRes+'_'+url+'_'+tipo
                log.lv('El repositorio '+tiGitRep.text+' tiene disponible la versión '+nRes)
                //Check si el nuevo contexto es igual al anterior
                if(apps.uCtxUpdate===nCtx){
                    //Estamos en un contexto similar al anterior
                    log.lv('No se puede instalar este repositorio '+url+' porque ya está instalada la versión '+nRes)

                    //Check si existe carpeta del contexto similar
                    //Si la carpeta no existe se reinstalará el mismo contexto
                    let lastVersionInstaled='0.0.0.0'
                    if(apps.uCtxUpdate.indexOf(url)>=0 && apps.uCtxUpdate.indexOf('_')>=0){
                        let m100=apps.uCtxUpdate.split(url)
                        lastVersionInstaled=m100[0]
                        log.lv('La última versión de este repositorio '+url+' instalada fué '+lastVersionInstaled)
                        //Check si la última version instalada es diferente a la última disponible
                        if( lastVersionInstaled===nRes){
                            //La última version instalada es igual
                            //Se procede a ejecutar por carpeta
                            let m101=url.replace('/main/version').split('/')
                            let repName=m101[m101.length-1]
                            let fullFolderToInstall=unik.getPath(4)+'/'+repName+'_'+nRes
                            let fullFolderToInstall2=unik.getPath(4)+'/'+repName+'_'+nRes+'/'+repName+'-main'
                            let fullFileMainToInstall=unik.getPath(4)+'/'+repName+'_'+nRes+'/'+repName+'-main/main.qml'
                            if(unik.folderExist(fullFolderToInstall) && unik.folderExist(fullFolderToInstall2) && unik.fileExist(fullFileMainToInstall)){
                                unik.runOut(unik.getPath(0)+' -nocfg -folder='+fullFolderToInstall2)
                                if(!apps.dev){
                                    app.close()
                                }else{
                                    log.lv('Esta instancia de '+presetAppName+' no se ha cerrado porque estamos en modo desarrollador. Se ejecutó runOut("'+cmd+'")')
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
                log.lv('El repositorio '+tiGitRep.text+' NO tiene un archivo "version" disponible.')
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
                "git":"https://github.com/nextsigner/qml-pacman",
                "dev": false,
                "dep": false,
                "runFromGit": true,
                "runFromFolder": "zool"
            }
        }
        */
        let aname=(''+presetAppName).toLowerCase()
        let nCfgFilePath=unik.getPath(4)+'/'+aname+'.cfg'
        let defaultCfgPath='"'+unik.getPath(1)+'/default.cfg"'
        log.lv('Cargando configuración por defecto desde: '+defaultCfgPath)
        let js=unik.getFile(defaultCfgPath)
        log.lv('Buscando '+defaultCfgPath)
        if(unik.fileExist(defaultCfgPath)){


            let j=JSON.parse(js)
            log.lv('Configuración por defecto: '+JSON.stringify(j, null, 2))

            apps.dev=j.args['dev']
            apps.runFromGit=j.args['runFromGit']
            apps.runFromFolder=j.args['runFromFolder']
            apps.runOut=j.args['dep']

            log.lv('Definiendo configuración por defecto: '+nCfgFilePath)
            unik.setFile(nCfgFilePath, JSON.stringify(j, null, 2))
        }else{
            log.lv('Configuración por defecto no existe!: '+defaultCfgPath)
            let j={}
            j.args={}
            //j.args['git']="https://github.com/nextsigner/unikey-apps"
            j.args['git']="https://github.com/nextsigner/qml-pacman
"
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
}
