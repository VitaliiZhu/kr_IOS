import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    
    // We use a temporary @State variable for the displayed list
    // to allow toggling without constant re-encoding until the view disappears.
    @State private var tempDisplayedCurrencies: [String]
    
    // Initializes the view, copying the AppSettings list to the temporary state
    init(settings: AppSettings) {
        self.settings = settings
        _tempDisplayedCurrencies = State(initialValue: settings.displayedCurrencies)
    }

    var body: some View {
        List {
            // MARK: - Base Currency Picker
            Section("Base Currency") {
                Picker("Select Base Currency", selection: $settings.baseCurrency) {
                    // Iterate over all available currencies for the picker
                    ForEach(allAvailableCurrencies, id: \.self) { currency in
                        Text(currency )
                    }
                }
                .pickerStyle(.navigationLink) // Presents the options on a new screen
            }

            // MARK: - Displayed Currencies Toggles
            Section("Currencies to Display") {
                ForEach(allAvailableCurrencies, id: \.self) { currencyCode in
                    // Bind the toggle to a computed boolean that checks if the currency is in the temporary list
                    Toggle(currencyCode ?? settings.baseCurrency, isOn: Binding(
                        get: {
                            tempDisplayedCurrencies.contains(currencyCode ?? settings.baseCurrency)
                        },
                        set: { isToggled in
                            if isToggled {
                                // Add to list if toggled ON
                                tempDisplayedCurrencies.append(currencyCode ?? settings.baseCurrency)
                            } else {
                                // Remove from list if toggled OFF
                                tempDisplayedCurrencies.removeAll(where: { $0 == currencyCode })
                            }
                        }
                    ))
                }
            }
        }
        .navigationTitle("Settings")
        .onDisappear {
            // When the user leaves the settings screen, save the changes back to AppSettings
            settings.displayedCurrencies = tempDisplayedCurrencies
        }
    }
}
