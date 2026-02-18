//
//  ComponentsView.swift
//  PaymentsSample
//
//  Created by Allan Cheng on 2/13/26.
//

import SwiftUI
import FiservMobilePayments
import PassKit
import UIKit
import Foundation

// Component view to illustrate embeding the SDK's component into your own view
struct ComponentsView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss

    @ObservedObject var paymentState: PaymentState = PaymentState()
    @State private var amount: String = ""
    @FocusState private var amountFocused: Bool
    
    @State private var isLoading: Bool = false
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    
    @StateObject private var applePayCoordinator = MobilePaymentsApplePayCoordinator()
    @State private var isApplePayAvailable: Bool = true
    
    @Binding var colorProvider: MobilePaymentsColorProvider
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TextField("Amount", text: $amount, prompt: Text("Amount").foregroundStyle(Color(colorProvider.darkText)))
                        .tint(Color(colorProvider.darkText))
                        .foregroundStyle(Color(colorProvider.darkText))
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .padding(.horizontal)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(amountFocused ? Color(colorProvider.primary) : Color(colorProvider.mediumText), lineWidth: 1)
                        }
                        .focused($amountFocused)
                        .padding()
                        .onTapGesture {
                            amountFocused = true
                        }
                    
                    ScrollView {
                        VStack {
                            // Shows the entered total to be charged
                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color(colorProvider.darkText))
                                
                                Spacer()
                                
                                Text(parseAmount(), format: .currency(code: "USD"))
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundStyle(Color(colorProvider.darkText))
                            }
                            .padding(.horizontal)
                            
                            // If apple pay is available, present an Apple Pay button for the user to checkout with
                            if isApplePayAvailable {
                                PayWithApplePayButton(.buy, action: {
                                    // User tapped on apple pay button
                                    paymentState.transactionInProgress = true
                                    Task {
                                        // Use the SDK's MobilePaymentsApplePayCoordinator to start the Apple Pay flow
                                        await applePayCoordinator.performTransaction(amount: parseAmount(),
                                                                                     applePayMerchantId: applePayMerchantId)
                                    }
                                })
                                .padding(.horizontal)
                                .payWithApplePayButtonStyle(colorProvider.background == DarkColorProvider().background ? .white : .black)
                                .disabled(paymentState.transactionInProgress || parseAmount() == 0)
                                .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                            }
                            
                            // Presents the SDK's'credit card list component.
                            // Disables scrolling because this is embeded inside a ScrollView
                            // Enabled requireCvv to forcefully collect CVV. Can be set to false if desired
                            CreditCardListView(state: paymentState,
                                               scrollingEnabled: false,
                                               requireCvv: true) { creditCard in
                                self.paymentState.selectedPayment = creditCard
                            }
                            
                            Text("UPS provides information you submit through this site to a vendor for security purposes. Please see the Privacy Policy for more information.")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(colorProvider.mediumText))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .padding([.horizontal, .top])
                            
                            Text("Terms and Conditions of Service")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(colorProvider.primary))
                                .underline(color: Color(colorProvider.primary))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Presents the SDK's purchase button component.
                    // Process the transaction as a sales transaction
                    PurchaseButton(state: paymentState,
                                   transactionType: .sale) { result in
                        if let error = result.error {
                            alertTitle = "Error!"
                            alertMessage = error.localizedDescription
                            showAlert = true
                        } else if let transaction = result.transaction {
                            alertTitle = "Success!"
                            alertMessage = "Transaction successful. Transaction ID: \(transaction.transactionId).\nPaid \(transaction.amount) \(transaction.currencyCode?.uppercased() ?? "USD")"
                            showAlert = true
                        } else {
                            alertTitle = "Error!"
                            alertMessage = "Transaction status unknown"
                            showAlert = true
                        }
                    }
                    
                    Spacer()
                }
                
                if isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            .background(Color(colorProvider.background))
        }
        .task {
            do {
                isApplePayAvailable = try await PaymentManager.shared.canPayWithApplePay()
            } catch {
                alertTitle = "Apple Pay Error"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func parseAmount() -> Decimal {
        let amount = (Decimal(string: amount) ?? 0)
        if amount < 0 {
            return 0
        } else {
            return amount.rounded(scale: 2)
        }
    }
}
