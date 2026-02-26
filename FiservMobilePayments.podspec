Pod::Spec.new do |spec|
  spec.name          = 'FiservMobilePayments'
  spec.version       = '1.0.6'
  spec.summary       = 'Fiserv\'s Mobile Payments SDK'
  spec.description   = 'Take and manage payments on iOS with Fiserv'
  spec.homepage      = 'https://github.com/fiserv/mobile-payments-ios'
  spec.license       = { :type => 'MIT',
                         :text => <<-LICENSE
                            MIT License

Copyright (c) 2026 Fiserv

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
                        LICENSE
                        }
  spec.authors       = { 'Allan' => 'allan.cheng@fiserv.com' }
  spec.platform      = :ios, '16.4'
  spec.swift_version = '5.0'
  spec.source        = { :http => 'https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.6/FiservMobilePayments.xcframework.zip' }
  spec.vendored_frameworks  = 'FiservMobilePayments.xcframework'
  spec.frameworks    = 'SwiftUI', 'UIKit', 'CryptoKit', 'PassKit'
end
