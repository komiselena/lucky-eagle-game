//
//  MemoryMatchView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import SwiftUI

struct MemoryGameView: View {
    @StateObject private var game = MemoryGame(images: ["card1", "card2", "card3", "card4", "card5", "card6"])
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameData: GameData
    @State private var remainingAttempts = 5
    @State private var timeLeft = 45
    @State private var showReward = false
    @State private var timer: Timer?

    var body: some View {
        
        GeometryReader { g in
            ZStack{
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing: 0){
                    HStack{
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image("crossButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.12)
                            
                        }

                    }
                    
                    .frame(width: g.size.width )

                    ZStack(alignment: .center){
                        BackgroundRectangle()
                            .frame(width: g.size.width * 1, height: g.size.height * 0.85)

//                            .scaleEffect(2.8)
                        
                        VStack {
                            if game.lostMatch {
                                Image("Matches is wrong")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.3)
                                Button {
                                    game.restartGame()
                                    remainingAttempts = 5
                                } label: {
                                    Image("Retry")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.18)

                                }


                            }else if game.allMatchesFound {
                                Image("All matches found")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.5)
                                    .onAppear{
                                        gameData.coins += 100

                                    }

                                HStack(spacing: 8) {
                                    ForEach(game.cards.prefix(6), id: \.id) { card in
                                        Image(card.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.06)
                                            .cornerRadius(8)
                                    }
                                }
                                Image("Group 10")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.2)

                                Button {
                                    game.restartGame()
                                    remainingAttempts = 5

                                } label: {
                                    Image("Retry")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.18)

                                }



                            }else {
                                ZStack{
                                    Image("Group 8")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.15, height: g.size.height * 0.09)
                                    HStack{
                                        Image("coin")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.05)
                                        Text("\(gameData.coins)")
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 10)
                                    }
                                    .frame(width: g.size.width * 0.15, height: g.size.height * 0.09)
                                }
                                
                                Image("Find a match")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.3)
                                
                                
                                HStack {
                                    VStack {
                                        Text("TRIES: \(remainingAttempts)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    VStack {
                                        Text("TIME: \(timeLeft)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(width: g.size.width * 0.45)
                                .padding()
                                
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 010) {
                                    ForEach(Array(game.cards.enumerated()), id: \.element.id) { index, card in
                                        CardView(card: card)
                                            .onTapGesture {
                                                handleCardTap(index)
                                            }
                                            .frame(width: g.size.width * 0.06, height: g.size.width * 0.06)
                                    }
                                }
                                .frame(width: g.size.width * 0.6)


                                
                            }
                            Spacer()
                        }
                        .padding(.top, g.size.height * 0.1)

                    }
                }
                .frame(width: g.size.width, height: g.size.height)
                .padding(.bottom, g.size.height * 0.3)
            }
            .onAppear(perform: startTimer)
            .onDisappear(perform: stopTimer)

        }
        .navigationBarBackButtonHidden()


    }
    
    private func handleCardTap(_ index: Int) {
        guard !showReward else { return }
        
        let previousMatched = game.cards.filter { $0.isMatched }.count
        game.flipCard(at: index)
        let currentMatched = game.cards.filter { $0.isMatched }.count
        
        if currentMatched == previousMatched && game.indexOfFirstCard == nil {
            remainingAttempts -= 1
        }
        
        checkGameEnd()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeLeft -= 1
            if timeLeft <= 0 {
                game.lostMatch = true
                stopTimer()
                gameOver()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkGameEnd() {
        if game.cards.allSatisfy({ $0.isMatched }) {
            game.allMatchesFound = true
            stopTimer()
        } else if remainingAttempts <= 0 {
            game.lostMatch = true
            gameOver()
        }
    }
    
    private func gameOver() {
        stopTimer()
    }
}

struct CardView: View {
    var card: Card
    @State private var flipped = false
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    var body: some View {
        ZStack {
            Group {
                if flipped {
                    Image(card.imageName)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                } else {
                    Image("cardBack")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                }
            }
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(scale)
        }
        .onChange(of: card.isFlipped || card.isMatched) { newValue in
            flipCard(to: newValue)
        }
    }
    
    private func flipCard(to isFlipped: Bool) {
        withAnimation(.easeInOut(duration: 0.2)) {
            rotation = 90
            scale = 1.05
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            flipped = isFlipped
            withAnimation(.easeInOut(duration: 0.2)) {
                rotation = 0
                scale = 1.0
            }
        }
    }
}

extension AnyTransition {
    static var flipFromLeft: AnyTransition {
        .modifier(
            active: FlipEffect(angle: 90),
            identity: FlipEffect(angle: 0)
        )
    }
}

struct FlipEffect: ViewModifier {
    var angle: Double

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.3), value: angle)
    }
}

#Preview {
    MemoryGameView(gameData: GameData())
}
