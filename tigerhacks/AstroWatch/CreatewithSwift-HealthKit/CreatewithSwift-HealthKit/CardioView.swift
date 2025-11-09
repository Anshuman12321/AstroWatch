import SwiftUI

struct CardioView: View {
    @StateObject private var viewModel = CardioViewModel()
    
    var body: some View {
        ZStack {
            Image("bg1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 20) {
                    Text("Cardio Recommendations")
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
                await viewModel.fetchRecommendation()
            }
        }
    }
}
