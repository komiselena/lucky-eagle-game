//
//  MazeGameView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 26.04.2025.
//

import SwiftUI
import SpriteKit


#Preview {
    MazeGameView(gameData: GameData())
}


struct MazeGameView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var scene = MazeGameScene(size: CGSize(width: 196, height: 196))
    @ObservedObject var gameData: GameData
    @State private var timeLeft = 90
    @State private var timer: Timer?
    @State private var showWin = false
    @State private var coins = 0
    
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
                        VStack{
                            if showWin{
                                VStack{
                                Image("Good JOb You made it the finish lne")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.35)
                                
                                    Image("Group 10")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.2)
                                
                                Image("Take")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.2)
                                    .onTapGesture {
                                        gameData.coins += 20
                                        dismiss()
                                    }

                                }
                                

                            } else{
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
                                
                                Image("Find way to the cup")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.4)
                                
                                HStack(spacing: 60) {
                                    SpriteView(scene: scene)
                                        .frame(width: g.size.width * 0.2, height: g.size.width * 0.2)
                                        .border(Color.black)
                                        .padding(.leading, 20)
                                    
                                    VStack (spacing: 0){
                                        Text("TIME: \(timeLeft)")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .padding(10)
                                        
                                        
                                        Button(action: { scene.movePlayer(dx: 0, dy: scene.moveStep) }) {
                                            Image("mazeArrowControl")
                                                .resizable()
                                                .frame(width: g.size.width * 0.06, height: g.size.width * 0.06)
                                        }
                                        HStack(spacing: 0) {
                                            Button(action: { scene.movePlayer(dx: -scene.moveStep, dy: 0) }) {
                                                Image("mazeArrowControl")
                                                    .resizable()
                                                    .frame(width: g.size.width * 0.06, height: g.size.width * 0.06)
                                                    .rotationEffect(.degrees(-90))
                                            }
                                            Button(action: {  }) {
                                                Image("mazeArrowControl")
                                                    .resizable()
                                                    .opacity(0.0)
                                                    .frame(width: g.size.width * 0.06, height: g.size.width * 0.06)
                                                    .rotationEffect(.degrees(-90))
                                            }
                                            
                                            Button(action: { scene.movePlayer(dx: scene.moveStep, dy: 0) }) {
                                                Image("mazeArrowControl")
                                                    .resizable()
                                                    .frame(width: g.size.width * 0.06, height: g.size.width * 0.06)
                                                    .rotationEffect(.degrees(90))
                                            }
                                        }
                                        Button(action: { scene.movePlayer(dx: 0, dy: -scene.moveStep) }) {
                                            Image("mazeArrowControl")
                                                .resizable()
                                                .frame(width: g.size.width * 0.06, height: g.size.width * 0.06)
                                                .rotationEffect(.degrees(180))
                                        }
                                        
                                    }
                                    .padding(.leading)
                                }
                            }
                        }

                    }
                    .frame(height: g.size.height * 0.8)

                }
                

//                .padding(.bottom, g.size.height * 0.3)
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

            .onAppear {
                startTimer()
                scene.onGameWon = {
                    timer?.invalidate()
                    showWin = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        gameData.coins += 20
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            showWin = false

                        }

                    }
                }
            }

        }
        .navigationBarBackButtonHidden()

        
        
    }
    
    func resetGame() {
        scene.resetGame()
        timeLeft = 90
        showWin = false
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}
