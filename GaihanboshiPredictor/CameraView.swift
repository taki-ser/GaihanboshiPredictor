//
//  CameraView.swift
//  CameraTest
//
//  Created by 滝瀬隆斗 on 2023/08/27.
//

import SwiftUI
import AVFoundation
//    Viewの定義
struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    //    カメラセッションをclassプロパティとして定義
    let captureSession = AVCaptureSession()
    //    Delegateのインスタンス生成
    @StateObject private var photoCaptureDelegate = PhotoCaptureDelegate()
    @ObservedObject private var cameraModel = CameraModel()
    @State var flashMode = false
    
    //    body定義
    init() {
        cameraModel.setupCamera(captureSession: captureSession)
    }
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                //            カメラプレビュー
                PreviewViewUIView(captureSession: captureSession)
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(height: UIScreen.main.bounds.width/3*4)
                    .background(Color.white)
                Spacer()
                HStack{
                    //                    キャンセルボタン
                    Button(action: {dismiss()}) {
                        Text("Cancel")
                            .foregroundColor(Color.white)
                            .font(.title)
                    }
                    .frame(width: UIScreen.main.bounds.width/3)
                    //                    シャッターボタン
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth:5)
                            .frame(width: 90, height:90)
                        Button(action: {
                            cameraModel.takePicture(flashMode: flashMode, captureSession: captureSession, photoCaptureDelegate: photoCaptureDelegate)
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height:80)
                            
                        }
                        .buttonStyle(ShutterButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 110)
                    //                   フラッシュボタン
                    Button(action: {flashMode.toggle()}) {
                        Image(systemName: flashMode == true ? "bolt.circle": "bolt.slash.circle")
                            .font(.title)
                        
                    }
                    .frame(width: UIScreen.main.bounds.width/3)
                    .foregroundColor(Color.white)
                }
                .frame(width: UIScreen.main.bounds.width)
                
                Spacer()
                
            }
            .background(Color.gray)
            
            
            
            if let image = photoCaptureDelegate.imageForPreview {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    Button(action: {
                        photoCaptureDelegate.imageForPreview = nil
                    }, label: {Text("Back")})
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
            return previewView
        }
        func updateUIView(_ uiViewController:  UIViewControllerType, context: Context) {
        }
    }
    struct ShutterButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1)
        }
    }
    
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
        else {
            print("写真が撮れていない")
        }

    }
}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
