import SwiftUI

@MainActor
class StressViewModel: ObservableObject {
    @Published var recommendation: String? = nil

    func fetchRecommendation() async {
        // FastAPI endpoint URL
        guard let url = URL(string: "http://18.221.238.135:8000/evaluate") else {
            recommendation = "Invalid server URL"
            return
        }

        // Example payload (you’ll eventually replace with live sensor data)
        let astroData: [String: Any] = [
            "activeEnergyBurned": 540.0,
            "vo2Max": 42.1,
            "lowCardioFitnessEvent": 0,
            "height": 1.80,
            "bodyMass": 74.0,
            "bodyMassIndex": 22.8,
            "leanBodyMass": 60.0,
            "bodyFatPercentage": 15.5,
            "heartRate": 72,
            "lowHeartRateEvent": 0,
            "highHeartRateEvent": 0,
            "oxygenSaturation": 98,
            "bodyTemperature": 36.7,
            "bloodPressure_systolic": 120,
            "bloodPressure_diastolic": 78,
            "respiratoryRate": 16,
            "sleepAnalysis_hours": 7.5,
            "uvExposure_minutes": 15.0,
            "selection": "stress"
        ]

        do {
            // Convert to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: astroData)

            // Create POST request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            // Send request
            let (data, _) = try await URLSession.shared.data(for: request)

            // Decode plain string or simple JSON from the server
            if let decoded = try? JSONDecoder().decode([String: String].self, from: data),
               let result = decoded["recommendation"] ?? decoded["response"] {
                recommendation = result
            } else if let text = String(data: data, encoding: .utf8) {
                recommendation = text
            } else {
                recommendation = "Unexpected response format"
            }
        } catch {
            recommendation = "Network or decoding error: \(error.localizedDescription)"
        }
    }
}
