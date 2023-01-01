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
            
            BoomerangCard(isBlurEnabled: isBlurEnabled, isRotationEnagled: isRotationEnabled, cards: $cards)
                .frame(height: 220)
                .padding(.horizontal)
        }
        .padding()
        .background {
            Color.black
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: { setupCard() } )
    }
    
    // MARK: - Setting Up Card`s
    func setupCard() {
        for index in 0...3 {
            cards.append(.init(imageName: "Card \(index)"))
        }
        // For infinite cards
        // Logic is Simple. Place the First Card at last
        // When the last card is arriver, set index to 0
        if var first = cards.first { first.id = UUID().uuidString
            cards.append(first)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 
