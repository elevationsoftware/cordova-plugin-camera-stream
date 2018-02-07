import Foundation
import AVFoundation

@objc(CameraStream)
class CameraStream: CDVPlugin, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var mainCommand: CDVInvokedUrlCommand?
    
    @objc(startCapture:)
    func startCapture(command: CDVInvokedUrlCommand) {
        // Selecting the camera from the device
        let cameraString = command.arguments[0] as? String ?? "front"
        var camera: AVCaptureDevice
        
        switch cameraString {
        case "back":
            camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        default:
            camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)!
        }
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        var videoDataOutput: AVCaptureVideoDataOutput!
        
        // Setting up session
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSession.Preset.photo
        
        do{
            input = try AVCaptureDeviceInput(device: camera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session!.canAddInput(input){
            session!.addInput(input)
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            
            // Setting single thread queue to silence xcode warning
            let queue = DispatchQueue.main//(label: "camerabase64")
            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            
            if session!.canAddOutput(videoDataOutput) {
                mainCommand = command
                session!.addOutput(videoDataOutput)
                // lets start some session baby :)
                session!.startRunning()
            }
        }
    }
    
    @objc(pause:)
    func pause(command: CDVInvokedUrlCommand){
        if session?.isRunning {
            session?.stopRunning()
        }
    }
    
    @objc(resume:)
    func resume(command: CDVInvokedUrlCommand){
        if session?.isRunning {
            return
        }
        session?.startRunning()
    }
    
    
    func captureOutput(_ output: AVCaptureOutput,  didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool{
            let  imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            // Lock the base address of the pixel buffer
            CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
            
            // Get the number of bytes per row for the pixel buffer
            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
            
            // Get the number of bytes per row for the pixel buffer
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
            // Get the pixel buffer width and height
            let width = CVPixelBufferGetWidth(imageBuffer!)
            let height = CVPixelBufferGetHeight(imageBuffer!)
            
            // Create a device-dependent RGB color space
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            // Create a bitmap graphics context with the sample buffer data
            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
            bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
            let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            // Create a Quartz image from the pixel data in the bitmap graphics context
            let quartzImage = context?.makeImage()
            // Unlock the pixel buffer
            CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
            
            // Create an image object from the Quartz image
            let image = UIImage.init(cgImage: quartzImage!)
            let imageData = UIImageJPEGRepresentation(image, 0.3)
            // Generating a base64 string for cordova's consumption
            let base64 = imageData?.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
            // Describe the function that is going to be call by the webView frame
            let javascript = "cordova.plugins.CameraStream.capture('data:image/jpeg;base64,\(base64!)')"
            
            if let webView = webView {
                if let uiWebView = webView as? UIWebView {
                    // Evaluating the function
                    uiWebView.stringByEvaluatingJavaScript(from: javascript)
                }
            } else {
                print("webView is nil")
            }
        }
    }
}

