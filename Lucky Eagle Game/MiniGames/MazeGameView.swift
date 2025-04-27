//
//  MazeGameView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import SwiftUI
import SpriteKit

struct MazeGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timeLeft: Int = 60
    @State private var gameWon: Bool = false
    @State private var coins: Int = 0
    
    private var scene: MazeGameScene {
        let scene = MazeGameScene()
        scene.size = CGSize(width: 300, height: 400)
        scene.scaleMode = .aspectFit
        
        scene.onTimeUpdate = { time in
            DispatchQueue.main.async {
                self.timeLeft = time
            }
        }
        
        scene.onGameWon = {
            DispatchQueue.main.async {
                self.gameWon = true
            }
        }
        
        return scene
    }

    var body: some View {
        GeometryReader { g in
            ZStack {
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                BackgroundRectangle()
                    .scaleEffect(2.8)


                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image("crossButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.15)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Таймер
                    Text("Time: \(timeLeft)")
                        .font(.title2)
                        .padding(.bottom)
                        .foregroundColor(.white)

                    ZStack(alignment: .topTrailing) {
                        SpriteView(scene: scene)
                            .frame(width: 300, height: 400)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                    }

                    // Кнопки управления
                    
                    HStack(spacing: 20) {
//                        SpriteView(scene: scene)
//                            .frame(width: g.size.width * 0.6, height: g.size.width * 0.6)
//                            .background(Color.clear)
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        VStack(spacing: 20) {
                            Button(action: {
                                scene.movePlayer(direction: .up)
                            }) {
                                Image("mazeArrowControl")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    scene.movePlayer(direction: .left)
                                }) {
                                    Image("mazeArrowControl")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .rotationEffect(.degrees(-90))
                                }
                                Button(action: {
                                    scene.movePlayer(direction: .down)
                                }) {
                                    Image("mazeArrowControl")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .rotationEffect(.degrees(90))
                                }

                            }
                            
                            Button(action: {
                                scene.movePlayer(direction: .right)
                            }) {
                                Image("mazeArrowControl")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .rotationEffect(.degrees(180))
                            }
                        }
                    }
                    .padding()


//                    Button(action: restartGame) {
//                        Image("Retry")
//                            .resizable()
//                            .frame(width: 60, height: 60)
//                            .padding()
//                    }
                }
                .frame(height: g.size.height * 0.8)
                .padding(.bottom, g.size.height * 0.3)

            }
        }
//        .onAppear(perform: startTimer)
        .navigationBarBackButtonHidden()
    }


//    private func restartGame() {
//        scene = MazeGameScene()
//        startTimer()
//    }
//
//    private func move(_ vector: CGVector) {
//        scene.movePlayer(by: vector)
//    }
}




#Preview {
    MazeGameView()
}
