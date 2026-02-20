# UI Integration
Component integration is a more in-depth, and simultaneously more flexible integration process.  To embed the SDK's pre-built native UI components, you first need to select the desired components for the behavior you want and attach them to your existing UI in your desired arrangement. 

These UI components are exposed directly through the SDK instance. Each component behaves like a standard SwiftUI view, meaning you can apply standard modifiers like `.padding()` or `.frame()` directly to it. 

Although these are designed as a native SwiftUI view, the SDK also includes a fully compatible wrapper for UIKit codebases.

### Table of Contents
  * [Payment State](#payment-state)
  * [Credit Cards](#credit-cards)
  * [Purchase](#purchase)
  
## Payment State
State is an ObservableObject responsible for coordinating all UI components provided by the SDK. Each property is annotated with @Published, enabling observers to subscribe and respond to changes. If multiple SDK UI components are used, they must all share the same PaymentState instance or listen for changes from that shared instance.
#### Parameters
  * Amount
    * The amount to charge the customer
  * Credit Card
    * The list of saved objects. You may provide a custom list to manage the data yourself.
  * Selected Payment
    * The currently selected payment. You may pass a value to preselect a payment. Otherwise, the default card, if available, will be selected. Otherwise, the first payment in the list will be selected.
  * Selected Payment Valid
    * Bool to indicate whether the current selected payment is valid. This is mainly used in conjuction with requireCvv where if requireCvv is true, this flag will indicate whether or not the cvv has been entered
  * Transaction In Progress
    * Bool to indicate whether there is currently a transaction in progress. This can be used to update your UI to disable buttons or show spinners when this is true

## Credit Cards
Credit Cards in MobilePayments have two major UI elements, a Credit Card List primarily used for saving and managing Credit Cards associated with a provided Customer ID value, and a Credit Card Details UI used to collect the user’s Credit Card information and tokenize the data for usage elsewhere.

### Credit Card List
The Credit Card List is provided through the `CreditCardListView` View for SwiftUI or `UICreditCardListView` for UIView. This renders a vertical list of credit cards with support for adding new cards and deleting existing ones via a left-swipe gesture on a cell.

#### SwiftUI
```
import FiservMobilePayments

struct YourView: View {
    @ObservedObject private var state = PaymentState()
    
    var body: some View {
        ZStack {
           CreditCardListView(state: state,
                              customerId: customerId,
                              requireCvv: requireCvv) { card in
                    // User has selected a card
                    // Update your UI
                    self.updateUI()
           }
           .padding(.horizontal)
        }
    }
}
```

#### UIKit
```
import FiservMobilePayments

class YourViewController: UIViewController {
    private var state = PaymentState()
    
    private var cancellables = Set<AnyCancellable>()
        
    override func viewDidLoad {
        super.viewDidLoad()
        
        // If you want to listen to updates via PaymentState
        setupBindings()
        
        // Add the credit card view
        let creditCardView = UICreditCardListView(state: state,
                                                  customerId: customerId,
                                                  requireCvv: requireCvv, 
                                                  delegate: self)
        creditCardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(creditCardView)
        // Important!
        creditCardView.add(to: self)
        // Add your layout constraints
    }
    
    func setupBindings() {
        // Optional binding to listen to updates
        state.$selectedPayment
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCard in
               // update UI based on selected card
               updateUI()
        }
        .store(in: &cancellable)
    }
}

// Optional delegate to implement if you want to subscribe for updates
// Can also subscribe to paymentState
extension YourViewController: CreditCardListDelegate {
     func onCreditCardSelected(card: CreditCard) {
        // User has selected a card
        // Update your UI
        updateUI()
     }
}
```

#### Parameters
  * Payment State
    * An observable object that you can subscribe to for updates such as credit card selected or getting the list of credit cards
  * **(OPTIONAL)** Customer ID
    * You can provide a specific Customer ID here. If omitted, the SDK defaults to the ID provided during `MobilePayments.shared.setCustomerId()` call.
  * **(OPTIONAL)** Scrolling Enabled
    * Whether or not scrolling the List is possible.  This only matters in the event the space provided to the `CreditCardListView` through the Modifier or host UI arrangement is smaller than its contents, or the List is embedded inside another scrolling Composable.
  * **(OPTIONAL)** Show Selectors
    * Flag to show or hide the radio button selection indicator.  Defaults to true
  * **(OPTIONAL)** Require CVV
    * Flag to require CVV value when reusing previously saved `CreditCards`.  Defaults to nil
  * **(OPTIONAL)** Can Add Cards
    * Flag to allow adding a `CreditCard` through the `CreditCardListView`.  Defaults to true
  * **(OPTIONAL)** On Credit Card Selected (SwiftUI only)
    * A callback invoked whenever the user selects a card in the list.
  * **(OPTIONAL)** Credit Card List Delegate (UIKit only)
    * A delegate invoked whenever the user selects a card in the list.

### Credit Card Details
Credit Card Details is handled through two UI components.  The `CreditCardDetailsModal`, for a modal, modular display that can easily slot anywhere its needed, and the `CreditCardDetailsView` for embedding the UI directly into the host UI.

#### Modal
`CreditCardDetailsModal` is a self-contained modal UI widget designed to be a quick and easy way to slot `CreditCardDetailsView` into nearly any UI design.  It is a bottom sheet that slides up from the bottom and will need to be presented as a full screen cover.

#### SwiftUI
```
import FiservMobilePayments

struct YourSwiftUIView: View {
    @State showAddCreditCard: Bool = false
    
    var body: some View {
        Button {
            // When this button is pressed, showAddCreditCard will be set to true
            // to present fullScreenCover of CreditCardDetailsModal
                showAddCreditCard = true
        }, label: {
            Text("Show Add Credit Card Modal!")
        }
    }
    .fullScreenCover($showAddCreditCard) {
            CreditCardDetailsModal(customerId: customerId,
                                   canSaveCard: canSaveCard,
                                   amount: amount,
                                   billingAddress: billingAddress) { addedCard in
                                       // Card was added
                                       // Update UI
                                       updateUI(card: addedCard)
                                   }
    }
}
```

#### UIKit
```
let viewController = CreditCardDetailsViewController(customerId: customerId,
                                                     canSaveCard: canSaveCard,
                                                     amount: amount,
                                                     billingAddress: billingAddress, 
                                                     delegate: self)
present(viewController, animated: true)
```
and implement the delegate to receive the results:
```
extension YourViewController: CreditCardDetailsDelegate {
    func onCardAdded(_ card: CreditCard) {
          // Card was added
          // Update UI
          updateUI(card: addedCard)
    }
}
```

##### Parameters
  * **(OPTIONAL)** Customer ID
    * A unique alphanumeric string identifying a single user in order to access previously saved Credit Cards and save new ones for a future transaction.  This value is the same as that passed to `MobilePayments.setCustomerId`, and can be omitted if you have set it there or if you do not wish to allow users to save Credit Cards and use them again in future.
  * **(OPTIONAL)** Can Save Card
    * Flag to allow the customer to save the `CreditCard` to the provided Customer ID.  Defaults to true
  * **(OPTIONAL)** Amount
    * Amount to show on the button label in the event where `autoSubmitAfterAddingCard` is true
  * **(OPTIONAL)** Billing Address
    * `BillingAddress` to use as the billing address for this payment.
  * **(OPTIONAL)** On Card Added
    * Closure invoked when a CreditCard is successfully tokenized and is passed to the calling UI

#### View
**Note:** It is strongly recommended you do not use the CreditCardDetailsView if you are already making use of the CreditCardListView with canAddCards = true or if you are leveraging the CreditCardDetailsModal in any way.

Credit Card Details is handled through the `CreditCardDetailsView`, a vertical stack containing a collection of input fields.  It is designed to take user text input and when prompted convert it into a tokenized `CreditCard` object and, if a Customer ID value is provided and the user allows it, save the card to the provided Customer ID.

To embed the `CreditCardDetailsView`, you must simply add the Composable where you wish in your UI, as so:

#### SwiftUI
```
import FiservMobilePayments

struct YourView: View {    
    var body: some View {
        ZStack {
            CreditCardDetailsView(customerId: customerId,
                                  canSaveCard: canSaveCard,
                                  amount: amount,
                                  billingAddress: billingAddress) { addedCard in
                                      // Card was added
                                      // Update UI
                                      updateUI(card: addedCard)
                                  }
           }
           .padding(.horizontal)
        }
    }
}
```
#### UIKit
```
import FiservMobilePayments

class YourViewController: UIViewController {
    override func viewDidLoad {
        super.viewDidLoad()
        
        // Add the credit card view
        let creditCardView = UICreditCardDetailsView(customerId: customerId,
                                                     canSaveCard: canSaveCard,
                                                     amount: amount,
                                                     billingAddress: billingAddress 
                                                     delegate: self)
        creditCardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(creditCardView)
        // Important!
        creditCardView.add(to: self)                                       
        // Add your layout constraints
    }
}
```
and implement the delegate to receive the results:
```
extension YourViewController: CreditCardDetailsDelegate {
    func onCardAdded(_ card: CreditCard) {
          // Card was added
          // Update UI
          updateUI(card: addedCard)
    }
}
```

##### Parameters
  * **(OPTIONAL)** Customer ID
    * A unique alphanumeric string identifying a single user in order to access previously saved Credit Cards and save new ones for a future transaction.  This value is the same as that passed to `MobilePayments.setCustomerId`, and can be omitted if you have set it there or if you do not wish to allow users to save Credit Cards and use them again in future.
  * **(OPTIONAL)** Can Save Card
    * Flag to allow the customer to save the `CreditCard` to the provided Customer ID.  Defaults to true
  * **(OPTIONAL)** Amount
    * Amount to show on the button label in the event where `autoSubmitAfterAddingCard` is true
  * **(OPTIONAL)** Billing Address
    * `BillingAddress` to use as the billing address for this payment.
  * **(OPTIONAL)** Delegate
    * Delegate to receive callbacks when a credit card has been added
   
### Purchase
Purchase in MobilePayments has only one UI element, the `PurchaseButton`.  This element will display the amount being charged, and display a button that will automatically be enabled when all parameters are ready for a transaction.  When pressed, the button will charge the provided amount to the provided payment method and return the resulting `Transaction`.

`PurchaseButton` operates in two ways, `Standard` and `OneTimeUse`.
  1. `Standard` mode is an integration with the `CreditCardListView` or similar widget from the host UI that will provide ultimately a valid `PaymentMethod` from the customer.  When the PaymentMethod and amount are provided to the `PurchaseButton` in this mode, the button becomes enabled and the customer can press the button to initiate the transaction
  2. `OneTimeUse` mode is a standalone mode where, if a `PaymentMethod` is not provided, when the customer presses the button, the `CreditCardDetailsModal` will open, allowing the customer to enter their `CreditCard` information and proceed through the transaction immediately

To integrate the `PurchaseButton`, add it to your SwiftUI view hierarchy or attach it to your view controller’s view. 

#### SwiftUI
```
import FiservMobilePayments
          
struct YourView: View {
    @ObservedObject private var state = PaymentState()
    
    var body: some View {
        ZStack {
                PurchaseButton(state: state,
                               transactionType: transactionType,
                               customerId: customerId,
                               billingAddress: billingAddress,
                               clientTransactionId: clientTransactionId,
                               merchantReference: merchantReference) { result in
                    if let error = result.error {
                        // Transaction failed
                        print("Error: \(error.localizedDescription)")
                    } else if let transaction = result.transaction {
                        // Transaction success
                    }
                }
           }
           .padding(.horizontal)
        }
    }
}
```

#### UIKit:
```
import FiservMobilePayments

class YourViewController: UIViewController {
    private var state = PaymentState()
            
    override func viewDidLoad {
        super.viewDidLoad()
        
        // Add the credit card view
        let purchaseButton = UIPurchaseButton(state: state,
                                              transactionType: transactionType,
                                              customerId: customerId,
                                              billingAddress: billingAddress,
                                              clientTransactionId: clientTransactionId,
                                              merchantReference: merchantReference,
                                              delegate: self)
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(purchaseButton)
        // Important!
        purchaseButton.add(to: self)
        // Add your layout constraints
    }
}

// Delegate to implement if you want to subscribe for transaction updates
extension YourViewController: PurchaseButtonDelegate {
     func onTransactionCompleted(result: TransactionResult) {
            if let error = result.error {
                // Transaction failed
                print("Error: \(error.localizedDescription)")
            } else if let transaction = result.transaction {
                // Transaction success
            }
     }
}
```

#### Parameters
  * Payment State
    * An observable object that you can subscribe to for updates such as credit card selected or getting the list of credit cards
  * **(OPTIONAL)** Show Total
    * Flag to control whether to show the total to the left of the button
  * **(OPTIONAL)** Transaction Type
    * The type of Payment you are seeking to collect.  The options are `TransactionType.SALE` or `TransactionType.AUTH`.  Simply put, `SALE` is used to collect funds immediately, while `AUTH` will reserve funds on the payment method, but will not collect them until a `CAPTURE` transaction is run in the future.
  * **(OPTIONAL)** Customer ID
    * A unique alphanumeric string identifying a single user in order to access previously saved Credit Cards and save new ones for a future transaction.  This value is the same as that passed to `MobilePayments.setCustomerId`, and can be omitted if you have set it there or if you do not wish to allow users to save
  * **(OPTIONAL)** Can Save Card
    * Flag to allow the customer to save the `CreditCard` to the provided Customer ID.  Defaults to true
  * **(OPTIONAL)** Purchase Button Operation Mode
    * Flag to control the operation mode of the `PurchaseButton`.  Defaults to `standard`
  * **(OPTIONAL)** Billing Address
    * `BillingAddress` to use as the billing address for this payment.
  * **(OPTIONAL)** Client Transaction Id
    * An identifier for the transaction, used for tracking purposes. Defaults to a randomly generated UUID if not supplied.
  * **(OPTIONAL)** Merchant Reference
    * A reference value for the transaction, usually the ticket or order number
  * **(OPTIONAL)** Transaction Completed (SwiftUI)
    * Closure invoked when the `Payment` is completed.  The result will be returned as a `TransactionResult` object. If the operation succeeds, a `Transaction` object is provided. If it fails, an `Error` is returned and may be accompanied by a `Transaction` object containing additional failure details.
  * **(OPTIONAL)** Delegate (UIKit)
    * When the `Payment` is completed, the result will be to the delegate's `onTransactionCompleted` as a `TransactionResult` object. If the operation succeeds, a `Transaction` object is provided. If it fails, an `Error` is returned and may be accompanied by a `Transaction` object containing additional failure details.
