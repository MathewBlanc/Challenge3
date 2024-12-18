//
//  MusicView.swift
//  Challenge3
//
//  Created by Mathew Blanc on 11/12/24.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        ZStack {
            
            Color.accentColor
                .ignoresSafeArea()
                .accessibilityHidden(true)
            
            VStack(spacing: 20) {
                Text("Credits")
                    .font(.title).bold()
                Text("All music by Scott Buckley - released under CC-BY 4.0. www.scottbuckley.com.au")
                Text("Bunny model: (https://skfb.ly/6nI9R) by yellokab is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).")
                Spacer()
                
            }
            .multilineTextAlignment(.center)
            .padding()
            .padding(.top, 20)
        }
    }
}

#Preview {
    CreditsView()
}
