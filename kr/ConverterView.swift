import SwiftUI

extension String {
    /// Cleans and validates the input string to ensure it is a valid number
    /// with a maximum of two decimal places, respecting the device's locale.
    func formattedAsTwoDecimalNumber(locale: Locale = .current) -> String {
        let decimalSeparator = locale.decimalSeparator ?? "."
        let numericCharacters = "0123456789"
        
        // 1. Filter out all non-numeric characters, except the decimal separator
        let validCharacters = Set(numericCharacters + decimalSeparator)
        var filtered = self.filter { validCharacters.contains($0) }
        
        // 2. Ensure only one decimal separator exists
        let parts = filtered.components(separatedBy: decimalSeparator)
        if parts.count > 2 {
            // Re-assemble the string, keeping only the first decimal separator
            filtered = parts.prefix(2).joined(separator: decimalSeparator)
        }
        
        // 3. Enforce a maximum of two digits after the decimal separator
        if let decimalIndex = filtered.firstIndex(of: Character(decimalSeparator)) {
            let afterDecimalLength = filtered.distance(
                from: filtered.index(after: decimalIndex),
                to: filtered.endIndex
            )
            
            if afterDecimalLength > 2 {
                // Truncate the string to keep only two digits after the decimal point
                let endIndex = filtered.index(decimalIndex, offsetBy: 3)
                filtered = String(filtered.prefix(upTo: endIndex))
            }
        }
        
        // 4. Prevent leading zeros (e.g., "0123" becomes "123") unless it's just "0" or "0."
        if filtered.count > 1 && filtered.prefix(2) != "0" + decimalSeparator && filtered.hasPrefix("0") {
             filtered.removeFirst()
        }

        return filtered
    }
}

struct ConverterView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var viewModel: ExchangeRateViewModel
    private let currentLocale = Locale.current
    // 1. Change the state variable to a String
    @State private var inputAmountString: String = "0"
    @State private var numericAmount: Double = 0.00
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
        formatter.maximumFractionDigits = 2
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
                                
                                        
                                        
                                        .onChange(of: inputAmountString) { oldValue, newValue in
                                            
                                            let validatedString = newValue.formattedAsTwoDecimalNumber(locale: currentLocale)
                                            
                                            
                                            if inputAmountString != validatedString {
                                                inputAmountString = validatedString
                                            }
                                            
                                            
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .decimal
                                            formatter.locale = currentLocale
                                            
                                            if let number = formatter.number(from: validatedString) {
                                                numericAmount = number.doubleValue
                                            } else {
                                                numericAmount = 0.0
                                            }
                                        }
                        
                        Picker(settings.baseCurrency, selection: $settings.baseCurrency) {
                            // Iterate over all available currencies for the picker
                            ForEach(allAvailableCurrencies, id: \.self) { currency in
                                Text(currency ?? settings.baseCurrency)
                            }
                        }
                        .pickerStyle(.navigationLink)
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                List {
                    if viewModel.isLoading {
                        ProgressView("Loading rates...")
                    }
                    
                    else if let rates = viewModel.ratesResponse, numericAmount > 0 {
                        Section("Conversion Results (Base: \(settings.baseCurrency))") {
                            ForEach(settings.displayedCurrencies, id: \.self) { currencyCode in
                                HStack {
                                    Text(currencyCode)
                                        .bold()
                                    Spacer()
                                    
                                    if let rate = rates.conversionRates[currencyCode] {
                                        
                                        let convertedValue = numericAmount * rate
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
