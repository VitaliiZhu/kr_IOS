import Foundation

// MARK: - 1. Data Structure (Codable)

/// Represents the structure of the JSON response from the ExchangeRate-API Standard Endpoint.
struct ExchangeRateResponse: Decodable {
    let result: String
    let baseCode: String
    let timeLastUpdateUtc: String
    let conversionRates: [String: Double]

    // Map JSON keys (snake_case) to Swift properties (camelCase)
    enum CodingKeys: String, CodingKey {
        case result
        case baseCode = "base_code"
        case timeLastUpdateUtc = "time_last_update_utc"
        case conversionRates = "conversion_rates"
    }
}

// MARK: - 2. Error Handling

/// Custom errors specific to the exchange rate fetching process.
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiFailure(message: String)
}

// MARK: - 3. API Fetcher Class

/// A utility class to handle all network operations for the ExchangeRate-API.
class ExchangeRateFetcher {
    
    // NOTE: You MUST replace this with your actual API key obtained from exchangerate-api.com
    private let apiKey = "3e76b4d2abe44b028108724b"
    private let baseURL = "https://v6.exchangerate-api.com/v6/"
    
    /**
     Fetches the latest exchange rates for a specified base currency.
     
     - Parameter baseCurrency: The three-letter currency code (e.g., "USD", "EUR").
     - Returns: An ExchangeRateResponse object containing the rates.
     - Throws: An APIError if the request or decoding fails.
     */
    func fetchLatestRates(baseCurrency: String) async throws -> ExchangeRateResponse {
        
        // 1. Construct the URL
        let urlString = "\(baseURL)\(apiKey)/latest/\(baseCurrency)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            // 2. Perform the network request using modern async/await
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Basic HTTP response check (optional but good practice)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                throw APIError.networkError(NSError(domain: "HTTP", code: status, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response status code"]))
            }

            // 3. Decode the JSON data
            let decoder = JSONDecoder()
            let rateResponse = try decoder.decode(ExchangeRateResponse.self, from: data)
            
            // 4. Check for API-specific failure reported in the 'result' field
            if rateResponse.result != "success" {
                // In a real app, you'd check the 'error-type' field for more detail,
                // but we'll use a generic failure for this example.
                throw APIError.apiFailure(message: "API request failed with status: \(rateResponse.result)")
            }
            
            return rateResponse
            
        } catch {
            // Catch other errors (URLSession failures, connection issues, etc.)
            throw APIError.networkError(error)
        }
    }
}

