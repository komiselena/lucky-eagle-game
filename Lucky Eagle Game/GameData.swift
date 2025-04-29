//
//  GameData.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import Foundation


class GameData: ObservableObject {
    
    @Published var boughtSkinId: [Int] = [1]
    @Published var boughtLocId: [Int] = [1]

    @Published var coins: Int {
        didSet {
            UserDefaults.standard.set(coins, forKey: "coins")
        }
    }
    
    init() {
        let savedCoins = UserDefaults.standard.integer(forKey: "coins")
        if savedCoins == 0 {
            self.coins = 5568
            UserDefaults.standard.set(5568, forKey: "coins")
        } else {
            self.coins = savedCoins
        }
    }

    
    func addCoins(_ amount: Int){
        coins += amount
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if coins >= amount {
            coins -= amount
            return true
        } else {
            return false
        }
    }
    
}

