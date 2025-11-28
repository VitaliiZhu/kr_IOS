import Foundation
import SwiftUI

let locale = Locale.current
let currencyCode = locale.currency?.identifier

// Create a Set for automatic uniqueness and sort it later
let baseCodes: Set<String> = [
    "USD", "EUR", "GBP", "JPY", "CAD", "AUD",
    "CHF", "CNY", "HKD", "INR", "PLN", "UAH"
]

let localCodeArray = [currencyCode].compactMap { $0 }

let finalCodesSet = baseCodes.union(localCodeArray)

let allAvailableCurrencies = finalCodesSet.sorted()
class AppSettings: ObservableObject {
    
    @AppStorage("baseCurrency") var baseCurrency: String = (currencyCode ?? "USD"){
        didSet {
            
            objectWillChange.send()
        }
    }

    // Stores the list of currencies to display (e.g., ["EUR", "JPY", "GBP"])
    @AppStorage("displayedCurrencies") var displayedCurrenciesData: Data = Data() {
        didSet {
            objectWillChange.send()
        }
    }

    // Computed property to safely access the displayed currencies as a [String]
    var displayedCurrencies: [String] {
        get {
            // Attempt to decode the Data back into an array of Strings
            if let decoded = try? JSONDecoder().decode([String].self, from: displayedCurrenciesData) {
                return decoded
            }
            // Default list if decoding fails or is empty
            return ["EUR", "JPY", "GBP", "USD", "PLN"]
        }
        set {
            // Attempt to encode the array of Strings into Data for storage
            if let encoded = try? JSONEncoder().encode(newValue) {
                displayedCurrenciesData = encoded
            }
        }
    }
}
