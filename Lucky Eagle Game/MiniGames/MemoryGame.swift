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
    @Published var allMatchesFound: Bool = false
    @Published var lostMatch: Bool = false
        @Published var cards: [Card] = []
        @Published var mistakes = 0
        @Published var timeRemaining = 45

        var indexOfFirstCard: Int?
        var originalImages: [String] = []

        init(images: [String]) {
            originalImages = images
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
                    checkAllMatchesFound()
                } else {
                    mistakes += 1
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

        func checkAllMatchesFound() {
            if cards.allSatisfy({ $0.isMatched }) {
                allMatchesFound = true
            }
        }

        func restartGame() {
            startGame(with: originalImages)
            mistakes = 0
            timeRemaining = 45
            allMatchesFound = false
            lostMatch = false
        }
    }
