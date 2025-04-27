//
//  MiniGamesView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI

struct MiniGamesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader{ g in
            ZStack{
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
//                    .frame(width: g.size.width, height: g.size.height)
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
                                .frame(width: g.size.width * 0.1)
                        }
                    }
                    .frame(width: g.size.width * 0.9)
                    
                    Image("miniGames")
                        .resizable()
                        .scaledToFit()
                        .frame(width: g.size.width * 0.9)
                    
                        .overlay(
                            ZStack{
                                Image("rec")
                                    .resizable()
                                    .frame(width: g.size.width * 0.7, height: g.size.height * 0.45)
                                    .padding(.top, 10)
                                
                                VStack(spacing: g.size.width * 0.05){
                                    HStack(spacing: g.size.width * 0.07){
                                        
                                        // Мини-игра: "Угадай число"
                                        NavigationLink {
                                            GuessTheNumberView()
                                        } label: {
                                            Image("achieve")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.23)

                                        }

                                        
                                            // "Найди пару"
                                        NavigationLink {
                                            MemoryGameView()
                                        } label: {
                                            Image("achieve")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.23)

                                        }

                                    }
                                    HStack(spacing: g.size.width * 0.07){
                                        NavigationLink {
                                            MemorySequnceGameView()
                                        } label: {
                                            Image("achieve")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.23)

                                        }

                                            // "Лабиринт"
                                            NavigationLink {
                                                MazeGameView()
                                            } label: {
                                                Image("achieve")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.23)

                                            }

                                    }
                                    
                                }
                            }
                                .padding(.top, g.size.height * 0.1)
                            //                        ,alignment: .bottom
                            
                        )
                    
                }
                .padding(.bottom, g.size.height * 0.3)

            }
            .navigationBarBackButtonHidden()
            
        }
        
    }
}

#Preview {
    MiniGamesView()
}
