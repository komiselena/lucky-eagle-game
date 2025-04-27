//
//  WinView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI

struct WinView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var gameData: GameData

    var body: some View {
        GeometryReader { g in
            ZStack {
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        Image("coins")
                        .resizable()
                        .rotationEffect(Angle(degrees: -120))
                        .frame(width: g.size.width * 0.5)
                        .offset(x: -50, y: -120)
                        ,alignment: .leading
                    )
                    .overlay(
                        Image("coins")
                            .resizable()
                            .rotationEffect(Angle(degrees: 10))
                            .frame(width: g.size.width * 0.7)
                            .offset(x: 100, y: -30)

                        ,alignment: .trailing
                    )
                Image("EagleWin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: g.size.width * 0.8)
                    .offset(y: -(g.size.height * 0.2))

                VStack{
                    
                    Image("Win")
                        .resizable()
                        .scaledToFit()
                        .frame(width: g.size.width * 0.53)
                    Spacer()
                    
                    Image("+100")
                        .resizable()
                        .scaledToFit()
                        .frame(width: g.size.width * 0.25)
                    
                    HStack(spacing: 100){
                            Button {
                                dismiss()
                                gameViewModel.isGameOver = false
                                gameData.coins += 100
                            } label: {
                                Image("Menu")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.2)

                            }


                        Button {
                            gameViewModel.isGameOver = false
                            gameData.coins += 100

//                            dismiss()
                        } label: {
                            Image("Retry")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.2)

                        }

                        
                    }
                }
                .padding(.vertical, g.size.height * 0.1)
                .padding(.bottom, g.size.height * 0.2)

//                .frame(height: g.size.height)
            }
            
        }
    }

}

//#Preview {
//    WinView()
//}
