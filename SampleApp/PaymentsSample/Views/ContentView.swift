//
//  ContentView.swift
//  PaymentsSample
//
//  Created by Allan Cheng on 2/5/26.
//

import SwiftUI
import FiservMobilePayments
import PassKit

// Landing view to showcase customizing the colors, fonts, and shapes for the SDK
// Presents an entry point to examples of how to use the SDK
struct ContentView: View {
    @State var customerId: String = ""
    
    @State var showSheets: Bool = false
    @State var showComponents: Bool = false
    @State var showGuestCheckout: Bool = false
    
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @State var showAlert = false
    
    @State var colorProvider: MobilePaymentsColorProvider = DefaultMobilePaymentsColorProvider()
        
    var body: some View {
        VStack {
            Text("Mobile Payments Sample App")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.black)
                .padding()
            
            TextField("Customer ID", text: $customerId, prompt: Text("Customer ID").foregroundStyle(.black))
                .keyboardType(.asciiCapable)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 50)
                .padding(.horizontal)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1)
                }
                .padding()
            
            Button(action: {
                setCustomerId()
                showSheets = true
            }, label: {
                Text("Sheets")
            })
            .buttonStyle(RoundedButtonStyle())
            .padding([.horizontal, .bottom])
            
            Button(action: {
                setCustomerId()
                showComponents = true
            }, label: {
                Text("UI Components")
            })
            .buttonStyle(RoundedButtonStyle())
            .padding([.horizontal, .bottom])
            
            Button(action: {
                setCustomerId()
                showGuestCheckout = true
            }, label: {
                Text("Guest Checkout")
            })
            .buttonStyle(RoundedButtonStyle())
            .padding([.horizontal, .bottom])

            Text("Styles")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.black)
                .padding()
            
            HStack {
                // Customize the SDK to a custom look
                Button(action: {
                    let font = CustomFontProvider()
                    let color = CustomColorProvider()
                    let shape = CustomShapeProvider()
                    let style = MobilePaymentsStyleProvider(colors: color, fonts: font, shapes: shape)
                    MobilePayments.shared.setStyle(style)
                    self.colorProvider = style.colors
                    setCustomerId()
                    alertTitle = "Style #1 (Yellow Block) Applied"
                    alertMessage = ""
                    showAlert = true
                }, label: {
                    Text("Style #1")
                })
                .buttonStyle(RoundedButtonStyle())
                
                // Customize the SDK to a dark mode look
                Button(action: {
                    let color = DarkColorProvider()
                    let fonts = DarkFontProvider()
                    let style = MobilePaymentsStyleProvider(colors: color, fonts: fonts)
                    MobilePayments.shared.setStyle(style)
                    self.colorProvider = style.colors
                    setCustomerId()
                    alertTitle = "Style #2 (Dark Rounded) Applied"
                    alertMessage = ""
                    showAlert = true
                }, label: {
                    Text("Style #2")
                })
                .buttonStyle(RoundedButtonStyle())
                .padding(.leading)

                
                // Customize the SDK back to the default styling
                Button(action: {
                    setCustomerId()
                    let style = MobilePaymentsStyleProvider()
                    MobilePayments.shared.setStyle(style)
                    self.colorProvider = style.colors
                    alertTitle = "Style #3 (Default) Applied"
                    alertMessage = ""
                    showAlert = true
                }, label: {
                    Text("Style #3")
                })
                .buttonStyle(RoundedButtonStyle())
                .padding(.leading)
            }
            .padding([.horizontal, .bottom])
            
            Spacer()
        }
        .background(.white)
        .task {
            // Initialize the SDK
            MobilePayments.shared.initialize(environment: .sandbox,
                                             clientToken: token,
                                             businessLocationId: locationId)
            customerId = getUserIDFromCache() ?? ""
            if !customerId.isEmpty {
                MobilePayments.shared.setCustomerId(customerId)
            }
            
            for familyName in UIFont.familyNames {
                print("\n-- \(familyName) \n")
                for fontName in UIFont.fontNames(forFamilyName: familyName) {
                    print(fontName)
                }
            }
        }
        .fullScreenCover(isPresented: $showSheets) {
            // Generate a random amount from $0.01 - $149.99
            let amount = Decimal(Int.random(in: 1...14_999)) / 100
            // Present the MobilePaymentsPurchaseView
            // This is a self-contained payment view that fully handle the entire payment flow
            MobilePaymentsPurchaseView(amount: amount,
                                       customerId: customerId,
                                       applePayMerchantId: applePayMerchantId,
                                       applePayButtonLabel: .checkout,
                                       applePayButtonStyle: colorProvider.background == DarkColorProvider().background ? .white : .black,
                                       delegate: self)
        }
        .fullScreenCover(isPresented: $showComponents) {
            // Presents the component view. This is a view that uses UI components created by the SDK
            ComponentsView(colorProvider: $colorProvider)
        }
        .fullScreenCover(isPresented: $showGuestCheckout) {
            // Presents the one time use view. This is an example of how the PurchaseButton's oneTimeUse work
            GuestCheckoutView(colorProvider: $colorProvider)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func setCustomerId() {
        let customerId = customerId.isEmpty ? nil : customerId
        MobilePayments.shared.setCustomerId(customerId)
        UserDefaults.standard.set(customerId, forKey: "customerId")
    }
    
    private func getUserIDFromCache() -> String? {
        let customerId = UserDefaults.standard.string(forKey: "customerId")
        if customerId?.isEmpty == true {
            return nil
        } else {
            return customerId
        }
    }
}

extension ContentView: MobilePaymentsPurchaseDelegate {
    func onTransactionCompleted(transaction: FiservMobilePayments.Transaction) {
        alertTitle = "Success!"
        alertMessage = "Transaction successful.\nTransaction ID: \(transaction.transactionId).\nPaid \(transaction.amount) \(transaction.currencyCode?.uppercased() ?? "USD")"
        showAlert = true
    }
    
    func onTransactionCanceled() {
        alertTitle = "Canceled"
        alertMessage = "Transaction was canceled."
        showAlert = true
    }
}
