//
//  SessionSuccessView.swift
//  Challenge3
//
//  Created by Mathew Blanc on 16/12/24.
//

import SwiftUI
import ConfettiSwiftUI

struct SessionSuccessView: View {
    @State private var currentSUDs: Double = 0
    @State private var highSUDs: Double = 0
    
//    @State private var path = NavigationPath()
    
    @State private var sessionCompleted: Bool = false
    
    @State private var counter: Int = 0

    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color.darkGreen
                    .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 30) {
                    
                    Text("Well done! 🎉")
                        .font(.largeTitle).bold()
                    
                    Text("You successfully completed an exposure session.")
                        .multilineTextAlignment(.center)
                    
                    Text("How would you rate your Subjective Units of Distress (SUDs) out of 10, right now?")
                        .font(.title3).bold()
                        .multilineTextAlignment(.center)
                    
                    Text("\(currentSUDs, specifier: "%.0f")")
                        .font(.largeTitle)
                        .fontWeight(.black)
                    
                    Slider(value: $currentSUDs, in: 0...10, step: 1)
                        .padding(.horizontal, 20)
                    
                    Text("And how high did your SUDs get during the session?")
                        .font(.title3).bold()
                        .multilineTextAlignment(.center)
                    
                    Text("\(highSUDs, specifier: "%.0f")")
                        .font(.largeTitle)
                        .fontWeight(.black)
                    
                    Slider(value: $highSUDs, in: 0...10, step: 1)
                        .padding(.horizontal, 20)
                    
                    Spacer()

                    NavigationLink("Complete session", destination: HomeView())
                        .font(.title).bold()
                        .buttonStyle(.borderedProminent)
                    
                }
                .padding(30)
//                .onChange(of: sessionCompleted) { _, _ in
//                    if sessionCompleted {
//                        path.append("completedSession")
//                    }
//                }
//                .navigationDestination(for: String.self) { value in
//                    if value == "completedSession" {
//                        HomeView()
//                    }
//                }
                .onAppear {
                    counter += 1
                }
                .confettiCannon(counter: $counter, num: 100, colors: [.extraDarkGreen, .darkOrange, .darkPink, .lightPurple], confettiSize: 10, opacity: 0.5, radius: 400)
                .navigationBarBackButtonHidden()
            }
        }
        
    }
}

#Preview {
    SessionSuccessView()
}
