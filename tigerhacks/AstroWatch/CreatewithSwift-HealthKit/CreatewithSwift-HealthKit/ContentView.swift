
//  ContentView.swift
//  HealtKitInformation
//
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
                                Image("cardio").renderingMode(.template)
                                    .frame(width: 24, height: 24)
                                Text("Cardio")
                            }
                        }
            
                    CognitiveView()
                        .tabItem {
                            VStack{
                                Image("cog").renderingMode(.template)
                                    .frame(width: 24, height: 24)
                                Text("Cognitive")
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



#Preview {
    ContentView()
}
