//
//  HealthDataView.swift
//  CreatewithSwift-HealthKit
//
//  Created by Anika Vydier on 11/8/25.
//
import SwiftUI
struct HealthDataView: View {
    @State private var viewModel = HealthDataViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("bg1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    if let error = viewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    }
                    else if viewModel.isAuthorized {
                        
                        //  Added ScrollView so content (including the button) is always visible
                        ScrollView {
                            VStack(spacing: 24) {
                                VStack(spacing: 16) {
                                    HealthInfoView(
                                        label: Text("Heart Rate"),
                                        value: Text("\(Int(viewModel.stepCount)) steps"),
                                        color: Color(hex: "#1E1E1E").opacity(0.5),
                                        textColor: Color(hex: "#F0F4EF")
                                    )
                                    
                                    HealthInfoView(
                                        label: Text("Cognitive Measure"),
                                        value: Text(String(format: "%.1f bpm", viewModel.heartRate)),
                                        color: Color(hex: "#1E1E1E").opacity(0.5),
                                        textColor: Color(hex: "#F0F4EF")
                                    )
                                    
                                    HealthInfoView(
                                        label: Text("Stress"),
                                        value: Text(String(format: "%.1f kcal", viewModel.activeEnergy)),
                                        color: Color(hex: "#1E1E1E").opacity(0.5),
                                        textColor: Color(hex: "#F0F4EF")
                                    )
                                }
                                
                                // 🧪 Test Notification Button
                                Button("Send Hello World Notification") {
                                    Task {
                                        await viewModel.requestNotificationPermission()
                                        viewModel.sendNotification(
                                            title: "Hello Astronaut 🌍",
                                            body: "This is your test notification!"
                                        )
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 12)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        // End ScrollView
                        
                    } else {
                        ProgressView("Requesting HealthKit authorization...")
                            .padding()
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Health Data")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#F0F4EF"))
                }
            }
        }
    }
}

struct HealthInfoView<Label: View, Value: View>: View {
    let label: Label
    let value: Value
    var color: Color = .orange
    var textColor: Color = .white

    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(color.gradient)
            .frame(width: 200, height: 150)
            .overlay {
                VStack {
                    label
                    value
                }
                .font(.title2)
                .fontWeight(.bold)
                
                .foregroundColor(.white)
                .padding()
            }
    }
}
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .whitespacesAndNewlines))
        var hexNumber: UInt64 = 0
        if scanner.scanString("#") != nil {}
        scanner.scanHexInt64(&hexNumber)
        
        let r = Double((hexNumber & 0xFF0000) >> 16) / 255
        let g = Double((hexNumber & 0x00FF00) >> 8) / 255
        let b = Double(hexNumber & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}
