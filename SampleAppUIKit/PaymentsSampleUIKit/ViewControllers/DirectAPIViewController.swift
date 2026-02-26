//
//  DirectAPIViewController.swift
//  PaymentsSampleUIKit
//
//  Created by Allan Cheng on 2/25/26.
//

import Foundation
import SnapKit
import FiservMobilePayments

class DirectAPIViewController: UIViewController {
    var colorProvider: MobilePaymentsColorProvider = DefaultMobilePaymentsColorProvider()
    let transactionTypes: [TransactionType] = [.sale, .auth, .capture, .void]
    
    var authorizationCode: String?
    var transactionId: String?
    var selectedTransactionType: TransactionType?

    // Views
    private lazy var transactionIdTextField: UITextField = {
        let textField = UITextField()
        // Configure the styling
        textField.attributedPlaceholder = NSAttributedString(string: "Transaction ID",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.borderColor = colorProvider.darkText.cgColor
        textField.layer.cornerRadius = 10
        textField.backgroundColor = colorProvider.background
        textField.textColor = colorProvider.darkText
        textField.addTarget(self, action: #selector(transactionIdDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var authorizationCodeTextField: UITextField = {
        let textField = UITextField()
        // Configure the styling
        textField.attributedPlaceholder = NSAttributedString(string: "Authorization Code",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.borderColor = colorProvider.darkText.cgColor
        textField.layer.cornerRadius = 10
        textField.backgroundColor = colorProvider.background
        textField.textColor = colorProvider.darkText
        textField.addTarget(self, action: #selector(authorizationCodeDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var selectedTransactionTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Previous Transaction Type: "
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = colorProvider.darkText
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var selectedTransactionTypeTextField: UITextField = {
        let textField = UITextField()
        // Configure the styling
        textField.attributedPlaceholder = NSAttributedString(string: "Transaction Type",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.borderStyle = .none
        textField.backgroundColor = colorProvider.background
        textField.textColor = colorProvider.darkText
        textField.inputView = transactionTypePickerView
        textField.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        // Create a toolbar with a 'Done' button on the right to dismiss the picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPickerView))
        toolbar.setItems([space, doneButton], animated: false)
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    private lazy var transactionTypePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        // Configure the pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
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
    
    // Buttons
    private lazy var saleButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sale"
        config.baseBackgroundColor = colorProvider.primary
        config.baseForegroundColor = colorProvider.lightText
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.saleTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var voidButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Void"
        config.baseBackgroundColor = colorProvider.primary
        config.baseForegroundColor = colorProvider.lightText
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.voidTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var captureButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Capture"
        config.baseBackgroundColor = colorProvider.primary
        config.baseForegroundColor = colorProvider.lightText
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.captureTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var authButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Auth"
        config.baseBackgroundColor = colorProvider.primary
        config.baseForegroundColor = colorProvider.lightText
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.authTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colorProvider.background
        
        setupView()
    }
    
    func createTransactionTypeView() -> UIView {
        // Setup the 'Previous Transaction Type' view that will show/hide picker
        // Create a view to show/hide picker and show what was selected
        let container = UIView()
        
        // Chevron icon
        let chevronIcon = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevronIcon.contentMode = .scaleAspectFit
        
        container.addSubview(selectedTransactionTypeLabel)
        container.addSubview(selectedTransactionTypeTextField)
        container.addSubview(chevronIcon)
        
        selectedTransactionTypeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.marginSmall)
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-UIConstants.marginSmall)
            $0.right.equalTo(selectedTransactionTypeTextField.snp.left).offset(-UIConstants.marginSmall)
        }
        
        selectedTransactionTypeTextField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(chevronIcon.snp.left).offset(-UIConstants.marginSmall)
        }
        
        chevronIcon.snp.makeConstraints {
            $0.centerY.right.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        return container
    }
    
    func setupView() {
        // Add the views to the layout
        let contentContainer = UIView()
        let selectedTransactionTypeView = createTransactionTypeView()
        
        view.addSubview(contentContainer)
        contentContainer.addSubview(transactionIdTextField)
        contentContainer.addSubview(authorizationCodeTextField)
        contentContainer.addSubview(selectedTransactionTypeView)
        contentContainer.addSubview(saleButton)
        contentContainer.addSubview(authButton)
        contentContainer.addSubview(captureButton)
        contentContainer.addSubview(voidButton)
        
        // Setup the view constraints
        contentContainer.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        transactionIdTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.verticalScreenEdgeMargin)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
        }
        
        authorizationCodeTextField.snp.makeConstraints {
            $0.top.equalTo(transactionIdTextField.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
        }
        
        selectedTransactionTypeView.snp.makeConstraints {
            $0.top.equalTo(authorizationCodeTextField.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.lessThanOrEqualToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
        }
        
        saleButton.snp.makeConstraints {
            $0.top.equalTo(selectedTransactionTypeView.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
        }
        
        authButton.snp.makeConstraints {
            $0.top.equalTo(saleButton.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
        }
        
        captureButton.snp.makeConstraints {
            $0.top.equalTo(authButton.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
        }
        
        voidButton.snp.makeConstraints {
            $0.top.equalTo(captureButton.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
            $0.bottom.lessThanOrEqualToSuperview().offset(-UIConstants.verticalScreenEdgeMargin)
        }
    }
    
    @objc func dismissPickerView() {
        view.endEditing(true)
    }
    
    @objc func transactionIdDidChange(_ textField: UITextField) {
        transactionId = textField.text
        updateCTA()
    }
    
    @objc func authorizationCodeDidChange(_ textField: UITextField) {
        authorizationCode = textField.text
        updateCTA()
    }
    
    // Disable/enable CTA depending on if we have necessary data to perform the action
    func updateCTA() {
        if let transactionType = selectedTransactionType, let transactionId = transactionId, !transactionId.isEmpty {
            let acceptedVoidTypes: [TransactionType] = [.sale, .auth, .capture]
            voidButton.isEnabled = acceptedVoidTypes.contains(transactionType)
            if transactionType == .auth, let authorizationCode = authorizationCode, !authorizationCode.isEmpty {
                captureButton.isEnabled = true
            } else {
                captureButton.isEnabled = false
            }
        } else {
            voidButton.isEnabled = false
            captureButton.isEnabled = false
        }
    }
    
    func selectTransactionType(_ type: TransactionType) {
        guard let index = transactionTypes.firstIndex(of: type) else { return }
        transactionTypePickerView.selectRow(index, inComponent: 0, animated: false)
        selectedTransactionType = type
        selectedTransactionTypeTextField.text = type.rawValue
    }
    
    func showSpinner() {
        guard loadingOverlay.superview == nil else { return }
        view.addSubview(loadingOverlay)
    }
    
    func hideSpinner() {
        loadingOverlay.removeFromSuperview()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func transactionCompleted(type: TransactionType, result: TransactionResult) {
        var title: String = ""
        var message: String = ""
        if let error = result.error {
            // Show alert
            title = "Error"
            message = error.localizedDescription
            if let corrId = error.correlationId {
                message = "\(message) (\(corrId))"
            }
        } else if let transaction = result.transaction {
            // Update UI and data with transaction data
            transactionId = transaction.transactionId
            transactionIdTextField.text = transaction.transactionId
            authorizationCode = transaction.authorizationCode
            authorizationCodeTextField.text = transaction.authorizationCode
            selectTransactionType(type)
            updateCTA()
            
            // Show alert
            let chargedAmount = transaction.amount.formatted(.currency(code: transaction.currencyCode ?? "USD"))
            title = "Success"
            let messageText: String
            switch type {
            case .sale: messageText = "Charged \(chargedAmount)"
            case .auth: messageText = "Authorized \(chargedAmount)"
            case .capture: messageText = "Captured transaction."
            case .void: messageText = "Voided transaction."
            default: messageText = "Unknown action."
            }
            message = "\(messageText)\nTransaction ID = \(transaction.transactionId)."
        }
        
        // Show alert
        showAlert(title: title, message: message)
    }
    
    //MARK: - Direct API calls

    // Generate a test credit card
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
    
    // Create a payment transaction
    func createFakePayment() -> Payment<CreditCard> {
        let creditCard = generateTestCreditCard()
        // Random amount to charge
        let amount = Decimal(Int.random(in: 1...14_999)) / 100
        return Payment(amount: amount,
                       paymentMethod: creditCard,
                       merchantReference: nil)
    }
    
    // Generate a transaction object based on current data or entered values
    func generateTransaction() -> Transaction? {
        guard let transactionId = transactionId, let selectedTransactionType = selectedTransactionType else { return nil }
        return Transaction(transactionId: transactionId,
                           authorizationCode: authorizationCode,
                           transactionType: selectedTransactionType)
    }
    
    func saleTapped() {
        showSpinner()
        PaymentManager.shared.sale(payment: createFakePayment()) { [weak self] result in
            guard let self = self else { return }
            self.hideSpinner()
            let type = result.transaction?.transactionType ?? .sale
            self.transactionCompleted(type: type, result: result)
        }
    }
    
    func authTapped() {
        showSpinner()
        PaymentManager.shared.auth(payment: createFakePayment()) { [weak self] result in
            guard let self = self else { return }
            self.hideSpinner()
            let type = result.transaction?.transactionType ?? .auth
            self.transactionCompleted(type: type, result: result)
        }
    }
    
    func captureTapped() {
        guard let transaction = generateTransaction() else { return }
        showSpinner()
        PaymentManager.shared.capture(transaction: transaction) { [weak self] result in
            guard let self = self else { return }
            self.hideSpinner()
            let type = result.transaction?.transactionType ?? .auth
            self.transactionCompleted(type: type, result: result)
        }
    }
    
    func voidTapped() {
        guard let transaction = generateTransaction() else { return }
        showSpinner()
        PaymentManager.shared.void(transaction: transaction) { [weak self] result in
            guard let self = self else { return }
            self.hideSpinner()
            let type = result.transaction?.transactionType ?? .sale
            self.transactionCompleted(type: type, result: result)
        }
    }
}

//MARK: - UIPickerViewDataSource
extension DirectAPIViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // We are only displaying 1 column
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        transactionTypes.count
    }
}

//MARK: - UIPickerViewDelegate
extension DirectAPIViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard transactionTypes.count > row else { return nil }
        // Set the traction
        return transactionTypes[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard transactionTypes.count > row else { return }
        let selected = transactionTypes[row]
        selectedTransactionType = selected
        selectedTransactionTypeTextField.text = selected.rawValue
        updateCTA()
    }
}
