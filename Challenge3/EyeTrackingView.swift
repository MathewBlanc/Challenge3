//
//  ContentView.swift
//  Challenge3
//
//  Created by Mathew Blanc on 09/12/24.
//

import SwiftUI

import ARKit
import RealityKit

class EyeTrackingManager: NSObject, ARSessionDelegate, ObservableObject {
    private var arSession: ARSession?
    @Published var gazePoint: CGPoint?
    @Published var isEyesClosed: Bool = false
    
    private var screenSize: CGSize = .zero
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        super.init()
        setupARSession()
    }
    
    func setupARSession() {
        arSession = ARSession()
        let configuration = ARFaceTrackingConfiguration()
        configuration.isWorldTrackingEnabled = false
        
        arSession?.delegate = self
        arSession?.run(configuration)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        
        // Analyze eye closure
        let leftEyeClosed = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
        let rightEyeClosed = faceAnchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0
        
        DispatchQueue.main.async {
                    self.gazePoint = self.convertLookAtPointToScreenCoordinates(faceAnchor: faceAnchor)
                }
        
        DispatchQueue.main.async {
                    self.isEyesClosed = leftEyeClosed > 0.5 || rightEyeClosed > 0.5
                    
                    // Placeholder for gaze point calculation
                    // You'll need to implement proper coordinate transformation
                    // self.gazePoint = calculatedPoint
                }
    }
    
    func convertLookAtPointToScreenCoordinates(faceAnchor: ARFaceAnchor) -> CGPoint? {
            // ARKit's lookAtPoint is a normalized vector in the face's coordinate system
            // It represents gaze direction as (-1, -1) to (1, 1)
            let lookAtPoint = faceAnchor.lookAtPoint
            
            // Convert normalized coordinates to screen coordinates
            // We'll map the -1 to 1 range to our screen dimensions
            let screenX = CGFloat((lookAtPoint.x + 1) / 2) * screenSize.width
            let screenY = CGFloat((lookAtPoint.y + 1) / 2) * screenSize.height
            
            return CGPoint(x: screenX, y: screenY)
        }
}

struct EyeTrackingView: View {
    @StateObject private var eyeTrackingManager: EyeTrackingManager
    
    init() {
        let screenSize = UIScreen.main.bounds.size
        _eyeTrackingManager = StateObject(wrappedValue: EyeTrackingManager(screenSize: screenSize))
    }
    
    var body: some View {
        ZStack {
            // Your main UI
            VStack {
                Text("Gaze Tracking")
                
                // Overlay showing gaze point or eye state
                if let gazePoint = eyeTrackingManager.gazePoint {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .position(gazePoint)
                }
                
                Text(eyeTrackingManager.isEyesClosed ? "Eyes Closed" : "Eyes Open")
            }
        }
    }
}

#Preview {
    EyeTrackingView()
}
