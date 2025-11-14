import Foundation
import SwiftUI

// This list should ideally come from your API/ViewModel after fetching
// but for a starting point, we'll define a set of common currencies.
let allAvailableCurrencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD", "INR", "PLN", "UAH"]

class AppSettings: ObservableObject {
    // Stores the selected base currency (e.g., "UAH")
    @AppStorage("baseCurrency") var baseCurrency: String = "USD" {
        didSet {
            // Notifies the view model to refetch data when the base currency changes
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
