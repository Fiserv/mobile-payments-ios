# Apple Pay
The SDK includes helper methods for Apple Pay transactions, from verifying availability to executing the transaction end-to-end. To use this feature, your Apple Pay configurations must be fully set up on our remote server.

### Table of Contents
  * [Manual Implementation](#Manual Implementation)
  * [Apple Pay Coordinator](#apple-pay-coordinator)
    
## Manual Implementation
For developer-managed transactions, use the SDK’s helper methods to implement your flow.

### Generating PKPayment
To request an Apple Pay payment, a PKPayment object must be created. Our SDK assists by providing this object through the `PaymentManager`.
```
do {
    if let pkPayment = PaymentManager.shared.createAPPaymentRequest(amount: amount, applePayMerchantId: applePayMerchantId) {
        ...
    }
} catch {
   // Error - Make sure you have your Apple Pay configurations fully setup on our remote server.
}
```
#### Parameters
  * Amount
    * The amount as `Decimal` to charge in this Apple Pay transaction
  * Apple Pay Merchant ID
    * The Apple Pay Merchant ID you use in your app to process Apple Pay transactions. Provide it if you wish to use Apple Pay as a payment method.
    
Then you will be able to pass this PKPayment object to Apple's `PKPaymentAuthorizationViewController` to start the Apple Pay transaction
```
if let controller = PKPaymentAuthorizationViewController(paymentRequest: request) {
      controller.delegate = self
      present(controller, animated: true)
}
```
Once the user has authorized the payment, you can call our APIs to charge them.
```
extension PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment) async -> PKPaymentAuthorizationResult {
        let applePayPayment = ApplePay(payment: payment)
        guard applePayPayment.isSuccess else {
            return PKPaymentAuthorizationResult(status: .failure, errors: nil)
        }
        // Generate a Payment object
        let payment: Payment<ApplePay> = Payment(clientTransactionId: clientTransactionId ?? UUID().uuidString,
                                                 amount: amount,
                                                 paymentMethod: applePayPayment,
                                                 merchantReference: merchantReference)
        // Call sales our auth
        let result = await PaymentManager.shared.sale(payment: payment)
        // Check the results
        if let error = result.error {
            return PKPaymentAuthorizationResult(status: .failure, errors: [error])
        } else {
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        }
    }
}
```
    
### Check Apple Pay Availability
The SDK also provides a method to check if Apple Pay is available on the user’s device, allowing you to adjust your UI accordingly. This also requires you to be fully set up with our remote server
```
let isApplePayAvailable = try await PaymentManager.shared.canPayWithApplePay()
```

## Apple Pay Coordinator
ApplePayCoordinator is an ObservableObject responsible for managing Apple Pay functionality end-to-end, for cases where you want the SDK to handle the entire flow. Simply set it up by initialize the object and listen to the results.
#### SwiftUI
```
@StateObject private var applePayCoordinator = MobilePaymentsApplePayCoordinator()
var body: some View {
    VStack {
       ...
    }
    .onChange(of: applePayCoordinator.paymentResults) { _, result in
        guard let result = result else { return }
        state.transactionInProgress = false
        DispatchQueue.main.async {
            switch result {
            case .success(let transaction):
                // Transaction success
            case .failure(let error):
                // Transaction failed
            default:
                break
            }
        }
    }
}
```
#### UIKit
```
private var applePayCoordinator = MobilePaymentsApplePayCoordinator()
    
private var cancellables = Set<AnyCancellable>()
        
override func viewDidLoad {
    super.viewDidLoad()
        
    // If you want to listen to updates via PaymentState
    setupBindings()
}
    
func setupBindings() {
    // Optional binding to listen to updates
    state.$paymentResults
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            guard let result = result else { return }
            switch result {
            case .success(let transaction):
                // Transaction success
            case .failure(let error):
                // Transaction failed
            default:
                break
            }
    }
    .store(in: &cancellable)
}
```
Then call MobilePaymentsApplePayCoordinator.performTransaction to start the Apple Pay transaction
```
await applePayCoordinator.performTransaction(amount: 13.37,
                                             applePayMerchantId: "com.merchant.your.apple.pay.merchant.id",
                                             transactionType: .sale)
```

#### Parameters
  * Amount
    * The amount as `Decimal` to charge in this Apple Pay transaction
  * The Apple Pay Merchant ID you use in your app to process Apple Pay transactions. Provide it if you wish to use Apple Pay as a payment method.
  * **(OPTIONAL)** Transaction Type
    * The type of Payment you are seeking to collect.  The options are `TransactionType.SALE` or `TransactionType.AUTH`.  Simply put, `SALE` is used to collect funds immediately, while `AUTH` will reserve funds on the payment method, but will not collect them until a `CAPTURE` transaction is run in the future. MobilePayments will default to SALE if this parameter is not set.
  * **(OPTIONAL)** Client Transaction Id
    * An identifier for the transaction, used for tracking purposes. Defaults to a randomly generated UUID if not supplied.
  * method
  * **(OPTIONAL)** Merchant Reference
    * A reference value for the transaction, usually the ticket or order number

#### Results
The results are returned as an `MobilePaymentsApplePayResult` enum.
```
/// Successful transaction
case success(Transaction)
/// Transaction failed. Transaction data may be returned in the struct for more information
case failure(ApplePayTransactionError)
/// Apple pay was dismissed
case dismissed
```
The error struct is defined as
```
struct ApplePayTransactionError {
    /// Transaction data
    /// May also be passed back even in the event of an error
    public let transaction: Transaction?
    /// The error describing the failure for the transaction request
    public let error: Error
}
```
An `Error` will be provided. In some cases, a `Transaction` object is also provided to give additional details about the payment.
