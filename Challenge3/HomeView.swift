//
//  HomeView.swift
//  Challenge3
//
//  Created by Mathew Blanc on 12/12/24.
//

import SwiftUI

struct HomeView: View {
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            
            Spacer() 

                        
            NavigationLink("Slider session") {
                SliderSessionView()
            }
            .buttonStyle(.borderedProminent)
            Spacer()

            Button("AR session") {
                isPresented.toggle()
            }
            .buttonStyle(.borderedProminent)
            Spacer()

        }
        .fullScreenCover(isPresented: $isPresented, content: {
            ARSessionView(isPresented: $isPresented)
        })
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    HomeView()
}
