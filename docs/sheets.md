# Sheets
Sheets integration is simply presenting the SwiftUI.View `MobilePaymentsPurchaseView` with methods like [fullScreenCover](https://developer.apple.com/documentation/swiftui/view/fullscreencover%28ispresented:ondismiss:content:%29) for SwiftUI or by presenting `MobilePaymentsPurchaseViewController` in your ViewController for UIKit

## Launching the UI
### SwiftUI
```
struct YourSwiftUIView: View {
    @State showPurchaseView: Bool = false
    
    var body: some View {
        Button {
            // When this button is pressed, showPurchaseView will be set to true
            // to present fullScreenCover of MobilePaymentsPurchaseView
            showPurchaseView = true
        }, label: {
            Text("Show Purchase View!")
        }
    }
    .fullScreenCover($showPurchaseView) {
        MobilePaymentsPurchaseView(amount: amount,
                                   customerId: customerId,
                                   applePayMerchantId: "merchant.com.your.applepay.merchant.id",
                                   applePayButtonLabel: .checkout,
                                   applePayButtonStyle: .black,
                                   delegate: self)
       )
    }
}
```
And also implement the MobilePaymentsPurchaseDelegate to receive the results
```
extension YourSwiftUIView: MobilePaymentsPurchaseDelegate {
    func onTransactionCompleted(transaction: FiservMobilePayments.Transaction) {
        // User finished paying and was successfully charged or authorized depending on what TransactionType you set. 
        // The information of the transaction is within the `Transaction` object
    }
    
    func onTransactionCanceled() {
        // User canceled the transaction
    }
}
```

### UIKit
```
let viewController = MobilePaymentsPurchaseViewController(amount: amount,
                                                          customerId: customerId,
                                                          applePayMerchantId: "merchant.com.your.applepay.merchant.id",
                                                          applePayButtonLabel: .checkout,
                                                          applePayButtonStyle: .black,
                                                          delegate: self)
present(viewController, animated: true)
```
and like in SwiftUI, implement the delegate to receive the results
```
extension YourViewController: MobilePaymentsPurchaseDelegate {
    func onTransactionCompleted(transaction: FiservMobilePayments.Transaction) {
        // User finished paying and was successfully charged or authorized depending on what TransactionType you set. 
        // The information of the transaction is within the `Transaction` object
    }
    
    func onTransactionCanceled() {
        // User canceled the transaction
    }
}
```

### Parameters
  * Amount 
    * A Double that represents the amount to charge the selected Payment method.  If this value is not set, then the Activity will immediately close and return RESULT_CANCELED
  * **(OPTIONAL)** Customer ID
    * A unique alphanumeric string identifying a single user in order to access previously saved Credit Cards and save new ones for a future transaction.  This value is the same as that passed to `MobilePayments.setCustomerId`, and can be omitted if you have set it there or if you do not wish to allow users to save Credit Cards and use them again in future.
  * **(OPTIONAL)** Require CVV
    * Flag to require CVV when re-using previously saved `CreditCards` for this transaction
  * **(OPTIONAL)** Billing Address
    * `Address` to use as the billing address for this transaction.
  * **(OPTIONAL)** Apple Pay Merchant ID
    * The Apple Pay Merchant ID you use in your app to process Apple Pay transactions. Provide it if you wish to use Apple Pay as a payment method
  * **(OPTIONAL)** Apple Pay Button Label
    * Requires SwiftUI and PassKit to be imported. Allows the customization of the label for the Apple Pay button. Refer to https://developer.apple.com/documentation/passkit/paywithapplepaybuttonlabel
  * **(OPTIONAL)** Apple Pay Button Style
    * Requires SwiftUI and PassKit to be imported. Allows the customization of the color for the Apple Pay button. Refer to https://developer.apple.com/documentation/ApplePayontheWeb/ApplePayButtonStyle
  * **(OPTIONAL)** Transaction Type
    * The type of Payment you are seeking to collect.  The options are `TransactionType.SALE` or `TransactionType.AUTH`.  Simply put, `SALE` is used to collect funds immediately, while `AUTH` will reserve funds on the payment method, but will not collect them until a `CAPTURE` transaction is run in the future. MobilePayments will default to SALE if this parameter is not set.
  * **(OPTIONAL)** Client Transaction Id
    * An identifier for the transaction, used for tracking purposes. Defaults to a randomly generated UUID if not supplied.
  * **(OPTIONAL)** Merchant Reference
    * A reference value for the transaction, usually the ticket or order number
  * **(OPTIONAL)** Delegate
    * `MobilePaymentsPurchaseDelegate` to receive callback for transaction updates
