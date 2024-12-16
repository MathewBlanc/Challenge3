//
//  MusicView.swift
//  Challenge3
//
//  Created by Mathew Blanc on 11/12/24.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        VStack {
            Text("All music by Scott Buckley - released under CC-BY 4.0. www.scottbuckley.com.au")
                .multilineTextAlignment(.center)
            Text("Bunny model: (https://skfb.ly/6nI9R) by yellokab is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).")
            Text("Bunny model: (https://skfb.ly/69z8N) by robk is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).")
        }
        .padding()
    }
}

#Preview {
    CreditsView()
}
