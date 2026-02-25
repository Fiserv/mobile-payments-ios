//
//  DirectView.swift
//  PaymentsSample
//
//  Created by Allan Cheng on 2/20/26.
//

import SwiftUI
import FiservMobilePayments

struct DirectView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
        
    @State private var isLoading: Bool = false
    
    @State private var transactionId: String = ""
    @State private var authorizationCode: String = ""
    @State private var selectedTransactionType: FiservMobilePayments.TransactionType?
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    @Binding var colorProvider: MobilePaymentsColorProvider
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TextField("Transaction ID", text: $transactionId, prompt: Text("Transaction ID").foregroundStyle(Color(colorProvider.darkText)))
                        .tint(Color(colorProvider.darkText))
                        .foregroundStyle(Color(colorProvider.darkText))
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .padding(.horizontal)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(colorProvider.mediumText), lineWidth: 1)
                        }
                        .padding()
                    
                    TextField("Authorization Code", text: $authorizationCode, prompt: Text("Authorization Code").foregroundStyle(Color(colorProvider.darkText)))
                        .tint(Color(colorProvider.darkText))
                        .foregroundStyle(Color(colorProvider.darkText))
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .padding(.horizontal)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(colorProvider.mediumText), lineWidth: 1)
                        }
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Previous Transaction Type: ")
                            .foregroundStyle(Color(colorProvider.darkText))
                        
                        Picker("Transaction Type", selection: $selectedTransactionType) {
                            ForEach(FiservMobilePayments.TransactionType.allCases) { type in
                                Text(type.rawValue)
                                    .tag(type as FiservMobilePayments.TransactionType?)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal])
                    
                    Button(action: {
                        let creditCard = generateTestCreditCard()
                        let amount = Decimal(Int.random(in: 1...14_999)) / 100
                        let payment: Payment<CreditCard> = Payment(amount: amount,
                                                                   paymentMethod: creditCard,
                                                                   merchantReference: nil)
                        isLoading = true
                        PaymentManager.shared.sale(payment: payment) { result in
                            isLoading = false
                            if let error = result.error {
                                alertTitle = "Error"
                                var message = error.localizedDescription
                                if let corrId = error.correlationId {
                                    message = "\(message) (\(corrId))"
                                }
                                alertMessage = message
                                showAlert = true
                            } else if let transaction = result.transaction {
                                let chargedAmount = transaction.amount.formatted(.currency(code: transaction.currencyCode ?? "USD"))
                                alertTitle = "Success"
                                alertMessage = "Charged \(chargedAmount).\nTransaction ID = \(transaction.transactionId)."
                                showAlert = true
                                transactionId = transaction.transactionId
                                selectedTransactionType = .sale
                                authorizationCode = ""
                            }
                        }
                    }, label: {
                        Text("Sale")
                            .padding(.horizontal, 4)
                            .multilineTextAlignment(.center)
                    })
                    .buttonStyle(RoundedButtonStyle())
                    .padding(.top, 30)
                    .padding(.horizontal)
                    
                    Button(action: {
                        let creditCard = generateTestCreditCard()
                        let amount = Decimal(Int.random(in: 1...14_999)) / 100
                        let payment: Payment<CreditCard> = Payment(amount: amount,
                                                                   paymentMethod: creditCard,
                                                                   merchantReference: nil)
                        isLoading = true
                        PaymentManager.shared.auth(payment: payment) { result in
                            isLoading = false
                            if let error = result.error {
                                alertTitle = "Error"
                                var message = error.localizedDescription
                                if let corrId = error.correlationId {
                                    message = "\(message) (\(corrId))"
                                }
                                alertMessage = message
                                showAlert = true
                            } else if let transaction = result.transaction {
                                let chargedAmount = transaction.amount.formatted(.currency(code: transaction.currencyCode ?? "USD"))
                                alertTitle = "Success"
                                alertMessage = "Authorized \(chargedAmount).\nTransaction ID = \(transaction.transactionId)."
                                showAlert = true
                                transactionId = transaction.transactionId
                                authorizationCode = transaction.authorizationCode ?? ""
                                selectedTransactionType = .auth
                            }
                        }
                    }, label: {
                        Text("Auth")
                            .padding(.horizontal, 4)
                            .multilineTextAlignment(.center)
                    })
                    .buttonStyle(RoundedButtonStyle())
                    .padding([.top, .horizontal])
                    
                    Button(action: {
                        let transaction = Transaction(transactionId: transactionId,
                                                      authorizationCode: authorizationCode,
                                                      transactionType: selectedTransactionType ?? .auth)
                        isLoading = true
                        PaymentManager.shared.capture(transaction: transaction) { result in
                            isLoading = false
                            if let error = result.error {
                                alertTitle = "Error"
                                var message = error.localizedDescription
                                if let corrId = error.correlationId {
                                    message = "\(message) (\(corrId))"
                                }
                                alertMessage = message
                                showAlert = true
                            } else if let transaction = result.transaction {
                                alertTitle = "Success"
                                alertMessage = "Captured transaction.\nTransaction ID = \(transaction.transactionId)."
                                showAlert = true
                                transactionId = transaction.transactionId
                                authorizationCode = transaction.authorizationCode ?? ""
                                selectedTransactionType = .capture
                            }
                        }
                    }, label: {
                        Text("Capture")
                            .padding(.horizontal, 4)
                            .multilineTextAlignment(.center)
                    })
                    .buttonStyle(RoundedButtonStyle())
                    .disabled(selectedTransactionType != .auth || authorizationCode.isEmpty)
                    .padding([.top, .horizontal])
                    
                    Button(action: {
                        let transaction = Transaction(transactionId: transactionId,
                                                      authorizationCode: authorizationCode,
                                                      transactionType: selectedTransactionType ?? .sale)
                        isLoading = true
                        PaymentManager.shared.void(transaction: transaction) { result in
                            isLoading = false
                            if let error = result.error {
                                alertTitle = "Error"
                                var message = error.localizedDescription
                                if let corrId = error.correlationId {
                                    message = "\(message) (\(corrId))"
                                }
                                alertMessage = message
                                showAlert = true
                            } else if let transaction = result.transaction {
                                alertTitle = "Success"
                                alertMessage = "Voided transaction.\nTransaction ID = \(transaction.transactionId)."
                                showAlert = true
                                transactionId = transaction.transactionId
                                authorizationCode = transaction.authorizationCode ?? ""
                                selectedTransactionType = .void
                            }
                        }
                    }, label: {
                        Text("Void")
                            .padding(.horizontal, 4)
                            .multilineTextAlignment(.center)
                    })
                    .buttonStyle(RoundedButtonStyle())
                    .disabled(transactionId.isEmpty)
                    .padding([.top, .horizontal])
                    
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
                    Text("Direct API")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(colorProvider.darkText))
                }
            }
            .background(Color(colorProvider.background))
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    func generateTestCreditCard() -> CreditCard {
        let billingAddress = BillingAddress(addressLine1: nil,
                                            locality: nil,
                                            region: nil,
                                            postalCode: "94104")
        return CreditCard(billingAddress: billingAddress,
                          nameOnCard: "Test Test",
                          cardNumber: "4111111111111111",
                          expiration: Expiration(month: 1, year: 2030),
                          cvv: "444",
                          cardType: .visa,
                          lastFourDigits: "1111",
                          firstSixDigits: "41111")
    }
}
