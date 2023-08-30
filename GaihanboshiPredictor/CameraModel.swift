//
//  CameraModel.swift
//  GaihanboshiPredictor
//
//  Created by 滝瀬隆斗 on 2023/08/27.
//
import AVFoundation

class CameraModel: ObservableObject {
    //    撮影関数
    func takePicture(flashMode: Bool, captureSession: AVCaptureSession, photoCaptureDelegate: AVCapturePhotoCaptureDelegate) {
        guard let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput else { return }
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .off
        
    #if targetEnvironment(simulator)
    #else
        guard let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
               for: AVMediaType.video, // ビデオ入力
               position: AVCaptureDevice.Position.back)
        else{
            print("default deviceが使えません")
            return
        }
        if device.hasFlash {
            if device.isFlashAvailable {
                if flashMode == true {
                    photoSettings.flashMode = .on
                }
            }
        }
    #endif
    //        DispatchQueue.global(qos: .background).async {
            photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
    //        }
    }

    //    カメラ初期設定
    func setupCamera(captureSession: AVCaptureSession) {
        //    シミュレータ上ではセッション設定をスキップ
    #if targetEnvironment(simulator)
    #else
        captureSession.beginConfiguration()
        connectInputsToSession()
        connectOutputToSession()
        captureSession.commitConfiguration()
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    #endif
        //    Input設定
        func connectInputsToSession() {
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput)
            else {
                print("error")
                return
                
            }
            captureSession.addInput(videoDeviceInput)
            
        }
        //    Output設定
        func connectOutputToSession() {
            let photoOutput = AVCapturePhotoOutput()
            guard captureSession.canAddOutput(photoOutput)
            else {
                print("error")
                return
                
            }
            captureSession.sessionPreset = .photo
            captureSession.addOutput(photoOutput)
        }
    }
}
