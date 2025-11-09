
//  ContentView.swift
//  HealtKitInformation
//
//  Created by Matteo Altobello on 16/04/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = HealthDataViewModel()

    var body: some View {
        TabView {
                    HealthDataView()
                .tabItem {
                    VStack{
                        Image("home").renderingMode(.template)
                            .frame(width: 24, height: 24)
                        Text("Home")
                    }
                }
                    CardioView()
                        .tabItem {
                            VStack{
                                Image("cog").renderingMode(.template)
                                    .frame(width: 24, height: 24)
                                Text("Cognitive")
                            }
                        }
            
                    CognitiveView()
                        .tabItem {
                            VStack{
                                Image("cardio").renderingMode(.template)
                                    .frame(width: 24, height: 24)
                                Text("Cardio")
                            }
                        }

                    StressView()
                        .tabItem {
                            VStack{
                                Image("stress").renderingMode(.template)
                                    .frame(width: 24, height: 24)
                                Text("Stress")
                            }
                        }
                }
                .accentColor(Color(hex: "#57E2E5"))
    }
}

struct CardioView: View {
    var body: some View {
        Text("Cardio Page")
    }
}

struct CognitiveView: View {
    var body: some View {
        Text("Cognitive Page")
    }
}

struct StressView: View {
    var body: some View {
        Text("Stress Page")
    }
}

#Preview {
    ContentView()
}
