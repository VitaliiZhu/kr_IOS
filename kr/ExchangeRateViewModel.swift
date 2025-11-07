import Foundation

// Note: Ensure your ExchangeRateResponse, APIError, and ExchangeRateFetcher are accessible.

/// Manages the state and business logic for fetching and displaying exchange rates.
@MainActor // Ensures all published changes are on the main thread, which is required for SwiftUI updates.
class ExchangeRateViewModel: ObservableObject {
    // The main data property, published so the view updates when it changes.
    @Published var ratesResponse: ExchangeRateResponse?
    
    // State properties for UI feedback
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // The service class responsible for networking
    private let fetcher = ExchangeRateFetcher()
    
    // A default base currency for the initial load
    private let defaultBaseCurrency = "USD"
    
    /**
     Initiates the asynchronous fetch operation.
     - Parameter baseCurrency: The currency to use as the base for the rates.
     */
    func fetchRates(baseCurrency: String? = nil) async {
        isLoading = true
        errorMessage = nil
        ratesResponse = nil // Clear previous data
        
        let currency = baseCurrency ?? defaultBaseCurrency
        
        do {
            // Call the async throwing function from the fetcher
            let response = try await fetcher.fetchLatestRates(baseCurrency: currency)
            
            // On success, update the published property
            ratesResponse = response
            
        } catch {
            // On failure, handle the error and set the error message
            if let apiError = error as? APIError {
                switch apiError {
                case .invalidURL:
                    errorMessage = "Error: Invalid API URL."
                case .networkError(let underlyingError):
                    errorMessage = "Network Error: \(underlyingError.localizedDescription)"
                case .decodingError(let underlyingError):
                    errorMessage = "Decoding Error: \(underlyingError.localizedDescription)"
                case .apiFailure(let message):
                    errorMessage = "API Failure: \(message)"
                }
            } else {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
}
