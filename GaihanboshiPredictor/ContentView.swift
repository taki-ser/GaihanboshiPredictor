//
//  ContentView.swift
//  GaihanboshiPredictor
//
//  Created by 滝瀬隆斗 on 2023/08/27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            NavigationLink(destination: LectureView()) {
                VStack {
                    Spacer()
                    Image(systemName: "hand.tap")
                        .font(.largeTitle)
                    Text("撮影方法を確認する")
                        .bold()
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width-30)
                .background(Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(30)
            }
            Spacer(minLength: 30)
            NavigationLink(destination: CameraView()) {
                VStack {
                    Spacer()
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                    Text("撮影開始")
                        .bold()
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width-30)
                .background(Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(30)
            }
        }

    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE","iPhone 14","iPhone 14 Pro Max"], id: \.self) { deviceName in
            ContentView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        
    }
}
