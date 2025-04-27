//
//  GuessTheNumberGame.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import Foundation

class GuessTheNumberGame: ObservableObject {
    @Published var target = Int.random(in: 1...999)
    @Published var guess = ""
    @Published var hint = ""
    @Published var isWon = false
    @Published var bigger = false
    @Published var smaller = false

    func checkGuess() {
        bigger = false
        smaller = false
        guard let guessNum = Int(guess) else { return }
        if guessNum < target {
            bigger = true
            hint = "Больше"
        } else if guessNum > target {
            hint = "Меньше"
            smaller = true
        } else {
            hint = "Угадал!"
            isWon = true
        }
    }

    func restart() {
        target = Int.random(in: 1...999)
        guess = ""
        hint = ""
        bigger = false
        smaller = false
        isWon = false
    }
}
