//
//  HomeView.swift
//  Challenge3
//
//  Created by Mathew Blanc on 12/12/24.
//

import SwiftUI
import TipKit

struct HomeView: View {
    
    @State private var isPresented: Bool = false
    
    var arTip = ARSessionTip()
    var sliderTip = SliderSessionTip()
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                Color.darkGreen
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("Welcome to Climb")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 40)
                    
                    Text("Choose from the session type options below to begin working towards your phobia goal. ")
                    
                    Text("We will never show you any phobia stimuli without warning you first")
                        .bold()
                    
                    Spacer()
                    
                    
                    VStack(spacing: 20) {
                        NavigationLink("Start slider session") {
                            SliderSessionView()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.title)
                        
                        Button("info", systemImage: "questionmark.circle") {
                            SliderSessionTip.isVisible.toggle()
                            try? Tips.resetDatastore()
                        }
                        .popoverTip(sliderTip, arrowEdge: .bottom)
                        //                .onTapGesture {
                        //                    arTip.invalidate(reason: .actionPerformed)
                        //                }
//                        TipView(arTip)
                        
                    }
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Button("Start AR session") {
                            isPresented.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.title)
                        Button("info", systemImage: "questionmark.circle") {
                            ARSessionTip.isVisible.toggle()
                            try? Tips.resetDatastore()
                        }
                        .popoverTip(arTip, arrowEdge: .bottom)

                    }
                    
                    Spacer()
                }
                .padding()
                .multilineTextAlignment(.center)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        CreditsView()
                    } label: {
                        Image(systemName: "info.circle")
                    }

                }
            }
            
            

        }
        .fullScreenCover(isPresented: $isPresented, content: {
            ARSessionView(isPresented: $isPresented)
        })
        .navigationBarBackButtonHidden()
        .task {
            do {
                try Tips.resetDatastore()
                try Tips.configure()
            }
            catch {
                // Handle TipKit errors
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HomeView()
}

struct ARSessionTip: Tip {
    
    @Parameter
    static var isVisible: Bool = false

    var rules: [Rule] {
        [
            // Define a rule based on the app state.
            #Rule(Self.$isVisible) {
                // Set the conditions for when the tip displays.
                $0 == true
            }
        ]
    }
    
    var title: Text {
        Text("How does an AR Session work?")
    }
    
    var message: Text? {
        Text("When you start the session, you can use your camera to view a virtual example of your chosen stimulus. Tapping on the stimulus will make it move towards you a small amount")
    }
    
    var image: Image? {
        Image(systemName: "arkit")
    }
}

struct SliderSessionTip: Tip {
    
    @Parameter
    static var isVisible: Bool = false

    var rules: [Rule] {
        [
            // Define a rule based on the app state.
            #Rule(Self.$isVisible) {
                // Set the conditions for when the tip displays.
                $0 == true
            }
        ]
    }
    
    var title: Text {
        Text("How does a Slider Session work?")
    }
    
    var message: Text? {
        Text("When you start the session, you will use an on-screen slider to increase the size of a photo of your chose stimulus. The image's initial size is 1 pixel (very small!)")
    }
    
    var image: Image? {
        Image(systemName: "photo.fill.on.rectangle.fill")
    }
}
