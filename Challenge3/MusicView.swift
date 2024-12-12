//
//  MusicView.swift
//  Challenge3
//
//  Created by Mathew Blanc on 11/12/24.
//

import SwiftUI

struct MusicView: View {
    var body: some View {
        VStack {
            Text("All music by Scott Buckley - released under CC-BY 4.0. www.scottbuckley.com.au")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    MusicView()
}
