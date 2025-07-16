import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.1
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
    property color c1: 'black'
    property color c2: 'white'

    property var appArgs: []

    property string cp

    property string uExampleCode: ''

    property bool enableQmlErrorLog: true

    Settings{
        id: apps
        fileName: unik?unik.getPath(4)+'/unikey_app.cfg':''
        property bool dev: false
        property bool runFromGit: false
        property bool runOut: true
        property string uGitRep: 'https://github.com/nextsigner/unikey-demo'
        property string uFolder: unik.getPath(3)
        property bool enableCheckBoxShowGitRep: false
        property color fontColor: 'white'
        property color backgroundColor: 'black'
    }

    Connections{
        target: unik
        onUkStdChanged:{
            log.text+=''+unik.ukStd+'<br>'
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
                    text: '<h3>UniKey</h3>'
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
                                log.text+=''+text+'<br>'
                            }
                        }
                    }
                }

                Row{
                    spacing: app.fs
                    Button{
                        id: botCrearMainQmlDeEjemplo
                        text: 'Crear un ejemplo'
                        font.pixelSize: app.fs
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
                        font.pixelSize: app.fs
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        onClicked: {
                            let cp = unik.currentFolderPath()
                            let fp=cp+'/main.qml'
                            unik.setProperty('fromUnikey', true)
                            unik.setProperty("documentsPath", unik.getPath(3))
                            unik.addImportPath(cp+'/modules')
                            engine.load(fp)
                        }
                    }
                    Button{
                        id: botDeleteQmlFileExample
                        text: 'Eliminar main.qml de ejemplo'
                        font.pixelSize: app.fs
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
                            onCheckedChanged: {
                                apps.enableCheckBoxShowGitRep=checked
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
                                zipManager.mkUqpRepExist(text)
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
                        font.pixelSize: app.fs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                           runMix('probe')
                        }
                    }
                    Button{
                        id: botSaveGitRep
                        text: 'Instalar'
                        font.pixelSize: app.fs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            runMix('install')
                        }
                    }
                }
                ZipManager{
                    id: zipManager
                    visible: true
                    dev: apps.dev
                    //version: '1.1.1'
                    onResponseRepVersion:{
                        //log.lv('onResponseRepVersion res: '+res)
                        //log.lv('onResponseRepVersion url: '+url)
                        //log.lv('onResponseRepVersion tipo: '+tipo)
                        let nRes=res.replace('\n', '')
                        let version=''
                        if(tipo==='probe'){
                            version='prueba'
                            if(nRes.split('.').length>=3){
                                zipManager.version=nRes
                                log.lv('El repositorio '+tiGitRep.text+' tiene disponible la versión '+nRes)
                            }else{
                                log.lv('El repositorio '+tiGitRep.text+' NO tiene un archivo "version" disponible.')
                            }
                            runProbe()
                        }else{
                            version='install'
                            if(nRes.split('.').length>=3){
                                zipManager.version=nRes
                                log.lv('El repositorio '+tiGitRep.text+' tiene disponible la versión '+nRes)
                            }else{
                                log.lv('El repositorio '+tiGitRep.text+' NO tiene un archivo "version" disponible.')
                            }
                            runInstall()

                        }

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
                }
                Row{
                    spacing: app.fs
                    anchors.right: parent.right
                    Button{
                        text: 'Salir'
                        font.pixelSize: app.fs
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            Qt.quit()
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

        zipManager.curlPath = Qt.platform.os==='windows'?unik.getPath(1)+'/curl-8.14.1_2-win64-mingw/bin/curl.exe':'curl'
        zipManager.app7ZipPath = Qt.platform.os==='windows'?unik.getPath(1)+'/7-Zip32/7z.exe':'7z'
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
        c+='        if(unik.getProperty("fromUnikey")){\n'
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
        sequence: 'Ctrl+R'
        onActivated: unik.restartApp()
        //onActivated: init()
    }
    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
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
                    let cmd=unik.getPath(0)+' -nocfg -folder='+tiFolder.text
                    if(checkBoxRunOut.checked){
                        log.lv('Lanzando aparte ['+cmd+']')
                        unik.runOut(cmd)
                    }else{
                        unik.run(cmd)
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
        let fp=cp+'/main.qml'
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
            if(unik.fileExist(cAppData+'/unikey.cfg')){
                log.lv('Procesando archivo de configuración de Unikey...')
                let jsonString = unik.getFile(cAppData+'/unikey.cfg').replace(/\n/g, '')
                try {
                    j = JSON.parse(jsonString);
                    log.lv('Iniciando con configuración de unikey.cfg:\n'+JSON.stringify(j, null, 2))
                    //log.lv('Iniciando con configuración de unikey.cfg:\n'+JSON.stringify(j.args, null, 2))
                    if(j.args && j.args['git']){
                        argsFinal.push('-git='+j.args['git'])
                    }else{
                        if(j.args && j.args['folder']){
                            argsFinal.push('-folder='+j.args['folder'])
                        }
                    }
                    cfgSeted=true
                } catch (error) {
                    log.lv('Falló la carga de unikey.cfg:\n'+jsonString)
                    console.error("Error! Hay un error en el archivo de configuración "+cAppData+'/unikey.cfg', error);
                }
            }

        }else{
            log.lv('Se omite la revisión del archivo unikey.cfg...')
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
            log.lv('Ejecutando Unikey con el argumento '+a)
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
            log.lv('Ejecutando Unikey con el argumento '+a)
            m0=a.split('=')

            zipManager.version='latest'
            zipManager.resetApp=true
            zipManager.setCfg=true
            zipManager.download(m0[1])
            return

            log.lv('Descargando '+a+' en la carpeta '+cp)

            //-->Download and Unzip
            let url=m0[1].replace(/ /g, '')
            let urlZip=getCodeloadZipUrl(url)
            log.lv('Descargando desde '+urlZip)


            //let m0=tiGitRep.text.split('/')
            let m1=m0[m0.length-1].replace('.git', '')
            let repName=m1

            let d = new Date(Date.now())
            let ms = d.getTime()
            let tempZipFileName='zip_'+ms+'.zip'
            let tempZipFilePath=unik.getPath(2)+'/'+tempZipFileName
            //cp=tempZipFilePath
            let zipFolderDestination=unik.getPath(4)

            log.lv('Se descargará '+tempZipFilePath+' en la carpeta '+zipFolderDestination)

            let downloaded=unik.downloadZipFile(urlZip, tempZipFilePath)

            if(downloaded){
                let containerFolderName=unik.getZipContainerFolderName(tempZipFilePath).replace('/', '')
                log.lv('Carpeta contenedora principal: '+containerFolderName)
                let unziped=unik.unzipFile(tempZipFilePath, zipFolderDestination)
                if(!unziped){
                    log.lv('Error! El archivo '+tempZipFilePath+' NO se ha descomprimido correctamente.')
                    log.lv('Este error puede estar provocado por un error de permisos de escritura o problemas de acceso a la ubicación en el dispositivo '+zipFolderDestination)
                    return
                }else{
                    log.lv('Archivo descomprimido con éxito en '+zipFolderDestination)


                    log.lv('Bien! El repositorio '+tiGitRep.text+' se ha descargado con éxito!')

                    //app.cp=zipFolderDestination+'/'+containerFolderName
                    //app.cp=app.cp.replace(/ /g, '%20')

                    cp=zipFolderDestination+'/'+containerFolderName
                    cp=cp.replace(/ /g, '%20')

                    let files=unik.getFolderFileList(cp)
                    files=files.toString().split(',')
                    log.lv('files: '+files.toString().split(','))
                    log.lv('Revisando la carpeta '+app.cp)
                    if(files.indexOf('main.qml')<0){
                        log.lv('Tenemos un problema!\nEn la carpeta principal del repositorio descargado NO hay un archivo "main.qml"<br>Por este motivo no se podrá probar o ejecutar este repositorio con Unikey.')
                    }else{
                        unik.cd(app.cp)
                        fp=app.cp+'/main.qml'
                    }
                }
            }else{
                log.lv('Error! El repositorio git '+tiGitRep.text+' no se ha descargado correctamente.\nEl repositorio no existe o hay un problema con la conexión de internet.')
            }
            //<--Download and Unzip


            /*let downloaded=unik.downloadGit(m0[1], 'main', cp)
            let gp0=m0[1].split('/')
            let gp=gp0[gp0.length-1]
            if(downloaded){
                log.lv('Listo. Se ha descargado '+a+' en la carpeta '+cp)
                //Git Project

                log.lv('Los archivos se descargaron en '+cp+'/'+gp)
                let fl=unik.getFolderFileList(cp+'/'+gp)
                log.lv('Archivos:\n ')
                for(var i=0;i<fl.length;i++){
                    if(fl[i]==='.' || fl[i]==='..' )continue
                    if(unik.isFolder(cp+'/'+gp+'/'+fl[i])){
                        log.lv('./'+fl[i])
                        let fl2=unik.getFolderFileList(cp+'/'+gp+'/'+fl[i])
                        for(var i2=0;i2<fl2.length;i2++){
                            if(fl2[i2]==='.' || fl2[i2]==='..' )continue
                            if(unik.isFolder(cp+'/'+gp+'/'+fl[i]+'/'+fl2[i2])){
                                //log.lv('&nbsp;&nbsp;/'+fl[i]+'/'+fl2[i2])
                                let fl3=unik.getFolderFileList(cp+'/'+gp+'/'+fl[i]+'/'+fl2[i2])
                                for(var i3=0;i3<fl3.length;i3++){
                                    if(fl3[i3]==='.' || fl3[i3]==='..' )continue
                                    if(unik.isFolder(cp+'/'+gp+'/'+fl[i]+'/'+fl2[i2]+'/'+fl3[i3])){
                                        log.lv('&nbsp;&nbsp;&nbsp;&nbsp;/'+fl[i]+'/'+fl2[i2]+'/'+fl3[i3])
                                    }else{
                                        log.lv('&nbsp;&nbsp;&nbsp;&nbsp;'+fl3[i3]+'\n')
                                    }
                                }
                            }else{
                                log.lv('&nbsp;&nbsp;'+fl2[i2]+'\n')
                            }
                        }
                    }else{
                        log.lv(''+fl[i]+'\n')
                    }
                }
                unik.cd(cp+'/'+gp)
                fp=cp+'/'+gp+'/main.qml'
                //engine.load(fp)
            }else{
                log.lv('Error! Ocurrió un error al descargar '+m0[1])
                log.lv('Hay un problema con la conexión de internet o el repositorio no existe.')
                log.lv('Ten en cuenta que Unikey está programado para descargar desde la rama "main", no "master".')
                app.visibility="Maximized"
            }*/
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
            log.lv('Es posible que estes viendo estos mensajes porque no tienes un archivo main.qml en esta carpeta.<br><br>El archivo main.qml es necesario para que Unikey inicie una aplicación del tipo QtQuick.')
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
        let argsName=args.replace(/-/g, '_')
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
Comment=Creado por Unikey
Exec='+exePath+' '+args+'
Icon='+exePath.replace('/'+m0[m0.length-1], '')+'/logo.png
Categories=Application
Type=Application
Terminal=false'
        }

        return c
    }
    function mkAd(exePath, args, wd){
        let m0=exePath.split('/')
        let argsName=args.replace(/-/g, '_')
        let fileName=''+m0[m0.length-1]+'_'+argsName//+'.lnk'
        let c=getAdCode(exePath, args, wd)
        if(Qt.platform.os==='linux'){
            unik.setFile(unik.getPath(6)+'/'+fileName+'.desktop', c)
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

            if(app.dev)log.lv('cf '+idName+': '+cf)

            let comp=Qt.createQmlObject(cf, zipManager.uqpsContainer, 'uqp-code-'+idName)
        }
    }
}
