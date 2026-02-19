//
//  GuestCheckoutView.swift
//  PaymentsSample
//
//  Created by Allan Cheng on 2/14/26.
//

import SwiftUI
import FiservMobilePayments
import PassKit

// View to showcase how the PurchaseButton oneTimeUse operation mode
struct GuestCheckoutView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    @ObservedObject var paymentState: PaymentState = PaymentState()
    @State private var amount: String = ""
    @FocusState private var amountFocused: Bool
    
    @State private var isLoading: Bool = false
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    
    @Binding var colorProvider: MobilePaymentsColorProvider
    
    @StateObject private var applePayCoordinator = MobilePaymentsApplePayCoordinator()
    @State private var isApplePayAvailable: Bool = true
    
    let taxesAndFees: Decimal = 5.95
    
    var total: Decimal {
        taxesAndFees + parseAmount()
    }
    
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
                    
                    Text("Your Cart")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(colorProvider.darkText))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Large Container")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(colorProvider.darkText))
                        
                        Spacer()
                        
                        Text(parseAmount(), format: .currency(code: "USD"))
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(Color(colorProvider.darkText))
                    }
                    .padding()
                    
                    Capsule()
                        .fill(Color(colorProvider.mediumText))
                        .frame(height: 1)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Taxes & Fees")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(colorProvider.darkText))
                        
                        Spacer()
                        
                        Text(taxesAndFees, format: .currency(code: "USD"))
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(Color(colorProvider.darkText))
                    }
                    .padding()
                    
                    // If apple pay is available, present an Apple Pay button for the user to checkout with
                    if isApplePayAvailable {
                        PayWithApplePayButton(.order, action: {
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
                    
                    // Set the SDK's purchase button component to oneTimeUse opperation
                    PurchaseButton(state: paymentState,
                                   transactionType: .sale,
                                   purchaseButtonOperationMode: .oneTimeUse,
                                   autoSubmitAfterAddingCard: true) { result in
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
            .onTapGesture {
                amountFocused = false
            }
            .onChange(of: amount) { _,_ in
                paymentState.amount = total
            }
            .onChange(of: applePayCoordinator.paymentResults) { _, result in
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
                            .foregroundStyle(Color(colorProvider.darkText))
                            .imageScale(.large)
                            .padding()
                    }
                }
                .hideSharedBackground()
                
                ToolbarItem(placement: .principal) {
                    Text("Guest Checkout")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(colorProvider.darkText))
                }
            }
            .background(Color(colorProvider.background))
        }
        .task {
            paymentState.amount = taxesAndFees
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
