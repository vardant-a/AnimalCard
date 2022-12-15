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

// MARK: Boomerang Card View
struct BoomerangCard: View {
    var isBlurEnabled: Bool = false
    var isRotationEnagled: Bool = false
    @Binding var cards: [Card]
    
    // MARK: - Gesture Properties
    @State var offset: CGFloat = 0
    @State var currentIndex: Int = 0

    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(cards.reversed()) { card in
                    CardView(card: card, size: size)
                    // MARK: - Moving only current active card
                        .offset(y: currentIndex == indexOf(card: card) ? offset: 0)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: offset == .zero)
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged(onChanged(value:))
                    .onEnded(onEnded(value:))
            )
        }
    }
    
    // MARK: - Gesture Calls
    func onChanged(value: DragGesture.Value) {
        // For Saftey
        offset = currentIndex == (cards.count - 1)
        ? 0 : value.translation.height
    }
    
    func onEnded(value: DragGesture.Value) {
        var translation = value.translation.height
        // Since we only need negative
        translation = (translation < 0 ? -translation: 0)
        translation = (currentIndex == (cards.count - 1) ? 0 : translation)
        
        // MARK: - Since our Card height = 220
        if translation > 110 {
            // MARK: - Deing Boomerang Effect And Updating Current Index
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.6)) {
                // Applying Rotation and Extra Offset
                cards[currentIndex].isRotated = true
                // Give Slightly Bigger Than Card Height
                cards[currentIndex].extraOffset = -350
                cards[currentIndex].scale = 0.7
            }
            
            // After a Little Delay Resetting Gesture Offset And Extra offset
            // Pushing Card into back using zIndex
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.6)) {
                    cards[currentIndex].zIndex = -100
                    for index in cards.indices {
                        cards[index].extraOffset = 0
                    }
                    // MARK: - Updating Current Index
                    if currentIndex != (cards.count - 1) {
                        currentIndex += 1
                    }
                    offset = .zero
                }
            }
            
            // After Animation Completed Resetting Rotation and Scaling and Setting Proper zIndex value
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for index in cards.indices {
                    if index == currentIndex {
                        // MARK: - Placing The Card At Right Index
                        // NOTE: Since the Current Index is Updated +1 Previeously
                        // So the current index will be -1 now
                        if cards.indices.contains(currentIndex - 1) {
                            cards[currentIndex - 1].zIndex = zIndex(card: cards[currentIndex - 1])
                        }
                    } else {
                        cards[index].isRotated = false
                        withAnimation(.linear) {
                            cards[index].scale = 1
                        }
                    }
                }
                if currentIndex == (cards.count - 1) {
                    //Resetting index to 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        for index in cards.indices {
                            // Reseting zIndex
                            cards[index].zIndex = 0
                        }
                        currentIndex = 0
                    }
                }
            }
        } else {
            offset = .zero
        }
    }
    
    func zIndex(card: Card) -> Double {
        let index = indexOf(card: card)
        let totalCount = cards.count
        
        return currentIndex > index
        ? Double(index - totalCount)
        : cards[index].zIndex
    }
    
    @ViewBuilder
    func CardView(card: Card, size: CGSize) -> some View {
        let index = indexOf(card: card)
        //MARK: Your custom View
        Image(card.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .blur(radius: card.isRotated && isBlurEnabled ? 6.5 : 0)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(card.scale, anchor: card.isRotated ? .center : .top)
            .rotation3DEffect(.init(degrees: isRotationEnagled && card.isRotated ? 360 : 0), axis: (x: 0, y: 0, z: 1))
            .offset(y: -ofseetFor(index: index))
            .offset(y: card.extraOffset)
            .scaleEffect(scaleFor(index: index), anchor: .top)
            .zIndex(card.zIndex)
    }
    
    // MARK: - Scale And Offset Values for Each Card
    // Adressing Negative Indexes
    func scaleFor(index value: Int) -> Double {
        let index = Double(value - currentIndex)
        // MARK: - I`m only showing three Card (Your Wish)
        if index >= 0 {
            if index > 3 {
                return 0.8
            }
            // For Each Card 0.06 Scale will be Reduced
            return 1 - (index / 15)
        } else {
            if -index > 3 {
                return 0.8
            }
            // For Each Card 0.06 Scale will be Reduced
            return 1 + (index / 15)
        }
    }
    
    func ofseetFor(index value: Int) -> Double {
        let index = Double(value - currentIndex)
        // MARK: - I`m only showing three Card (Your Wish)
        if index >= 0 {
            if index > 3 {
                return 30
            }
            // For Each Card 0.06 Scale will be Reduced
            return (index * 10)
        } else {
            if -index > 3 {
                return 30
            }
            // For Each Card 0.06 Scale will be Reduced
            return (-index * 10)
        }
    }
    
    func indexOf(card: Card) -> Int {
        if let index = cards.firstIndex(where: { CCard  in
            CCard.id == card.id
        }) {
            return index
        }
        return 0
    }
}
 
