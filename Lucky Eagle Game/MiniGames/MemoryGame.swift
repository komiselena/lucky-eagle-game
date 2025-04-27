//
//  MemoryGame.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import Foundation

struct Card: Identifiable {
    let id = UUID()
    let imageName: String
    var isFlipped = false
    var isMatched = false
}

class MemoryGame: ObservableObject {
    @Published var cards: [Card] = []
    private var indexOfFirstCard: Int?

    init(images: [String]) {
        startGame(with: images)
    }

    func startGame(with images: [String]) {
        let pairs = images + images
        cards = pairs.shuffled().map { Card(imageName: $0) }
    }

    func flipCard(at index: Int) {
        guard !cards[index].isMatched, !cards[index].isFlipped else { return }

        cards[index].isFlipped.toggle()

        if let firstIndex = indexOfFirstCard {
            if cards[firstIndex].imageName == cards[index].imageName {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.cards[firstIndex].isFlipped = false
                    self.cards[index].isFlipped = false
                }
            }
            indexOfFirstCard = nil
        } else {
            indexOfFirstCard = index
        }
    }
}
