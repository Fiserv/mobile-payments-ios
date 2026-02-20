//
//  ComponentViewController.swift
//  PaymentsSampleUIKit
//
//  Created by Allan Cheng on 2/19/26.
//

import Foundation
import FiservMobilePayments
import SnapKit
import PassKit
import Combine

class ComponentViewController: UIViewController {
    var isApplePayAvailable: Bool = false
    var colorProvider: MobilePaymentsColorProvider = DefaultMobilePaymentsColorProvider()
    
    // Define a payment state to be used with the SDK components for amount, credit cards, etc
    private let state = PaymentState()
    
    // Apple Pay
    private var applePayCoordinator = MobilePaymentsApplePayCoordinator()
    private var cancellables = Set<AnyCancellable>()
    
    // Views
    private lazy var creditCardListView: UICreditCardListView = {
        // SDK's credit card list component
        // Disable scrolling because it is going to be embeded into an UIScrollView
        // Enabled requireCvv to forcefully collect CVV. Can be set to false if desired
        let view = UICreditCardListView(state: state, scrollingEnabled: false, requireCvv: true, delegate: self)
        view.add(to: self)
        return view
    }()
    
    private lazy var purchaseButton: UIPurchaseButton = {
        let button = UIPurchaseButton(state: state, billingAddress: nil, delegate: self)
        button.add(to: self)
        return button
    }()
    
