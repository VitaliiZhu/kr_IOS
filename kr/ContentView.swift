import SwiftUI

struct ContentView: View {
    // 1. Instantiate the ViewModel using @StateObject
    @StateObject private var viewModel = ExchangeRateViewModel()
    
    // Example target currencies to display in the list
    let displayCurrencies = ["EUR", "JPY", "GBP", "CAD", "AUD", "INR"]
    
    var body: some View {
        NavigationView {
            VStack {
                // --- 2. Loading State ---
                if viewModel.isLoading {
                    ProgressView("Fetching rates...")
                        .padding()
                }
                
                // --- 3. Error State ---
                else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                // --- 4. Data Loaded State ---
                else if let rates = viewModel.ratesResponse {
                    List {
                        // Header with base currency and last update time
                        Section(header: Text("Base Currency: \(rates.baseCode)").font(.headline)) {
                            Text("Last Updated: \(formatUpdateTime(rates.timeLastUpdateUtc))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Display the conversion rates for selected currencies
                        Section("Conversion Rates") {
                            ForEach(displayCurrencies, id: \.self) { currencyCode in
                                HStack {
                                    Text(currencyCode)
                                        .bold()
                                    Spacer()
                                    // Safely access the rate and format it
                                    if let rate = rates.conversionRates[currencyCode] {
                                        Text(String(format: "%.4f", rate))
                                    } else {
                                        Text("N/A")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                
                // --- 5. Initial/Empty State (Optional) ---
                else {
                    Text("No exchange rates data available.")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Global Exchange Rates")
            // 6. Use .task to call the async function when the view appears
            .task {
                await viewModel.fetchRates(baseCurrency: "USD") // or "EUR", etc.
            }
        }
    }
    
    // Helper function to format the UTC time string for display
    private func formatUpdateTime(_ utcTime: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: utcTime) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return utcTime
    }
}

// Preview struct (Xcode 15+)
#Preview {
    ContentView()
}
