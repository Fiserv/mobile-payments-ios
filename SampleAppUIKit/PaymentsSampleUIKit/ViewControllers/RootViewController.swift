//
//  ViewController.swift
//  PaymentsSampleUIKit
//
//  Created by Allan Cheng on 2/19/26.
//

import UIKit
import FiservMobilePayments
import SnapKit

class RootViewController: UIViewController {
    private var colorProvider: MobilePaymentsColorProvider?
    private var isApplePayAvailable: Bool = false
    
    private lazy var customerIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Customer ID"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var sheetsButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sheets"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.sheetsTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var componentsButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "UI Components"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.componentsTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var guestCheckoutButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Guest Checkout"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.guestCheckoutTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var stylesLabel: UILabel = {
        let label = UILabel()
        label.text = "Styles"
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var styleOneButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Style #1"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.applyStyleOne()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var styleTwoButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Style #2"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.applyStyleTwo()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var styleThreeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Style #3"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.background.cornerRadius = UIConstants.buttonHeight / 2
        let button = UIButton(configuration: config)
        button.addAction(UIAction { _ in
            self.applyStyleThree()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var styleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = UIConstants.marginMedium
        stackView.addArrangedSubview(styleOneButton)
        stackView.addArrangedSubview(styleTwoButton)
        stackView.addArrangedSubview(styleThreeButton)
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Mobile Payments Sample App UIKit"
        
        loadConfigs()
        setupView()
        
        customerIdTextField.text = getCustomerId()
    }
    
    func setupView() {
        let contentContainer = UIView()
        
        view.addSubview(contentContainer)
        contentContainer.addSubview(customerIdTextField)
        contentContainer.addSubview(sheetsButton)
        contentContainer.addSubview(componentsButton)
        contentContainer.addSubview(guestCheckoutButton)
        contentContainer.addSubview(stylesLabel)
        contentContainer.addSubview(styleStackView)
        
        contentContainer.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        customerIdTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.verticalScreenEdgeMargin)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.textFieldHeight)
        }
        
        sheetsButton.snp.makeConstraints {
            $0.top.equalTo(customerIdTextField.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.buttonHeight)
        }
        
        componentsButton.snp.makeConstraints {
            $0.top.equalTo(sheetsButton.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.buttonHeight)
        }
        
        guestCheckoutButton.snp.makeConstraints {
            $0.top.equalTo(componentsButton.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
            $0.height.equalTo(UIConstants.buttonHeight)
        }
        
        stylesLabel.snp.makeConstraints {
            $0.top.equalTo(guestCheckoutButton.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
        
        styleStackView.snp.makeConstraints {
            $0.top.equalTo(stylesLabel.snp.bottom).offset(UIConstants.marginDefault)
            $0.left.equalToSuperview().offset(UIConstants.horizontalScreenEdgeMargin)
            $0.right.equalToSuperview().offset(-UIConstants.horizontalScreenEdgeMargin)
        }
    }
    
    func loadConfigs() {
        Task {
            self.isApplePayAvailable = (try? await PaymentManager.shared.canPayWithApplePay()) ?? false
        }
    }
    
    func sheetsTapped() {
        setCustomerId()
        // Present `MobilePaymentsPurchaseViewController` from the SDK
        let amount = Decimal(Int.random(in: 1...14_999)) / 100
        let text = customerIdTextField.text ?? ""
        let customerId = text.isEmpty ? nil : text
        let vc = MobilePaymentsPurchaseViewController(amount: amount,
                                                      customerId: customerId,
                                                      applePayMerchantId: applePayMerchantId)
        present(vc, animated: true)
    }
    
    func componentsTapped() {
        setCustomerId()
        let vc = ComponentViewController()
        vc.title = "UI Components"
        vc.isApplePayAvailable = self.isApplePayAvailable
        if let colorProvider = self.colorProvider {
            vc.colorProvider = colorProvider
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func guestCheckoutTapped() {
        setCustomerId()
        let vc = GuestCheckoutViewController()
        vc.title = "Guest Checkout"
        if let colorProvider = colorProvider {
            vc.colorProvider = colorProvider
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func applyStyleOne() {
        setCustomerId()
        let font = CustomFontProvider()
        let color = CustomColorProvider()
        let shape = CustomShapeProvider()
        let style = MobilePaymentsStyleProvider(colors: color, fonts: font, shapes: shape)
        MobilePayments.shared.setStyle(style)
        self.colorProvider = style.colors
        showPopup(title: "Style #1 (Yellow Block) Applied", message: nil, from: self)
    }
    
    func applyStyleTwo() {
        setCustomerId()
        let color = DarkColorProvider()
        let fonts = DarkFontProvider()
        let style = MobilePaymentsStyleProvider(colors: color, fonts: fonts)
        MobilePayments.shared.setStyle(style)
        self.colorProvider = style.colors
        showPopup(title: "Style #2 (Dark Rounded) Applied", message: nil, from: self)
    }
    
    func applyStyleThree() {
        setCustomerId()
        let style = MobilePaymentsStyleProvider()
        MobilePayments.shared.setStyle(style)
        self.colorProvider = style.colors
        showPopup(title: "Style #3 (Default) Applied", message: nil, from: self)
    }
    
    func setCustomerId() {
        let text = customerIdTextField.text ?? ""
        let customerId = text.isEmpty ? nil : text
        MobilePayments.shared.setCustomerId(customerId)
        UserDefaults.standard.set(customerId, forKey: "customerId")
    }
    
    func getCustomerId() -> String? {
        let customerId = UserDefaults.standard.string(forKey: "customerId")
        if customerId?.isEmpty == true {
            return nil
        } else {
            return customerId
        }
    }
}

