//
//  AchievementsView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI

struct AchievementsView: View {
    
    enum Tab {
        case complete
        case inProccess
    }
    
    @State private var selectedTab: Tab = .inProccess
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        GeometryReader{ g in
            ZStack{
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0){
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                Button(action: {
                                    selectedTab = .inProccess
                                }) {
                                    Image(selectedTab == .inProccess ? "InProccess1" : "inProccess")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.18)
                                }
                                
                                Button(action: {
                                    selectedTab = .complete
                                }) {
                                    Image(selectedTab == .complete ? "complete1" : "complete")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width * 0.18)
                                }
                                
                                Spacer()
                            }
                            .frame(width: g.size.width * 0.9)
                            .padding()
                            ZStack{
                                if selectedTab == .inProccess {
                                    ZStack(alignment: .center){
                                        BackgroundRectangle()
                                            .frame(width: g.size.width , height: g.size.height * 0.9)

                                        VStack(spacing: g.size.height * 0.1){
                                            Image("Achievements")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.4)
                                                
                                            HStack(spacing: 10){
                                                VStack{
                                                    ZStack{
                                                        Image("king sky")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: g.size.width * 0.1)
                                                        VStack{
                                                            Spacer()
                                                            Image("Collect 100 small birds in one flight.")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: g.size.width * 0.08)
                                                            
                                                        }
                                                        .frame(height: g.size.height * 0.26)
                                                        
                                                    }
                                                    Image("10coin")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: g.size.width * 0.11)
                                                    
                                                }
                                                VStack{
                                                    ZStack{
                                                        Image("fly catcher")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: g.size.width * 0.1)
                                                        VStack{
                                                            Spacer()
                                                            Image("Survive three strong gusts of wind")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: g.size.width * 0.08)
                                                            
                                                        }
                                                        .frame(height: g.size.height * 0.26)
                                                        
                                                    }
                                                    Image("10coin")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: g.size.width * 0.11)
                                                    
                                                }
                                                VStack{
                                                    ZStack{
                                                        Image("air maneuver")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: g.size.width * 0.1)
                                                        VStack{
                                                            Spacer()
                                                            Image("Dodge 5 spears in a row without stopping.")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: g.size.width * 0.08)
                                                            
                                                        }
                                                        .frame(height: g.size.height * 0.26)
                                                        
                                                    }
                                                    Image("10coin")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: g.size.width * 0.11)
                                                    
                                                }
                                                VStack{
                                                    ZStack{
                                                        Image("without fear")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: g.size.width * 0.1)
                                                        VStack{
                                                            Spacer()
                                                            Image("Start flying by avoiding obstacles for the first 30 seconds.")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: g.size.width * 0.08)
                                                            
                                                        }
                                                        .frame(height: g.size.height * 0.26)
                                                        
                                                    }
                                                    Image("10coin")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: g.size.width * 0.11)
                                                    
                                                }
                                                VStack{
                                                    ZStack{
                                                        Image("hunters feast")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: g.size.width * 0.1)
                                                        VStack{
                                                            Spacer()
                                                            Image("Collect 20 birds of the same species per game.")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: g.size.width * 0.08)
                                                            
                                                        }
                                                        .frame(height: g.size.height * 0.26)
                                                        
                                                    }
                                                    Image("10coin")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: g.size.width * 0.11)
                                                    
                                                }
                                                
                                            }
                                        }
                                        .frame(height: g.size.height * 0.8)
                                    }
                                    
                                    
                                } else {
                                    ZStack{
                                        BackgroundRectangle()
                                            .frame(width: g.size.width , height: g.size.height * 0.9)

                                        VStack(spacing: g.size.height * 0.1){
                                            Image("Achievements")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width * 0.4)
                                            
                                            
                                            HStack(spacing: 15) {
                                                Image("king sky")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.1)
                                                Image("fly catcher")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.1)
                                                Image("air maneuver")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.1)
                                                Image("without fear")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.1)
                                                Image("hunters feast")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width * 0.1)
                                            }
                                            Image("10coin")
                                                .resizable()
                                                .scaledToFit()
                                                .opacity(0.0)
                                                .frame(width: g.size.width * 0.11)
                                            
                                        }
                                        .frame(height: g.size.height * 0.8)

                                    }
                                    
                                }
                                
                                
                            }
                    }
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
    AchievementsView()
}