    private lazy var applePayButton: PKPaymentButton = {
        let apButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: colorProvider.background == DarkColorProvider().background ? .white : .black)
        apButton.addAction(UIAction { [weak self] _ in
            self?.applePayTapped()
        }, for: .touchUpInside)
        return apButton
    }()
    
    // Constants
    let itemOnePrice: Decimal = Decimal(Int.random(in: 1...7_000)) / 100
    let itemTwoPrice: Decimal = Decimal(Int.random(in: 1...7_000)) / 100
    let taxesAndFees: Decimal = 5.95
    
    var total: Decimal {
        itemOnePrice + itemTwoPrice + taxesAndFees
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colorProvider.background
        
        setupView()
        state.amount = total
        
        // Listen to apple pay results
        applePayCoordinator.$paymentResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.processApplePayResults(results)
            }
            .store(in: &cancellables)
    }
    
    func setupView() {
        let container = UIView()
        let scrollView = UIScrollView()
        let scrollViewContent = UIView()
        let fakeCheckoutView = createFakeCheckoutView()
        
        view.addSubview(container)
        container.addSubview(scrollView)
        container.addSubview(purchaseButton)

        scrollView.addSubview(scrollViewContent)
        
        scrollViewContent.addSubview(creditCardListView)
        scrollViewContent.addSubview(fakeCheckoutView)
        
        container.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Inside container
        scrollView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(purchaseButton.snp.top)
        }
        
        purchaseButton.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        // ScrollView content
        scrollViewContent.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        creditCardListView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.marginSmall)
            $0.left.right.equalToSuperview()
        }
        
        fakeCheckoutView.snp.makeConstraints {
            $0.top.equalTo(creditCardListView.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        // Add Apple Pay button if available
        var currentView: UIView = fakeCheckoutView
        if isApplePayAvailable {
            scrollViewContent.addSubview(applePayButton)
            applePayButton.snp.makeConstraints {
                $0.top.equalTo(fakeCheckoutView.snp.bottom).offset(UIConstants.marginDefault)
                $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
                $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
                $0.height.equalTo(UIConstants.buttonHeight)
            }
            
            currentView = applePayButton
        }
        
        let fakeTermsView = createFakeTermsView()
        scrollViewContent.addSubview(fakeTermsView)
        fakeTermsView.snp.makeConstraints {
            $0.top.equalTo(currentView.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.right.bottom.equalToSuperview()
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
        
        // 'Gemini Chart' item
        let geminiChartLabel = UILabel()
        geminiChartLabel.text = "Gemini Chart"
        geminiChartLabel.textColor = colorProvider.darkText
        geminiChartLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        geminiChartLabel.textAlignment = .left
        geminiChartLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        geminiChartLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(geminiChartLabel)
        
        let geminiPriceLabel = UILabel()
        geminiPriceLabel.text = itemOnePrice.formatted(.currency(code: "USD"))
        geminiPriceLabel.textColor = colorProvider.darkText
        geminiPriceLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        geminiPriceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        geminiPriceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.addSubview(geminiPriceLabel)
        
        let divider1 = createDividerLine()
        view.addSubview(divider1)
        
        geminiChartLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalTo(geminiPriceLabel.snp.left).offset(-UIConstants.marginTiny)
            $0.top.equalTo(yourCartLabel.snp.bottom).offset(20)
        }
        
        geminiPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(geminiChartLabel)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        divider1.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.top.equalTo(geminiChartLabel.snp.bottom).offset(UIConstants.marginSmall)
            $0.height.equalTo(0.5)
        }
        
        // 'Quickstart Kit' item
        let quickstartKitLabel = UILabel()
        quickstartKitLabel.text = "Quickstart Kit"
        quickstartKitLabel.textColor = colorProvider.darkText
        quickstartKitLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        quickstartKitLabel.textAlignment = .left
        quickstartKitLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        quickstartKitLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(quickstartKitLabel)
        
        let quickstartKitPriceLabel = UILabel()
        quickstartKitPriceLabel.text = itemTwoPrice.formatted(.currency(code: "USD"))
        quickstartKitPriceLabel.textColor = colorProvider.darkText
        quickstartKitPriceLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        quickstartKitPriceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        quickstartKitPriceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.addSubview(quickstartKitPriceLabel)
        
        let divider2 = createDividerLine()
        view.addSubview(divider2)
        
        quickstartKitLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalTo(quickstartKitPriceLabel.snp.left).offset(-UIConstants.marginTiny)
            $0.top.equalTo(divider1.snp.bottom).offset(UIConstants.marginSmall)
        }
        
        quickstartKitPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(quickstartKitLabel)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        divider2.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.top.equalTo(quickstartKitLabel.snp.bottom).offset(UIConstants.marginSmall)
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
            $0.top.equalTo(divider2.snp.bottom).offset(UIConstants.marginSmall)
        }
        
        taxesAndFeesLabelPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(taxesAndFeesLabel)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        // Total
        let totalLabel = UILabel()
        totalLabel.text = "Total"
        totalLabel.textColor = colorProvider.darkText
        totalLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        totalLabel.textAlignment = .left
        totalLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        totalLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(totalLabel)
        
        let totalLabelPriceLabel = UILabel()
        totalLabelPriceLabel.text = total.formatted(.currency(code: "USD"))
        totalLabelPriceLabel.textColor = colorProvider.darkText
        totalLabelPriceLabel.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        totalLabelPriceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        totalLabelPriceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.addSubview(totalLabelPriceLabel)
        
        totalLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalTo(totalLabelPriceLabel.snp.left).offset(-UIConstants.marginTiny)
            $0.top.equalTo(taxesAndFeesLabel.snp.bottom).offset(20)
        }
        
        totalLabelPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(totalLabel)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.bottom.equalToSuperview()
        }
        
        return view
    }
    
    func createFakeTermsView() -> UIView {
        let container = UIView()
        let termsLabel = UILabel()
        termsLabel.text = "Acme provides information you submit through this site to a vendor for security purposes. Please see the Privacy Policy for more information."
        termsLabel.textColor = colorProvider.mediumText
        termsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        termsLabel.numberOfLines = 0
        termsLabel.lineBreakMode = .byWordWrapping
        termsLabel.textAlignment = .left
        termsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        termsLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        container.addSubview(termsLabel)
        
        termsLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
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
        container.addSubview(termsFakeLink)
        
        termsFakeLink.snp.makeConstraints {
            $0.top.equalTo(termsLabel.snp.bottom).offset(UIConstants.marginTiny)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.bottom.equalToSuperview()
        }
        
        return container
    }
    
    func createDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = colorProvider.darkText
        return view
    }
    
    func applePayTapped() {
        // Start the apple pay flow using the SDK
        Task {
            await applePayCoordinator.performTransaction(amount: total,
                                                         applePayMerchantId: applePayMerchantId,
                                                         transactionType: .sale)
        }
    }
    
    func processApplePayResults(_ results: MobilePaymentsApplePayResult?) {
        // Check the apple pay transaction results
        guard let results = results else { return }
        switch results {
        case .success(let transaction):
            let message = "Transaction successful. Transaction ID: \(transaction.transactionId).\nPaid \(transaction.amount) \(transaction.currencyCode?.uppercased() ?? "USD")"
            showPopup(title: "Success!", message: message, from: self)
        case .failure(let error):
            showPopup(title: "Error!", message: error.error.localizedDescription, from: self)
        default:
            break
        }
    }
}

extension ComponentViewController: PurchaseButtonDelegate {
    func onTransactionCompleted(result: TransactionResult) {
        if let error = result.error {
            showPopup(title: "Error!", message: error.localizedDescription, from: self)
        } else if let transaction = result.transaction {
            let message = "Transaction successful. Transaction ID: \(transaction.transactionId).\nPaid \(transaction.amount) \(transaction.currencyCode?.uppercased() ?? "USD")"
            showPopup(title: "Success!", message: message, from: self)
        }
    }
}

extension ComponentViewController: CreditCardListDelegate {
    func onCreditCardSelected(card: FiservMobilePayments.CreditCard) {
        // Credit card selected
    }
}
