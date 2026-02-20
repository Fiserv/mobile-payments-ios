//
//  GuestCheckoutViewController.swift
//  PaymentsSampleUIKit
//
//  Created by Allan Cheng on 2/19/26.
//

import Foundation
import FiservMobilePayments
import SnapKit

class GuestCheckoutViewController: UIViewController {
    var colorProvider: MobilePaymentsColorProvider = DefaultMobilePaymentsColorProvider()
    // Define a payment state to be used with the SDK components for amount, credit cards, etc
    private let state = PaymentState()
    
    // Views
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Amount"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = 0.formatted(.currency(code: "USD"))
        label.textColor = colorProvider.darkText
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var purchaseButton: UIPurchaseButton = {
        // Set the SDK's purchase button to one time use and autosubmit
        // for express checkout flow
        let button = UIPurchaseButton(state: state,
                                      purchaseButtonOperationMode: .oneTimeUse,
                                      autoSubmitAfterAddingCard: true,
                                      billingAddress: nil,
                                      delegate: self)
        button.add(to: self)
        return button
    }()
    
    // Constants
    let taxesAndFees: Decimal = 5.95

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colorProvider.background
        
        setupView()
        
        // Set the initial taxes and fee amount
        state.amount = taxesAndFees
        
        // Detect when user enter in an amount
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupView() {
        let contentContainer = UIView()
        
        view.addSubview(contentContainer)
        contentContainer.addSubview(amountTextField)
        
        contentContainer.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        amountTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.verticalScreenEdgeMargin)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
        }
        
        // Add the fake checkout view
        let fakeCheckoutView = createFakeCheckoutView()
        contentContainer.addSubview(fakeCheckoutView)
        fakeCheckoutView.snp.makeConstraints {
            $0.top.equalTo(amountTextField.snp.bottom).offset(UIConstants.marginLarge)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        contentContainer.addSubview(purchaseButton)
        purchaseButton.snp.makeConstraints {
            $0.top.equalTo(fakeCheckoutView.snp.bottom).offset(UIConstants.marginLarge)
            $0.left.right.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func createFakeCheckoutView() -> UIView {
        let view = UIView()
        
        // 'Your Cart' header
        let yourCartLabel = UILabel()
        yourCartLabel.text = "Your Cart"
        yourCartLabel.textColor = colorProvider.darkText
        yourCartLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        yourCartLabel.textAlignment = .left
        view.addSubview(yourCartLabel)
        
        yourCartLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.top.equalToSuperview().offset(UIConstants.verticalScreenEdgeMargin)
        }
        
        // 'Large Container' item
        let largeContainerLabel = UILabel()
        largeContainerLabel.text = "Large Container"
        largeContainerLabel.textColor = colorProvider.darkText
        largeContainerLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        largeContainerLabel.textAlignment = .left
        largeContainerLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        largeContainerLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(largeContainerLabel)
        
        view.addSubview(priceLabel)
        
        let divider1 = createDividerLine()
        view.addSubview(divider1)
        
        largeContainerLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalTo(priceLabel.snp.left).offset(-UIConstants.marginTiny)
            $0.top.equalTo(yourCartLabel.snp.bottom).offset(20)
        }
        
        priceLabel.snp.makeConstraints {
            $0.centerY.equalTo(largeContainerLabel)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        divider1.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.top.equalTo(largeContainerLabel.snp.bottom).offset(UIConstants.marginSmall)
            $0.height.equalTo(1)
        }
        
        // Taxes and Fee
        let taxesAndFeesLabel = UILabel()
        taxesAndFeesLabel.text = "Taxes & Fees"
        taxesAndFeesLabel.textColor = colorProvider.darkText
        taxesAndFeesLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        taxesAndFeesLabel.textAlignment = .left
        taxesAndFeesLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        taxesAndFeesLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(taxesAndFeesLabel)
        
        let taxesAndFeesLabelPriceLabel = UILabel()
        taxesAndFeesLabelPriceLabel.text = taxesAndFees.formatted(.currency(code: "USD"))
        taxesAndFeesLabelPriceLabel.textColor = colorProvider.darkText
        taxesAndFeesLabelPriceLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        taxesAndFeesLabelPriceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        taxesAndFeesLabelPriceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.addSubview(taxesAndFeesLabelPriceLabel)
        
        taxesAndFeesLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalTo(taxesAndFeesLabelPriceLabel.snp.left).offset(-UIConstants.marginTiny)
            $0.top.equalTo(divider1.snp.bottom).offset(UIConstants.marginSmall)
        }
        
        taxesAndFeesLabelPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(taxesAndFeesLabel)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        // Terms and conditions
        let termsLabel = UILabel()
        termsLabel.text = "Acme provides information you submit through this site to a vendor for security purposes. Please see the Privacy Policy for more information."
        termsLabel.textColor = colorProvider.mediumText
        termsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        termsLabel.numberOfLines = 0
        termsLabel.lineBreakMode = .byWordWrapping
        termsLabel.textAlignment = .left
        termsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        termsLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(termsLabel)
        
        termsLabel.snp.makeConstraints {
            $0.top.equalTo(taxesAndFeesLabel.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        let termsFakeLink = UILabel()
        let textAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: colorProvider.primary,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        termsFakeLink.attributedText = NSAttributedString(string: "Terms and Conditions of Service",
                                                       attributes: textAttributes)
        termsFakeLink.numberOfLines = 0
        termsFakeLink.lineBreakMode = .byWordWrapping
        termsFakeLink.textAlignment = .left
        termsFakeLink.setContentHuggingPriority(.defaultLow, for: .horizontal)
        termsFakeLink.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(termsFakeLink)
        
        termsFakeLink.snp.makeConstraints {
            $0.top.equalTo(termsLabel.snp.bottom).offset(UIConstants.marginTiny)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.bottom.equalToSuperview()
        }
        
        return view
    }
    
    func createDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = colorProvider.darkText
        return view
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let amount = parseAmount() + taxesAndFees
        state.amount = amount
        priceLabel.text = amount.formatted(.currency(code: "USD"))
    }
    
    func parseAmount() -> Decimal {
        let amount = (Decimal(string: amountTextField.text ?? "0") ?? 0)
        if amount < 0 {
            return 0
        } else {
            return amount.rounded(scale: 2)
        }
    }
}

//MARK: - PurchaseButtonDelegate
extension GuestCheckoutViewController: PurchaseButtonDelegate {
    // Receive updates for payment transaction
    func onTransactionCompleted(result: TransactionResult) {
        if let error = result.error {
            showPopup(title: "Error!", message: error.localizedDescription, from: self)
        } else if let transaction = result.transaction {
            let message = "Transaction successful. Transaction ID: \(transaction.transactionId).\nPaid \(transaction.amount) \(transaction.currencyCode?.uppercased() ?? "USD")"
            showPopup(title: "Success!", message: message, from: self)
        }
    }
}
