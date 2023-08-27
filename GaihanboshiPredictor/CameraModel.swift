//
//  CameraModel.swift
//  GaihanboshiPredictor
//
//  Created by 滝瀬隆斗 on 2023/08/27.
//

import AVFoundation
import UIKit
class CameraModel {
    //    カメラセッションをclassプロパティとして定義
    var captureSession = AVCaptureSession()
//    @Published var imageForPreview: UIImage?
    //    Delegateのインスタンス生成
//    var photoCaptureDelegate: PhotoCaptureDelegate
    //    撮影関数
    func takePicture(flashMode: Bool, delegate: PhotoCaptureDelegate) {
        guard let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput else { return }
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .off

        #if targetEnvironment(simulator)
        #else
        guard let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
            for: AVMediaType.video, // ビデオ入力
            position: AVCaptureDevice.Position.back)
        else{ return }
        if device.hasFlash {
            if device.isFlashAvailable {
                if flashMode == true {
                    photoSettings.flashMode = .on
                }
            }
        }
        #endif
        
        
        photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
//        imageForPreview = photoCaptureDelegate.imageForPreview
    }
    
    //    カメラ初期設定
    func setupCamera() {
        //    シミュレータ上ではセッション設定をスキップ
        #if targetEnvironment(simulator)
        #else
        captureSession.beginConfiguration()
        connectInputsToSession()
        connectOutputToSession()
        captureSession.commitConfiguration()
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        #endif
        //    Input設定
        func connectInputsToSession() {
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput)
            else {
                print("error. Input設定エラー")
                return
                
            }
            captureSession.addInput(videoDeviceInput)
            
        }
        //    Output設定
        func connectOutputToSession() {
            let photoOutput = AVCapturePhotoOutput()
            guard captureSession.canAddOutput(photoOutput)
            else {
                print("error. Output設定エラー")
                return
            }
            captureSession.sessionPreset = .photo
            captureSession.addOutput(photoOutput)
        }
    }
}

//    撮影関数で使用するDelegate
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, ObservableObject {
    @Published var imageForPreview: UIImage?

    // 写真撮影後の処理を実装する
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // 写真が取得されたら、ここで処理を行う
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData){
            print(image)
            imageForPreview = image
//            print(imageForPreview)
        }
    }
}

