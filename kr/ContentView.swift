import SwiftUI

// --- NEW: Add the AppSettings to the environment ---
// Note: You must also ensure your ViewModel has access to the baseCurrency,
// likely by updating its fetchRates function signature.

struct ContentView: View {
    // 1. Instantiate both the ViewModel and the Settings Model
    @StateObject private var settings = AppSettings()
    @StateObject private var viewModel = ExchangeRateViewModel()
    
    // The list of currencies to display is now taken from settings
    var body: some View {
        NavigationView {
            VStack {
                // ... (Loading, Error, and Empty States remain the same) ...
                if viewModel.isLoading {
                    ProgressView("Fetching rates...")
                        .padding()
                }
                else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                // --- 4. Data Loaded State (UPDATED) ---
                else if let rates = viewModel.ratesResponse {
                    List {
                        // Header with base currency and last update time
                        Section(header: Text("Base Currency: \(rates.baseCode)").font(.headline)) {
                            Text("Last Updated: \(formatUpdateTime(rates.timeLastUpdateUtc))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                            
                        // Display the conversion rates for SELECTED currencies from settings
                        Section("Conversion Rates") {
                            // !!! UPDATED to use settings.displayedCurrencies !!!
                            ForEach(settings.displayedCurrencies, id: \.self) { currencyCode in
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
                
                else {
                    Text("No exchange rates data available.")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Global Exchange Rates")
            
            // 6. Use .task and .onChange to call the fetch function
            // !!! UPDATED to use settings.baseCurrency !!!
            .task {
                await viewModel.fetchRates(baseCurrency: settings.baseCurrency)
            }
            
            // Refetches data immediately when the base currency changes
            .onChange(of: settings.baseCurrency) { oldValue, newValue in
                if oldValue != newValue {
                    Task {
                        await viewModel.fetchRates(baseCurrency: newValue)
                    }
                }
            }
            
            // --- NEW: Toolbar for Settings Button ---
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(settings: settings)
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
    }
    
    // Helper function... (remains the same)
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
