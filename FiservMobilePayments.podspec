Pod::Spec.new do |spec|
  spec.name          = 'FiservMobilePayments'
  spec.version       = '1.0.0'
  spec.summary       = 'Fiserv\'s Mobile Payments SDK'
  spec.description   = 'Take and manage payments on iOS with Fiserv'
  spec.homepage      = 'https://github.com/fiserv/mobile-payments-ios'
  spec.license       = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors       = { 'Allan' => 'allan.cheng@fiserv.com' }
  spec.platform      = :ios, '16.4'
  spec.swift_version = '5.0'
  spec.source        = { :git => 'https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.0/FiservMobilePayments.xcframework.zip' }
  spec.vendored_frameworks  = 'FiservMobilePayments.xcframework'
  spec.frameworks    = 'SwiftUI', 'UIKit', 'CryptoKit', 'PassKit'
end
