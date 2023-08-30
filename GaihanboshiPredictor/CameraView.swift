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
    @State var captureSession = AVCaptureSession()
    //    Delegateのインスタンス生成
    @StateObject private var photoCaptureDelegate = PhotoCaptureDelegate()
    @ObservedObject private var cameraModel = CameraModel()
    @State var flashMode = false
    @State var isCaptured = true
    
    //    body定義
    init() {
        cameraModel.setupCamera(captureSession: captureSession)
    }
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                ZStack {
                    //            カメラプレビュー
                    PreviewViewUIView(captureSession: captureSession)
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: UIScreen.main.bounds.width/3*4)
                        .background(Color.white)
                    if isCaptured == false {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: UIScreen.main.bounds.width)
                            .frame(height: UIScreen.main.bounds.width/3*4)
                            .animation(.spring(response: 0.5,
                                               dampingFraction: 0.5, blendDuration: 0), value: isCaptured)
                    }
                    if let image = photoCaptureDelegate.imageForPreview {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
                Spacer()
                if photoCaptureDelegate.imageForPreview == nil {
                    HStack{
                        
                        //                    キャンセルボタン
                        Button(action: {dismiss()}) {
                            Text("キャンセル")
                                .foregroundColor(Color.white)
                                .font(.title2)
                        }
                        .frame(width: UIScreen.main.bounds.width/3)
                        .disabled(!isCaptured)
                        //                    シャッターボタン
                        
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth:5)
                                .frame(width: 90, height:90)
                            Button(action: {
                                cameraModel.takePicture(flashMode: flashMode, captureSession: captureSession, photoCaptureDelegate: photoCaptureDelegate)
                                isCaptured = false
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 80, height:80)
                                
                            }
                            .buttonStyle(ShutterButtonStyle())
                        }
                        .disabled(!isCaptured)
                        //                   フラッシュボタン
                        Button(action: {flashMode.toggle()}) {
                            Image(systemName: flashMode == true ? "bolt.circle": "bolt.slash.circle")
                                .font(.largeTitle)
                        }
                        .frame(width: UIScreen.main.bounds.width/3)
                        .foregroundColor(Color.white)
                        .disabled(!cameraModel.isFlashAvailable)
                        .disabled(!isCaptured)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 110)
                }
                else {
                    HStack {
                        Spacer()
                        Button(action: {
                            photoCaptureDelegate.imageForPreview = nil
                            isCaptured = true
                        }, label: {Text("再撮影")})
                        .padding()
                        .font(.title)
                        .foregroundColor(Color.white)
//                        .background(Color.blue)
//                        .cornerRadius(20)
                        Spacer()
                        Button(action: {
                        }, label: {Text("次へ")})
                        .padding()
                        .font(.title)
                        .foregroundColor(Color.white)
//                        .background(Color.blue)
//                        .cornerRadius(20)
//                        Rectangle()
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 110)
                }
                
                Spacer()
                
            }
            .background(Color.black)
            
            
            
//            if let image = photoCaptureDelegate.imageForPreview {
//                VStack {
//                    Spacer()
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                    Button(action: {
//                        photoCaptureDelegate.imageForPreview = nil
//                    }, label: {Text("Back")})
//                    Spacer()
//                }
//            }
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
        func makeUIView(context: Context) -> UIViewControllerType {
            let previewView = PreviewView()
            previewView.videoPreviewLayer.session = captureSession
            return previewView
        }
        func updateUIView(_ uiViewController: UIViewControllerType, context: Context) {
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
