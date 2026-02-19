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
    
    @State private var isLoading: Bool = false
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    @StateObject private var applePayCoordinator = MobilePaymentsApplePayCoordinator()
    @State private var isApplePayAvailable: Bool = true
    
    let itemOnePrice: Decimal = Decimal(Int.random(in: 1...7_000)) / 100
    let itemTwoPrice: Decimal = Decimal(Int.random(in: 1...7_000)) / 100
    let taxesAndFees: Decimal = 5.95
    
    var total: Decimal {
        itemOnePrice + itemTwoPrice + taxesAndFees
    }
    
    @Binding var colorProvider: MobilePaymentsColorProvider
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView {
                        VStack {
                            // Presents the SDK's'credit card list component.
                            // Disables scrolling because this is embeded inside a ScrollView
                            // Enabled requireCvv to forcefully collect CVV. Can be set to false if desired
                            CreditCardListView(state: paymentState,
                                               scrollingEnabled: false,
                                               requireCvv: true) { creditCard in
                                self.paymentState.selectedPayment = creditCard
                            }
                            .padding(.top)
                            
                            Text("Your Cart")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color(colorProvider.darkText))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .padding([.horizontal, .top])
                            
                            HStack {
                                Text("Gemini Chart")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color(colorProvider.darkText))
                                
                                Spacer()
                                
                                Text(itemOnePrice.formatted(.currency(code: "USD")))
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(Color(colorProvider.darkText))
                            }
                            .padding([.horizontal, .top])
                            
                            Capsule()
                                .fill(Color(colorProvider.mediumText))
                                .frame(height: 0.5)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Quickstart Kit")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color(colorProvider.darkText))
                                
                                Spacer()
                                
                                Text(itemTwoPrice.formatted(.currency(code: "USD")))
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(Color(colorProvider.darkText))
                            }
                            .padding(.horizontal)
                            
                            Capsule()
                                .fill(Color(colorProvider.darkText))
                                .frame(height: 1)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Taxes & Fees")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color(colorProvider.darkText))
                                
                                Spacer()
                                
                                Text(taxesAndFees.formatted(.currency(code: "USD")))
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundStyle(Color(colorProvider.darkText))
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Total")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Color(colorProvider.darkText))
                                
                                Spacer()
                                
                                Text(total.formatted(.currency(code: "USD")))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Color(colorProvider.darkText))
                            }
                            .padding()
                            
                            // If apple pay is available, present an Apple Pay button for the user to checkout with
                            if isApplePayAvailable {
                                PayWithApplePayButton(.buy, action: {
                                    // User tapped on apple pay button
                                    paymentState.transactionInProgress = true
                                    Task {
                                        // Use the SDK's MobilePaymentsApplePayCoordinator to start the Apple Pay flow
                                        await applePayCoordinator.performTransaction(amount: total,
                                                                                     applePayMerchantId: applePayMerchantId)
                                    }
                                })
                                .padding(.horizontal)
                                .payWithApplePayButtonStyle(colorProvider.background == DarkColorProvider().background ? .white : .black)
                                .disabled(paymentState.transactionInProgress)
                                .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                            }
                            
                            Text("Acme provides information you submit through this site to a vendor for security purposes. Please see the Privacy Policy for more information.")
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
                    .scrollDismissesKeyboard(.immediately)
                    
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
            .onChange(of: applePayCoordinator.paymentResults) { _, result in
                // Listen to the resulting Apple Pay sales transaction if user paid with Apple Pay
                guard let result = result else { return }
                paymentState.transactionInProgress = false
                switch result {
                case .success(let transaction):
                    alertTitle = "Success!"
                    alertMessage = "Apple Pay transaction successful. Transaction ID: \(transaction.transactionId).\nPaid \(transaction.amount) \(transaction.currencyCode?.uppercased() ?? "USD")"
                    showAlert = true
                case .failure(let error):
                    alertTitle = "Error!"
                    alertMessage = error.error.localizedDescription
                    showAlert = true
                default:
                    break
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(colorProvider.background), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(colorProvider.darkText))
                            .imageScale(.large)
                            .padding()
                    }
                }
                .hideSharedBackground()
                
                ToolbarItem(placement: .principal) {
                    Text("UI Components")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(colorProvider.darkText))
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
            paymentState.amount = total
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}
