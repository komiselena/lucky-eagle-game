//
//  GuessTheNumberView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import SwiftUI

struct GuessTheNumberView: View {
    @StateObject private var game = GuessTheNumberGame()
    @ObservedObject var gameData: GameData
    @Environment(\.dismiss) private var dismiss
    @State private var sliderValue: Double = 100

    var body: some View {
        GeometryReader { g in
            ZStack{
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing: 0){

                    ZStack(alignment: .center){
                        BackgroundRectangle()
                            .frame(width: g.size.width , height: g.size.height * 0.9)

                        
//                            .scaleEffect(2.8)
                        
                        VStack(spacing: 10) {
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

                            if game.bigger{
                                Image("Bigger")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.3)

//                                    .scaleEffect(0.7)
                            } else if game.smaller{
                                Image("Smaller")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.3)

                            }else if game.isWon {
                                Image("Number guessed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.5)
                                    .onAppear{
                                        gameData.coins += 100

                                    }

                            }else {
                                Image("Guess the number")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.5)

//                                    .scaleEffect(0.7)

                            }
                            VStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(game.bigger || game.smaller ? .red.opacity(0.8) : Color.brown1)
                                        .frame(width: g.size.width * 0.2, height: g.size.height * 0.1)
                                    Text("\(Int(sliderValue))")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                
                                Slider(value: $sliderValue, in: 1...999, step: 1)
                                    .accentColor(Color("brown1"))
                                    .frame(width: g.size.width * 0.3, height: g.size.height * 0.04)
                            }

//                            Spacer()
                            Button(action: {
                                game.guess = String(Int(sliderValue))
                                game.checkGuess()

                            }) {
                                if game.smaller || game.bigger {
                                    Image("Retry")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.18)
                                    
                                } else if game.isWon {
                                    Image("Group 10")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.2)
                                    
                                } else {
                                    Image("guess")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.18)
                                    
                                }
                                
                            }
                            .padding(.horizontal)
//                            .frame(maxWidth: 300)
                            
                            Spacer()
                        }
                        .padding(.top, g.size.height * 0.1)
                    }
                    .frame(height: g.size.height * 0.8)

                }


            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image("crossButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: g.size.width * 0.1, height: g.size.width * 0.1)

                    }
                    
                    
                }

            }
            .frame(width: g.size.width, height: g.size.height)

            .navigationBarBackButtonHidden()

        }
    }
}

#Preview {
    GuessTheNumberView(gameData: GameData())
}
