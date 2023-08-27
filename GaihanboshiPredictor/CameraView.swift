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
    //    CameraModelインスタンスを生成
    private let cameraModel = CameraModel()
    private let photoCaptureDelegate: PhotoCaptureDelegate = PhotoCaptureDelegate()
    
    @State private var flashMode = false
    //    撮影された写真
    @State var previewImage: UIImage?
//    写真プレビュー画面表示
    @State var isPreviewPreview = false
    
    init() {
//        self.photoCaptureDelegate = PhotoCaptureDelegate()
        cameraModel.setupCamera()
        }
    //    body定義
    var body: some View {
//        if previewImage == nil {
            VStack {
                Spacer()
                PreviewViewUIView(captureSession: cameraModel.captureSession)
//                    .onAppear(perform: {cameraModel.setupCamera()})
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
                            cameraModel.takePicture(flashMode: flashMode,delegate:  photoCaptureDelegate)
                            previewImage = photoCaptureDelegate.imageForPreview
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
//                if let image = previewImage {
//                    Image(uiImage: image)
//                }
            }
            .background(Color.gray)
//        }
//        else {
            CapturedImagePreviewView(previewImage: $previewImage, isPreviewPreview: $isPreviewPreview)
//        }
    }
    
    struct CapturedImagePreviewView: View {
        @Binding var previewImage: UIImage?
        @Binding var isPreviewPreview: Bool
        
        var body: some View {
            VStack {
                if let image = previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/3*4)
                        .scaledToFit()
                }
                Button(action: {
                    isPreviewPreview.toggle()
                    previewImage = nil
                }, label: {Text("Back")})
            }
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



//struct CapturedImagePreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        CapturedImagePreviewView(previewImage: CameraView().$previewImage, isPreviewPreview: CameraView().$isPreviewPreview)
//    }
//}



struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
