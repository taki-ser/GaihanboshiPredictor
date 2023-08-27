//
//  CameraView.swift
//  GaihanboshiPredictor
//
//  Created by 滝瀬隆斗 on 2023/08/27.
//

import SwiftUI
import AVFoundation
//    Viewの定義
struct CameraView: View {
    //    カメラセッションをclassプロパティとして定義
    let captureSession = AVCaptureSession()
    @State var flashMode = false
    //    Delegateのインスタンス生成
    @StateObject private var photoCaptureDelegate = PhotoCaptureDelegate()
    //    撮影された写真
    @State var previewImage: UIImage?
    //    body定義
    var body: some View {
        VStack {
            Spacer()
            PreviewViewUIView(captureSession: captureSession)
                .onAppear(perform: {setupCamera()})
                .frame(width: UIScreen.main.bounds.width)
                .frame(height: UIScreen.main.bounds.width/3*4)
                .background(Color.white)
            Spacer()
            
            ZStack{
                HStack{
                    Button(action: {}) {
                        Text("Cancel")
                            .foregroundColor(Color.white)
                            .font(.title)
                    }
                    .frame(width: UIScreen.main.bounds.width/3)
                    Spacer()
                    Button(action: {flashMode.toggle()}) {
                        Image(systemName: flashMode == true ? "bolt.circle": "bolt.slash.circle")
                            .font(.title)
                        
                    }
                    .frame(width: UIScreen.main.bounds.width/3)
                    .foregroundColor(Color.white)
                }
                .frame(width: UIScreen.main.bounds.width)
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth:5)
                        .frame(width: 90, height:90)
                    Button(action: {
                        takePicture(flashMode: flashMode)
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height:80)
                        
                    }
                    .buttonStyle(ShutterButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 110)
            }
            Spacer()
        }
        .background(Color.gray)
    }
    
    //    撮影関数
    func takePicture(flashMode: Bool) {
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
        
        
        photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
    }
    //    撮影関数で使用するDelegate
    class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, ObservableObject {
        @Published var imageForPreview: UIImage?
        init(imageForPreview: UIImage? = nil) {
            self.imageForPreview = imageForPreview
        }
        // 写真撮影後の処理を実装する
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            // 写真が取得されたら、ここで処理を行う
            if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData){
                print(image)
                imageForPreview = image
            }
        }
    }
    //    カメラ初期設定
    private func setupCamera() {
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
  
    //    preview用画面UIView
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    //    PreviewViewをUIViewからSwiftUI用Viewに変換
    struct PreviewViewUIView: UIViewRepresentable {
        typealias UIViewControllerType = PreviewView
        let captureSession: AVCaptureSession
        func makeUIView(context: Context) ->  UIViewControllerType {
            let previewView = PreviewView()
            previewView.videoPreviewLayer.session = captureSession
//            previewView.videoPreviewLayer.connection?.videoOrientation = .portrait
//            previewView.videoPreviewLayer.videoGravity = .resizeAspect
            return previewView
        }
        func updateUIView(_ uiViewController:  UIViewControllerType, context: Context) {
        }
    }
//    シャッターボタンスタイル
    struct ShutterButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1)
        }
    }
}



struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
