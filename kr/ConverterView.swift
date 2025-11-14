import SwiftUI

struct ConverterView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var viewModel: ExchangeRateViewModel
    
    // 1. Change the state variable to a String
    @State private var inputAmountString: String = "1.0"
    
    // 2. Computed property to get the Double value (for calculations)
    private var inputAmount: Double {
        // Safely convert the string to a Double, or return 0.0 if invalid/empty
        return Double(inputAmountString) ?? 0.0
    }
    
    // Formatter (still needed for display formatting)
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return formatter
    }

    var body: some View {
        NavigationView {
            VStack {
                // --- Input Section (UPDATED) ---
                Section {
                    HStack {
                        // 3. Bind the TextField directly to the String
                        TextField("Enter Amount", text: $inputAmountString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.largeTitle)
                            // Clean up the input string after every change
                            .onChange(of: inputAmountString) { oldValue, newValue in
                                // Optional: You can enforce only numbers and decimal points here
                                inputAmountString = newValue.filter("0123456789.".contains)
                            }
                        
                        Text(settings.baseCurrency)
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // --- Conversion List Section (UPDATED) ---
                List {
                    if viewModel.isLoading {
                        ProgressView("Loading rates...")
                    }
                    // 4. Use the computed property `inputAmount` for validation
                    else if let rates = viewModel.ratesResponse, inputAmount > 0 {
                        Section("Conversion Results (Base: \(settings.baseCurrency))") {
                            ForEach(settings.displayedCurrencies, id: \.self) { currencyCode in
                                HStack {
                                    Text(currencyCode)
                                        .bold()
                                    Spacer()
                                    
                                    if let rate = rates.conversionRates[currencyCode] {
                                        // 5. Use the computed property for the calculation
                                        let convertedValue = inputAmount * rate
                                        Text(numberFormatter.string(from: NSNumber(value: convertedValue)) ?? "N/A")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text("Rate N/A")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    } else {
                        // Display message if input is 0 or less, or if rates are missing
                        Text("Please enter a valid amount to start converting.")
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Converter")
            
        }
    }
}
// ... (hideKeyboard extension remains the same)
