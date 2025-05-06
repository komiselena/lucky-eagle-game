//
//  SettingsView.swift
//  Lucky Eagle Game
//
//  Created by Mac on 25.04.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var musicManager = MusicManager.shared
    
    var body: some View {
        GeometryReader { g in
            ZStack{
                Image("bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing: -10){

                    
                    ZStack(alignment: .center){
                        Image("Settings")
                            .resizable()
                            .scaledToFit()
                            .frame(width: g.size.width * 0.8, height: g.size.height * 0.8)
                        HStack(spacing: 80){
                            VStack{
                                Image("Volume")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.width * 0.09)
                                Slider(value: $musicManager.audioPlayerVolume, in: 0...1)
                                    .frame(width: g.size.width * 0.2, height: g.size.height * 0.05)
                                    .accentColor(Color("brown1"))
                                    .padding(.horizontal, 20)
                                
                            }
                            Image("Group 32")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.09)

                            Image("Group 34")
                                .resizable()
                                .scaledToFit()
                                .frame(width: g.size.width * 0.07)


                        }
                        .padding(.bottom, g.size.height * 0.08)
                        .frame(width: g.size.width * 0.8)

                        
                    }
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

        }
//        .navigationBarBackButtonHidden()

    }
}

#Preview {
    SettingsView()
}
