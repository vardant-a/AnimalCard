//
//  HomeView.swift
//  AnimalCard
//
//  Created by Aleksei on 15.12.2022.
//

import SwiftUI

struct HomeView: View {
    // MARK: Sample Cards
    @State var cards: [Card] = []
    // MARK: View Properties
    @State var isBlurEnabled: Bool = false
    @State var isRotationEnabled: Bool = true
    var body: some View {
        VStack(spacing: 20) {
            Toggle("Enable blur", isOn: $isBlurEnabled)
            Toggle("Turn on Rotation", isOn: $isRotationEnabled)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding()
        .background {
            Color.black
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: Boomerang Card View
