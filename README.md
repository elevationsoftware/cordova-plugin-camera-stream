# Camera Stream Plugin for Apache Cordova

This plugin enables consumption of the device camera stream from an HTML Element.

The plugin provides a simple JavaScript API for iOS. 

 * Start Streaming
 * Capture streaming
 * Selecting back or front camera
 
After starting the streaming the plugin would provide access to a base64 string that can be convert it into a byteArray or just simply be associated with an image element. The reason for this plugin is to provide the ability to control the feel and look of the camera view with css directly from the DOM.

_This plugin isn't intended replace WebRTC._ Try [cordova-plugin-iosrtc](https://github.com/BasqueVoIPMafia/cordova-plugin-iosrtc) for WebRTC on iOS.

## Supported Platforms

* iOS

Android support is not really necessary because you can acquire the same stream by simply utilizing WebRTC.

# Installing

### Cordova

    $ cordova plugin add cordova-plugin-camera-stream

## Usage

The plugin exposes the `cordova.plugins.CameraStream` JavaScript namespace which contains two functions.

# Assign Stream to an image tag

```javascript
var imageElement = document.getElementById('<imageId>');

cordova.plugins.CameraStream.capture = function(data){
    imageElement.src = data;
}

// Start the streaming and select the camera
// @camera - front or back
cordova.plugins.CameraStream.startCapture('front')
  
```

# Assign Stream to a canvas element

```javascript
var image = new Image();

// draw image on canvas
let canvas = document.getElementById('<canvasId>');
let ctx = canvas.getContext('2d');

image.onload = function() {
    ctx.drawImage(this, 0, 0, '<canvasHeight>', '<canvasWidth>');
}

cordova.plugins.CameraStream.capture = function(data){
    image.src = data;
}

// Start the streaming and select the camera
// @camera - front or back
cordova.plugins.CameraStream.startCapture('front')
  
```

## Author

[Elevation Software](http://elevationsoftware.us/)

### Maintainers

* [Carlos Martin](https://github.com/pirumpi)


## License

[ISC](./LICENSE.md)