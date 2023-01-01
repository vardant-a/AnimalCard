//
//  Card.swift
//  AnimalCard
//
//  Created by Aleksei on 15.12.2022.
//

import SwiftUI

// MARK: - CardModel

struct Card: Identifiable {
    var id: String = UUID().uuidString
    var imageName: String
    var isRotated: Bool = false
    var extraOffset: CGFloat = 0
    var scale: CGFloat = 1
    var zIndex: Double = 0
}
