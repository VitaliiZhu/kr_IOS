import SwiftUI

// --- NEW: Rename ContentView to MainTabView (Better naming convention) ---
struct MainTabView: View {
    @StateObject private var settings = AppSettings()
    @StateObject private var viewModel = ExchangeRateViewModel()
    
    var body: some View {
        // Wrap everything in a TabView
        TabView {
            // --- TAB 1: Exchange Rates List ---
            ExchangeRatesListView(settings: settings, viewModel: viewModel)
                .tabItem {
                    Label("Rates", systemImage: "list.bullet.clipboard")
                }
            
            // --- TAB 2: Interactive Converter ---
            ConverterView(settings: settings, viewModel: viewModel)
                .tabItem {
                    Label("Converter", systemImage: "arrow.left.arrow.right.circle.fill")
                }
        }
        // Task and onChange modifiers are kept here to manage data fetching for all tabs
        .task {
            await viewModel.fetchRates(baseCurrency: settings.baseCurrency)
        }
        .onChange(of: settings.baseCurrency) { oldValue, newValue in
            if oldValue != newValue {
                Task {
                    await viewModel.fetchRates(baseCurrency: newValue)
                }
            }
        }
    }
}

// --- NEW: Rename the original ContentView content to ExchangeRatesListView ---
// This keeps your code organized. You will need to move the original
// ContentView struct content into this new struct and update the
// references to `displayCurrencies` to use `settings.displayedCurrencies`.

struct ExchangeRatesListView: View {
    @ObservedObject var settings: AppSettings // Add settings access
    @ObservedObject var viewModel: ExchangeRateViewModel // Add view model access
    
    // Moved the formatting function inside the view to keep it clean
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
    
    var body: some View {
        NavigationView {
            VStack {
                // Your original ContentView Vack logic:
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
                else if let rates = viewModel.ratesResponse {
                    List {
                        Section(header: Text("Base Currency: \(rates.baseCode)").font(.headline)) {
                            Text("Last Updated: \(formatUpdateTime(rates.timeLastUpdateUtc))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                            
                        Section("Conversion Rates") {
                            ForEach(settings.displayedCurrencies, id: \.self) { currencyCode in
                                HStack {
                                    Text(currencyCode)
                                        .bold()
                                    Spacer()
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
            // Settings button remains in the Rates View
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
}

// Preview struct (Xcode 15+)
#Preview {
    MainTabView()
}
