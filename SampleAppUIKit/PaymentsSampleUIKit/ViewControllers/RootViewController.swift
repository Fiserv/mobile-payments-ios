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
    
    // Views
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
        config.title = "Default"
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
    }
    
    func setupView() {
        let contentContainer = UIView()
        
        view.addSubview(contentContainer)
        contentContainer.addSubview(sheetsButton)
        contentContainer.addSubview(componentsButton)
        contentContainer.addSubview(guestCheckoutButton)
        contentContainer.addSubview(stylesLabel)
        contentContainer.addSubview(styleStackView)
        
        contentContainer.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        sheetsButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.verticalScreenEdgeMargin)
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
        // Present `MobilePaymentsPurchaseViewController` from the SDK
        let amount = Decimal(Int.random(in: 1...14_999)) / 100
        let vc = MobilePaymentsPurchaseViewController(amount: amount,
                                                      applePayMerchantId: applePayMerchantId)
        present(vc, animated: true)
    }
    
    func componentsTapped() {
        let vc = ComponentViewController()
        vc.title = "UI Components"
        vc.isApplePayAvailable = self.isApplePayAvailable
        if let colorProvider = self.colorProvider {
            vc.colorProvider = colorProvider
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func guestCheckoutTapped() {
        let vc = GuestCheckoutViewController()
        vc.title = "Guest Checkout"
        if let colorProvider = colorProvider {
            vc.colorProvider = colorProvider
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func directApiTapped() {
        let vc = DirectAPIViewController()
        vc.title = "Direct API"
        if let colorProvider = colorProvider {
            vc.colorProvider = colorProvider
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func applyStyleOne() {
        let font = CustomFontProvider()
        let color = CustomColorProvider()
        let shape = CustomShapeProvider()
        let style = MobilePaymentsStyleProvider(colors: color, fonts: font, shapes: shape)
        MobilePayments.shared.setStyle(style)
        navigationController?.navigationBar.barTintColor = color.background
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: color.darkText]
        self.colorProvider = style.colors
        showPopup(title: "Style #1 (Blocky Yellow) Applied", message: nil, from: self)
    }
    
    func applyStyleTwo() {
        let color = DarkColorProvider()
        let fonts = DarkFontProvider()
        let style = MobilePaymentsStyleProvider(colors: color, fonts: fonts)
        MobilePayments.shared.setStyle(style)
        navigationController?.navigationBar.barTintColor = color.background
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: color.darkText]
        self.colorProvider = style.colors
        showPopup(title: "Style #2 (Dark) Applied", message: nil, from: self)
    }
    
    func applyStyleThree() {
        let style = MobilePaymentsStyleProvider()
        MobilePayments.shared.setStyle(style)
        navigationController?.navigationBar.barTintColor = style.colors.background
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: style.colors.darkText]
        self.colorProvider = style.colors
        showPopup(title: "Default Applied", message: nil, from: self)
    }
}

