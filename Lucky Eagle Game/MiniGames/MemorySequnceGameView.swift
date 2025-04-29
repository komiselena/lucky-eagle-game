//
//  MemorySequnceGameView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 27.04.2025.
//


import SwiftUI

struct MemorySequnceGameView: View {
    @StateObject private var viewModel = MemoryGameViewModel()
    @ObservedObject var gameData: GameData
    @Environment(\.dismiss) private var dismiss
    
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
                        
                        VStack(spacing: 10) {
                            if viewModel.isGameOver && viewModel.isWon == false {
                                VStack(spacing: 16) {
                                    Image("The sequence is wrong")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.4)
                                    
                                    Button(action: {
                                        viewModel.startGame()
                                    }, label: {
                                        Image("Retry")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.18)
                                        
                                    })
                                    .padding(.bottom)
                                }
                            } else if viewModel.isGameOver && viewModel.isWon {
                                VStack(spacing: 16) {
                                    Image("The sequence is correct")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.4)
                                    Image("Group 10")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.2)
                                    
                                    Button(action: {
                                        dismiss()
                                        gameData.coins += 100
                                    }, label: {
                                        Image("Take")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: g.size.width * 0.18)
                                        
                                    })
                                }
                                
                            } else {
                                
                                
                                VStack(spacing: 20) {
                                    
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
                                    
                                    
                                    Image("Repeat the sequence")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.4)
                                    
                                    VStack(spacing: 10) {
                                        
                                        if viewModel.showingSequence {
                                            if let card = viewModel.showCard {
                                                Image(card)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.13, height: g.size.width * 0.13)
                                                    .transition(.scale)
                                            }
                                        } else {
                                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                                                ForEach(["card1", "card2", "card3", "card4", "card5", "card6"], id: \.self) { card in
                                                    Button {
                                                        viewModel.selectCard(card)
                                                    } label: {
                                                        Image(card)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: g.size.width * 0.08, height: g.size.width * 0.08)
                                                        //                                                        .padding(6)
                                                            .cornerRadius(12)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: g.size.height * 0.4)
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, g.size.height * 0.1)


                    }
                    .onAppear {
                        viewModel.startGame()
                    }
                    .animation(.easeInOut, value: viewModel.showCard)

                }
                .frame(width: g.size.width, height: g.size.height)
                .padding(.bottom, g.size.height * 0.3)
            }
        }
        .navigationBarBackButtonHidden()

    }
}


#Preview {
    MemorySequnceGameView(gameData: GameData())
}
