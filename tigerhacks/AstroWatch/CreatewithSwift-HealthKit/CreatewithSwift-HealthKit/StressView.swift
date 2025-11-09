//
//  StressView.swift
//  AstroWatch
//
//  Created by Anika Vydier on 11/9/25.
//

import SwiftUI

struct StressView: View {
    @StateObject private var viewModel = StressViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Stress Recommendations")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                if let recommendation = viewModel.recommendation {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AstroWatch LLM Recommendation:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(recommendation.replacingOccurrences(of: "\\n", with: "  "))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil) // allow multiple lines
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .padding()
                    .transition(.opacity)
                }
            }
            .padding()
        }
        .background(
            Image("bg1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            // Automatically fetch after a 10-second delay
            Task {
                try? await Task.sleep(nanoseconds: 0) // 10 seconds
                await viewModel.fetchRecommendation()
            }
        }
    }
}
