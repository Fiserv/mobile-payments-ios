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
            
            Button(action: {
                showSheets = true
            }, label: {
                Text("Sheets")
            })
            .buttonStyle(RoundedButtonStyle())
            .padding([.horizontal, .bottom])
            
            Button(action: {
                showComponents = true
            }, label: {
                Text("UI Components")
            })
            .buttonStyle(RoundedButtonStyle())
            .padding([.horizontal, .bottom])
            
            Button(action: {
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
            
            HStack(spacing: 4) {
                // Customize the SDK to a yellow blocky look
                Button(action: {
                    let font = CustomFontProvider()
                    let color = CustomColorProvider()
                    let shape = CustomShapeProvider()
                    let style = MobilePaymentsStyleProvider(colors: color, fonts: font, shapes: shape)
                    MobilePayments.shared.setStyle(style)
                    self.colorProvider = style.colors
                    alertTitle = "Style #1 (Blocky Yellow) Applied"
                    alertMessage = ""
                    showAlert = true
                }, label: {
                    Text("Style #1")
                        .padding(.horizontal, 4)
                        .multilineTextAlignment(.center)
                })
                .buttonStyle(RoundedButtonStyle())
                
                // Customize the SDK to a dark mode look
                Button(action: {
                    let color = DarkColorProvider()
                    let style = MobilePaymentsStyleProvider(colors: color)
                    MobilePayments.shared.setStyle(style)
                    self.colorProvider = style.colors
                    alertTitle = "Style #2 (Dark) Applied"
                    alertMessage = ""
                    showAlert = true
                }, label: {
                    Text("Style #2")
                        .padding(.horizontal, 4)
                        .multilineTextAlignment(.center)
                })
                .buttonStyle(RoundedButtonStyle())
                
                // Customize the SDK back to the default styling
                Button(action: {
                    let style = MobilePaymentsStyleProvider()
                    MobilePayments.shared.setStyle(style)
                    self.colorProvider = style.colors
                    alertTitle = "Default Style Applied"
                    alertMessage = ""
                    showAlert = true
                }, label: {
                    Text("Default")
                        .padding(.horizontal, 4)
                        .multilineTextAlignment(.center)
                })
                .buttonStyle(RoundedButtonStyle())
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(.white)
        .task {
            // Initialize the SDK
            MobilePayments.shared.initialize(environment: .sandbox,
                                             clientToken: token,
                                             businessLocationId: locationId)
            
            // Using device ID to represent customer as an example for this sample app
            if let customerId = UIDevice.current.identifierForVendor?.uuidString {
                MobilePayments.shared.setCustomerId(customerId)
            }
        }
        .fullScreenCover(isPresented: $showSheets) {
            // Generate a random amount from $0.01 - $149.99
            let amount = Decimal(Int.random(in: 1...14_999)) / 100
            // Present the MobilePaymentsPurchaseView
            // This is a self-contained payment view that fully handle the entire payment flow
            MobilePaymentsPurchaseView(amount: amount,
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
