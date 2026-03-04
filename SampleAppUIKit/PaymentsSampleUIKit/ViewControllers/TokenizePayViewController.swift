//
//  TokenizePayViewController.swift
//  PaymentsSampleUIKit
//
//  Created by Allan Cheng on 3/4/26.
//

import Foundation
import FiservMobilePayments
import SnapKit
import PassKit
import Combine

class TokenizePayViewController: UIViewController {
    var colorProvider: MobilePaymentsColorProvider = DefaultMobilePaymentsColorProvider()
    
    // Define a payment state to be used with the SDK components for amount, credit cards, etc
    private let session = PaymentSession()
    
    // Views
    private lazy var purchaseButton: UIPurchaseButton = {
        let button = UIPurchaseButton(session: session, billingAddress: nil, delegate: self)
        button.add(to: self)
        return button
    }()
    
    private lazy var tokenizeCardButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Tokenize Card"
        config.baseBackgroundColor = colorProvider.primary
        config.baseForegroundColor = colorProvider.lightText
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.showAddCreditCard()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var tokenizedCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        label.textColor = colorProvider.darkText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "No credit card entered."
        return label
    }()
    
    // Spinner
    private lazy var loadingOverlay: UIView = {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = .black.withAlphaComponent(0.5)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Setup a spinner to show when data is loading
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.center = overlay.center
        spinner.startAnimating()
        
        // Add spinner to overlay
        overlay.addSubview(spinner)
        return overlay
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
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
        session.amount = total
        
        // Listen to transactionInProgress to show/hide spinner
        session.$transactionInProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isInProgress in
                if isInProgress {
                    self?.showSpinner()
                } else {
                    self?.hideSpinner()
                }
            }
            .store(in: &cancellables)
    }
    
    func setupView() {
        // Add views to the UI and setup the constraints
        let container = UIView()
        let scrollView = UIScrollView()
        let scrollViewContent = UIView()
        let fakeCheckoutView = createFakeCheckoutView()
        
        view.addSubview(container)
        container.addSubview(scrollView)
        container.addSubview(purchaseButton)

        scrollView.addSubview(scrollViewContent)
        scrollViewContent.addSubview(fakeCheckoutView)
        // Add the tokenize card button and label
        scrollViewContent.addSubview(tokenizeCardButton)
        scrollViewContent.addSubview(tokenizedCardLabel)
        
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
        
        fakeCheckoutView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.marginSmall)
            $0.left.right.equalToSuperview()
        }
        
        tokenizeCardButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.top.equalTo(fakeCheckoutView.snp.bottom).offset(UIConstants.marginDefault)
            $0.height.equalTo(UIConstants.buttonHeight)
        }
        
        tokenizedCardLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.top.equalTo(tokenizeCardButton.snp.bottom).offset(UIConstants.marginDefault)
            $0.bottom.equalToSuperview()
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
            $0.bottom.equalToSuperview()
        }
        
        totalLabelPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(totalLabel)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        return view
    }
    
    func createDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = colorProvider.darkText
        return view
    }
    
    func showAddCreditCard() {
        let viewController = CreditCardDetailsViewController(canSaveCard: false,
                                                             addressMode: .postalCode,
                                                             cardNumberMaskMode: .lastFourVisible,
                                                             delegate: self)
        present(viewController, animated: true)
    }
    
    // Spinners
    func showSpinner() {
        guard loadingOverlay.superview == nil else { return }
        view.addSubview(loadingOverlay)
    }
    
    func hideSpinner() {
        loadingOverlay.removeFromSuperview()
    }
}

//MARK: - PurchaseButtonDelegate
extension TokenizePayViewController: PurchaseButtonDelegate {
    func onTransactionCompleted(result: TransactionResult) {
        if let error = result.error {
            showPopup(title: "Error!", message: error.localizedDescription, from: self)
        } else if let transaction = result.transaction {
            let message = "Transaction successful. Transaction ID: \(transaction.transactionId).\nPaid \(transaction.amount) \(transaction.currencyCode?.uppercased() ?? "USD")"
            showPopup(title: "Success!", message: message, from: self)
        }
    }
}

extension TokenizePayViewController: CreditCardDetailsDelegate {
    func onCardAdded(_ card: CreditCard) {
        guard let token = card.token else { return }
        // Update UI
        let text = "Credit Card Token\n\(token)"
        var attrString = AttributedString(text)
        attrString.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        attrString.foregroundColor = colorProvider.darkText
        
        // Make the token a smaller font size
        if let range = attrString.range(of: token) {
            attrString[range].font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }
        
        tokenizedCardLabel.attributedText = NSAttributedString(attrString)
        
        // Add the tokenized card to the payment session to use as payment
        session.payment = card
    }
}

//MARK: - CreditCardListDelegate
extension TokenizePayViewController: CreditCardListDelegate {
    func onCreditCardSelected(card: FiservMobilePayments.CreditCard) {
        // Credit card selected
    }
}
