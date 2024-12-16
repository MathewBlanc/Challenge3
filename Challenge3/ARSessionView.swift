//
//  ARSessionView.swift
//  Challenge3
//
//  Created by Mathew Blanc on 12/12/24.
//  Adapted from Tiago Pereira and Matteo Altobello
//  https://www.createwithswift.com/creating-an-augmented-reality-app-in-swiftui-using-realitykit-and-arkit/

import SwiftUI

struct ARSessionView: View {
    
    @Binding var isPresented: Bool
    @State private var modelName: String = "BunnyJump"
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ARViewContainer(modelName: $modelName)
                .ignoresSafeArea()
            VStack {
                Button() {
                    isPresented.toggle()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(24)
                
                Spacer()

            }
        }
    }
}

#Preview {
    ARSessionView(isPresented: .constant(true))
}
