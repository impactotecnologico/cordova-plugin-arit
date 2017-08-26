# Plataforma iOS

## Preparando el ordenador con herramientas para el desarrollo.
   Instalar NPM
   Instalar Cordova, npm install -g cordova
   Instalar Xcode, desde la app store
   Ejecutar en la terminal este comando xcode-select --install
   Instale ios-sim, npm install -g ios-sim
   Instale ios-deploy, npm install -g ios-deploy

## Preparando el proyecto.
   Descargar el proyecto cordova-plugin-arit, debe contener lo siguiente
    - hooks
    - package.json
    - plugin.xml
    - src
    - www
   Este es el directorio raiz del plugin para su instalacion en un proyecto cordova.   

   Dentro del directorio /src, tenemos
    - CatchoomSDK.zip      'SDK de CatchoomSDK, se debe descomprimir y colocar dentro de la carpeta ios.'
    - android               'Plugin para la plataforma android.'
    - ios                   'Plugin para la plataforma ios con recursos para ejecucion en nativo.'
    - ios.xcodeproj         'Conjunto de archivos para abrir Xcode y ejecutar el plugin en un entorno nativo.'

   Para concluir este paso, necesitamos descompirir el contenido del zip dentro de la carpeta src/ios/CatchoomSDK.

## Instalacion del plugin ARIT en un proyecto cordova o derivados.
   Crear un proyecto de cordova, cordova create proyecto
   Ubicamos el cursor dentro del proyecto creado, cd proyecto
   Agregamos la plataforma ios, cordova platform add ios
   Instalar el plugin ARIT, cordova plugin add ~/cordova-plugin-arit --nofetch

## Nativo ó Plugin Cordova
	Este plugin se puede ejecutar tanto en una aplicacion nativa y como en una aplicacion cordova y esto se debe gracias a que ambos proyectos estan mezclados en uno. En esencia la unica diferencia al momento de ejecutarse es quien dispara o inicia el flujo del componente. Cuando hablamos de...
		- Una ejecucion nativa, quien inicia la aplicacion es el archivo main.m, usando el AppDelegate con una configuracion por defecto para ejecutar una vista inicial en el ARMain.storyboard, esta vista inicial tiene un controlador, y es ARMainViewController.
		- Una ejecucion dentro de un proyecto cordova, quien inicia la ejecucion del plugin es cordova a traves de la clase ARPlugin, alli tenemos una primitivas que cordova invocara segun el mensaje que se reciba desde javacript.
	           Ejemplos de mensaje:
	           ARPlugin.ARActivity("menu") // Opcion 1
	           cordova.exec(function(we){}, function(err) {}, "ARPlugin", "execute", ["menu"]); // Opcion 2

	A partir de aqui el flujo entre ambas plataformas (Nativo ó Plugin Cordova) es el mismo ya que el codigo es practicamente igual.
		- ARPlugin y ARMainViewController se encargan de adquirir el config.json, guardar los recursos y segun la accion deseada mostrar ARAugmentedViewController.

## Ejecucion del componente en un proyecto cordova.
   	Creamos algun disparador para usar el plugin, un boton o evento, por ejemplo
   		...
	   	onDeviceReady: function() {
	   		...
	           ARPlugin.ARActivity("menu") // Opcion 1
	           cordova.exec(function(we){}, function(err) {}, "ARPlugin", "execute", ["menu"]); // Opcion 2
	       }
	    ...
   	Compilamos la plataforma ios, cordova prepare ios
   	Abrimos el proyecto que se genero en la carpeta platform/ios usando el archivo .xcworkspace.   

   	Ubicar el archivo ARBaseApiController.m y descomentar la linea 16
   		//#import "AFNetworking.h" => #import "AFNetworking.h"
   	Ubicar el archivo ARBaseApiController.m y comentar la linea 13
		#import <Pods/AFNetworking.h> => //#import <Pods/AFNetworking.h>
	Nota: Por defecto se encuentra asi, esto se hace por que cuando se ejecuta el componente en un proyecto nativo la libreria AFNetworking.h esta dentro de Pods.Frameworks mientras que cuando se ejecuta en un proyecto cordova, se encuentra en la raiz del proyecto como una referencia local.

   	Colocamos y selecionamos el dispositivo donde queremos probar.
   	Precionamos Run en XCode.

## Ejecucion del componente en nativo.
   	Abrir src/ios/ios.xcodeproj.
   	
   	Ubicar el archivo ARBaseApiController.m y descomentar la linea 13
   		//#import <Pods/AFNetworking.h> => #import <Pods/AFNetworking.h>
   	Ubicar el archivo ARBaseApiController.m y comentar la linea 16
		#import "AFNetworking.h" => //#import "AFNetworking.h"
	Nota: Esto se hace por que cuando se ejecuta el componente en un proyecto nativo la libreria AFNetworking.h esta dentro de Pods.Frameworks mientras que cuando se ejecuta en un proyecto cordova, se encuentra en la raiz del proyecto como una referencia local.
   	
   	Colocamos y selecionamos el dispositivo donde queremos probar.
   	Precionamos Run en XCode.
