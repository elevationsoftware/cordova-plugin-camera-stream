var exec = require('cordova/exec');

// Camera: front or back
exports.startCapture = function (camera) {
    exec(null, null, 'CameraBaseStream', 'startCapture', [camera]);
};

exports.pause = function () {
    exec(null, null, 'CameraBaseStream', 'pause', []);
};

exports.resume = function () {
    exec(null, null, 'CameraBaseStream', 'resume', []);
};

exports.capture = function(data){
    /**
     * Just a placeholder, iOS is going to call this
     * directly when the camera stream is ready.
     * 
     * Define this func in your app to use the data.
     * 
     * Example:
     * 
     * var imageData = document.getElementById('<imageId>')
     * 
     * cordova.plugins.CameraBase64.capture = function(data){
     *      image.src = imageData
     * }
     * //Starting the stream
     * cordova.plugins.CameraBase64.startCapture();
     */
};