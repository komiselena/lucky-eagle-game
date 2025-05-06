//
//  MiniGamesView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI

struct MiniGamesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameData: GameData
    
    var body: some View {
        GeometryReader{ g in
            ZStack{
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0){
                    
                    BackgroundRectangle()
                        .frame(width: g.size.width , height: g.size.height * 0.9)

                    
                        .overlay(
                            VStack{
                                Image("Mini games")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.3)
                                    .padding(.bottom)
                                    
                                    VStack(spacing: g.size.width * 0.05){
                                        HStack(spacing: g.size.width * 0.07){
                                            
                                            // Мини-игра: "Угадай число"
                                            NavigationLink {
                                                GuessTheNumberView(gameData: gameData)
                                            } label: {
                                                Image("achieve")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.3)
                                                
                                            }
                                            
                                            
                                            // "Найди пару"
                                            NavigationLink {
                                                MemoryGameView(gameData: gameData)
                                            } label: {
                                                Image("achieve")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.3)

                                            }
                                            
                                        }
                                        HStack(spacing: g.size.width * 0.07){
                                            NavigationLink {
                                                MemorySequnceGameView(gameData: gameData)
                                            } label: {
                                                Image("achieve")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.3)

                                            }
                                            
                                            // "Лабиринт"
                                            NavigationLink {
                                                MazeGameView(gameData: gameData)
                                            } label: {
                                                Image("achieve")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.3)

                                            }
                                            
                                        }
                                        
                                }
                            }
                                .frame(height: g.size.height * 0.6)
                            
                        )
                    
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
    MiniGamesView(gameData: GameData())
}
