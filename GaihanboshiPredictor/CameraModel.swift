//
//  CameraModel.swift
//  GaihanboshiPredictor
//
//  Created by 滝瀬隆斗 on 2023/08/27.
//
import AVFoundation

class CameraModel: ObservableObject {
    @Published var isFlashAvailable = false
    let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
    let photoOutput = AVCapturePhotoOutput()
    //    撮影関数
    func takePicture(flashMode: Bool, captureSession: AVCaptureSession, photoCaptureDelegate: AVCapturePhotoCaptureDelegate) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .off
        
        
        if flashMode == true && isFlashAvailable == true {
            photoSettings.flashMode = .on
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
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
            guard let device = videoDevice else {
                print("カメラが使用できません")
                return
                
            }
            if device.hasFlash && device.isFlashAvailable {
                isFlashAvailable = true
            }
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device), captureSession.canAddInput(videoDeviceInput)
            else {
                print("error")
                return
                
            }
            captureSession.addInput(videoDeviceInput)
            
        }
        //    Output設定
        func connectOutputToSession() {
            
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
