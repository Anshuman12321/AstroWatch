import SwiftUI

struct AstroData: Codable {
    var activeEnergyBurned: Double
    var vo2Max: Double
    var lowCardioFitnessEvent: Int
    var height: Double
    var bodyMass: Double
    var bodyMassIndex: Double
    var leanBodyMass: Double
    var bodyFatPercentage: Double
    var heartRate: Int
    var lowHeartRateEvent: Int
    var highHeartRateEvent: Int
    var oxygenSaturation: Int
    var bodyTemperature: Double
    var bloodPressure_systolic: Int
    var bloodPressure_diastolic: Int
    var respiratoryRate: Int
    var sleepAnalysis_hours: Double
    var uvExposure_minutes: Double
    var selection: String
}

@MainActor
class AstroViewModel: ObservableObject {
    @Published var result: String = ""
    
    func sendAstroData(_ data: AstroData) async {
        guard let url = URL(string: "http://18.221.238.135:8000/evaluate") else {
            result = "Invalid URL"
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(data)

            let (responseData, _) = try await URLSession.shared.data(for: request)
            if let responseString = String(data: responseData, encoding: .utf8) {
                result = responseString
            } else {
                result = "Unable to read response"
            }
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
    }
}


