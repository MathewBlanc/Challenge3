//
//  ARViewContainer.swift
//  Challenge3
//
//  Created by Mathew Blanc on 12/12/24.
//  Adapted from Tiago Pereira and Matteo Altobello:
//  https://www.createwithswift.com/creating-an-augmented-reality-app-in-swiftui-using-realitykit-and-arkit/

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var modelName: String
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        let anchorEntity = AnchorEntity(plane: .any)
        
        guard let modelEntity = try? Entity.loadModel(named: "Bunny5") else {
            print("model not loaded")
            return
        }

//        modelEntity.scale = SIMD3<Float>(0.1, 0.1, 0.1)
        
        anchorEntity.addChild(modelEntity)
        uiView.scene.addAnchor(anchorEntity)
        
//        let entity = try? Entity.load(named: "bunny2", in: .main)
        
//        guard let anchor = try? BunnyJump
//        uiView.scene.anchors.append(anchor)

    }
}

//#Preview {
//    ARViewContainer()
//}
