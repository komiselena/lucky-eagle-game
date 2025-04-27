//
//  MemorySequenceGame.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import Foundation
import SwiftUI

class MemoryGameViewModel: ObservableObject {
    @Published var sequence: [String] = []
    @Published var userInput: [String] = []
    @Published var currentStep: Int = 0
    @Published var showingSequence = true
    @Published var showCard: String? = nil
    @Published var isGameOver = false
    @Published var isWon = false
    @Published var coins = 0

    private let cards = ["card1", "card2", "card3", "card4", "card5", "card6"]

    func startGame() {
        sequence = []
        userInput = []
        currentStep = 3
        isGameOver = false
        isWon = false
        coins = 0
        nextRound()
    }

    func nextRound() {
        userInput = []
        showingSequence = true
        sequence = (0..<currentStep).map { _ in cards.randomElement()! }
        showSequence()
    }

    private func showSequence() {
        Task {
            for card in sequence {
                await MainActor.run {
                    showCard = card
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    showCard = nil
                }
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
            await MainActor.run {
                showingSequence = false
            }
        }
    }

    func selectCard(_ card: String) {
        guard !showingSequence else { return }
        userInput.append(card)

        if !sequence.prefix(userInput.count).elementsEqual(userInput) {
            isGameOver = true
            isWon = false
        } else if userInput.count == sequence.count {
            if currentStep == 6 {
                coins += 30
                isGameOver = true
                isWon = true
            } else {
                currentStep += 1
                nextRound()
            }
        }
    }
}
