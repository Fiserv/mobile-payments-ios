//
//  TokenizePayView.swift
//  PaymentsSample
//
//  Created by Allan Cheng on 3/4/26.
//

import SwiftUI
import FiservMobilePayments

struct TokenizePayView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss

    @ObservedObject var paymentSession: PaymentSession = PaymentSession()
    
    @State private var isLoading: Bool = false
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    @State private var showAddCreditCard: Bool = false
    
    @State private var tokenizedCard: CreditCard?
    
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
                            
                            Button {
                                showAddCreditCard = true
                            } label: {
                                Text("Tokenize Card")
                            }
                            .buttonStyle(RoundedButtonStyle())
                            .padding(.horizontal)
                            
                            if let card = tokenizedCard, let token = card.gatewayToken ?? card.token {
                                Text("Credit Card Token")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color(colorProvider.darkText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.horizontal, .top])
                                    .multilineTextAlignment(.leading)
                                
                                Text(token)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(Color(colorProvider.darkText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.top, 4)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("No Credit Card entered.")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(Color(colorProvider.darkText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.horizontal, .top])
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    
                    // Presents the SDK's purchase button component.
                    // Process the transaction as a sales transaction
                    PurchaseButton(session: paymentSession,
                                   transactionType: .sale) { result in
                        if let error = result.error {
                            alertTitle = "Error!"
                            var message = error.localizedDescription
                            if let corrId = error.correlationId {
                                message = "\(message) (\(corrId))"
                            }
                            alertMessage = message
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
                    Text("Tokenize and Pay")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(colorProvider.darkText))
                }
            }
            .background(Color(colorProvider.background))
        }
        .task {
            paymentSession.amount = total
        }
        .onChange(of: paymentSession.transactionInProgress) { _, newValue in
            // Use transactionInProgress from payment session to show/hide spinner
            isLoading = newValue
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showAddCreditCard) {
            CreditCardDetailsModal(
                canSaveCard: false,
                addressMode: .postalCode,
                cardNumberMaskMode: .lastFourVisible) { card in
                    // Update UI
                    tokenizedCard = card
                    // Add the tokenized card to the payment session to use as payment
                    paymentSession.payment = card
                }
                .presentationDetents([.large, .height(600)])
        }
    }
}
