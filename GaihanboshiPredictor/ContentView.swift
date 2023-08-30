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
            //            CameraView()
            NavigationLink(destination: CameraView()) {
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                    Text("撮影開始")
                        .bold()
                }
                .frame(width: 200, height: 100)
                .background(Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(30)
            }

            //                .navigationDestination
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
