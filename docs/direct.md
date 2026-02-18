# Direct
Direct integration is the most powerful and flexible of the integrations available, but that comes with some tradeoffs.  You have complete freedom to build any UI design, but you will need to manage additional elements of the design, such as UI state, and provide the necessary information from the UI to the MobilePayments SDK.  Once you have constructed the UI to your specifications, you then need to invoke the relevant Mobile Payments API where appropriate. The SDK provides support for both modern `Swift Concurrency (async/await)` and traditional `Completion Handlers (closures)` for the API calls. You can choose the style that best fits your codebase.

The MobilePayments APIs are broken into several distinct categories, which you can find below.

### Table of Contents
  * [Credit Cards](#credit-cards)
  * [Payments](#payments)
  * [General](#general)
  * [Javadocs](#javadocs)

## Credit Cards
Credit Cards are handled through the `CreditCardManager` object.  This is a singleton reference to contain all Credit Card interactions with the MobilePayments API.

### Retrieving Saved Credit Cards
Retrieves the saved credit cards for a specific customer.
```
retrieveCreditCards(customerId: String?)
```
* **`customerId`** *(Optional)*: You can provide a specific Customer ID here. If omitted, the SDK defaults to the ID provided during `MobilePayments.shared.setCustomerId()` call.

#### Option 1: Async / Await
```
do {
    let cards = try await CreditCardManager.shared.retrieveCreditCards()
    print("Success!")
} catch {
    print("Error: \(error.localizedDescription)")
}
```
#### Option 2: Completion Handler
```
CreditCardManager.shared.retrieveCreditCards() { result in
    switch result {
    case .success(let cards):
        print("Success!")
    case .failure(let error):
        print("Error: \(error.localizedDescription")")"
    }
}
```

### Adding a Credit Card
Tokenizes the provided credit card and optionally allow it to be saved to a customer's profile.
```
addCreditCard(creditCard: CreditCard, customerId: String?, save: Bool)
```
* **`creditCard`**:
    * A CreditCard object containing all the necessary information for a Credit Card to be tokenized
* **`customerId`** *(Optional)*: 
    * You can provide a specific Customer ID here. If omitted, the SDK defaults to the ID provided during `MobilePayments.shared.setCustomerId()` call.
* **`save`**:
    * If `true`, the card will be saved to the customer's profile for future transactions.

#### Option 1: Async / Await
```
do {
    let tokenizedCard = try await CreditCardManager.shared.addCreditCard(creditCard: card, save: true)
    print("Success!")
} catch {
    print("Error: \(error.localizedDescription)")
}
```
#### Option 2: Completion Handler
```
CreditCardManager.shared.addCreditCard(creditCard: card, save: true) { result in
    switch result {
    case .success(let tokenizedCard):
        print("Success!")
    case .failure(let error):
        print("Error: \(error.localizedDescription")")"
    }
}
```

### Deleting a Credit Card
This method will delete a tokenized card from the remote server.  If it had been saved to a Customer ID, it will be removed from that reference as well.
```
deleteCreditCard(creditCard: CreditCard)
```
* **`creditCard`**:
    * A tokenized `CreditCard` object to be deleted
    
#### Option 1: Async / Await
```
do {
    try await CreditCardManager.shared.deleteCreditCard(creditCard: card)
    print("Success!")
} catch {
    print("Error: \(error.localizedDescription)")
}
```
#### Option 2: Completion Handler
```
CreditCardManager.shared.deleteCreditCard(creditCard: card) { result in
    switch result {
    case .success:
        print("Success!")
    case .failure(let error):
        print("Error: \(error.localizedDescription")")"
    }
}
```

## Payments
Payments are handled through the `PaymentManager` object.  Like `CreditCardManager`, it is a singleton that contains all Payments interactions with the MobilePayments API.

### Parameter: Payment
A strongly-typed container for processing payments. The `Method` generic allows you to use different payment types (e.g., Credit Card, Apple Pay, Gift Cards) while maintaining type safety.
```
  struct Payment<Method>(clientTransactionId: String?, amount: Decimal, method: PaymentMethod, merchantReference: String?)
```
  * **(OPTIONAL)** Client Transaction Id
    * An identifier for the transaction, used for tracking purposes. Defaults to a randomly generated UUID if not supplied.
  * amount
    * The amount of money to charge the provided PaymentMethod
  * method
    * The `PaymentMethod` object to charge against.
  * **(OPTIONAL)** Merchant Reference
    * A reference value for the transaction, usually the ticket or order number

```
let applePayPayment = ApplePay(payment: pkPayment)
let payment: Payment<ApplePay> = Payment(clientTransactionId: nil,
                                         amount: amount,
                                         paymentMethod: applePayPayment,
                                         merchantReference: nil)
```

### Return Value: TransactionResult
A container that holds either the successful `Transaction` response or an `Error`. In the event of an error, a `Transaction` object may still be returned for more information about the transaction.

#### Sale
Perform a `SALE` transaction against the provided `Payment`, capturing the charge and immediately transferring funds
```
sale(pament: Payment<Method>)
```
* **`payment`**:
    * The `Payment<Method>` to charge against
    
##### Option 1: Async / Await
```
let result = await PaymentManager.shared.sale(payment: creditCardPayment)
if let error = result.error {
    print("Error: \(error.localizedDescription")")"
    if let transaction = result.transaction {
        print("Result Message: \(transaction.gatewayResultMessage)")
    }
} else {
    print("Success!")
}
```
##### Option 2: Completion Handler
```
PaymentManager.shared.sale(payment: creditCardPayment) { result in
    if let error = result.error {
        print("Error: \(error.localizedDescription")")"
        if let transaction = result.transaction {
            print("Result Message: \(transaction.gatewayResultMessage)")
        }
    } else {
        print("Success!")
    }
}
```

#### Authorize
```
auth(payment: Payment<Method>)
```
Perform an `AUTH` transaction against the provided `Payment`, placing an authorization on the provided `PaymentMethod` for the provided amount but not transferring funds until the transaction is captured.
* **`payment`**:
    * The `Payment<Method>` to authorize
    
##### Option 1: Async / Await
```
let result = await PaymentManager.shared.auth(payment: creditCardPayment)
if let error = result.error {
    print("Error: \(error.localizedDescription")")"
    if let transaction = result.transaction {
        print("Result Message: \(transaction.gatewayResultMessage)")
    }
} else {
    print("Success!")
}
```
##### Option 2: Completion Handler
```
PaymentManager.shared.auth(payment: creditCardPayment) { result in
    if let error = result.error {
        print("Error: \(error.localizedDescription")")"
        if let transaction = result.transaction {
            print("Result Message: \(transaction.gatewayResultMessage)")
        }
    } else {
        print("Success!")
    }
}
```

### Transactions
Transactions are operations run against previously made `Payments`.  There are two functions available, both of which require a `Transaction` object with a valid Transaction ID.
```
Transaction(transactionId: String)
```
  *  Transaction ID
    * The Mobile Payments `Transaction ID` value, provided by the `Transaction` object return to `PaymentManager` methods

#### Capture
Perform a `CAPTURE` on the `Transaction`, transferring the authorized funds from the original PaymentMethod immediately
```
capture(transaction: Transaction)
```
* **`Transaction`**:
    * The `Transaction` to capture

##### Option 1: Async / Await
```
let result = await PaymentManager.shared.capture(transaction: transaction)
if let error = result.error {
    print("Error: \(error.localizedDescription")")"
    if let transaction = result.transaction {
        print("Result Message: \(transaction.gatewayResultMessage)")
    }
} else {
    print("Success!")
}
```
##### Option 2: Completion Handler
```
PaymentManager.shared.capture(transaction: transaction) { result in
    if let error = result.error {
        print("Error: \(error.localizedDescription")")"
        if let transaction = result.transaction {
            print("Result Message: \(transaction.gatewayResultMessage)")
        }
    } else {
        print("Success!")
    }
}
```

#### Void
This method will `VOID` the `Transaction`, canceling the previous authorization and freeing the funds for the customer to use elsewhere.
```
void(transaction: Transaction)
```
* **`Transaction`**:
    * The `Transaction` to void
    
##### Option 1: Async / Await
```
let result = await PaymentManager.shared.void(transaction: transaction)
if let error = result.error {
    print("Error: \(error.localizedDescription")")"
    if let transaction = result.transaction {
        print("Result Message: \(transaction.gatewayResultMessage)")
    }
} else {
    print("Success!")
}
```
##### Option 2: Completion Handler
```
PaymentManager.shared.void(transaction: transaction) { result in
    if let error = result.error {
        print("Error: \(error.localizedDescription")")"
        if let transaction = result.transaction {
            print("Result Message: \(transaction.gatewayResultMessage)")
        }
    } else {
        print("Success!")
    }
}
```

### Transaction Details
```
retrieveTransaction(transactionId: String)
```
This method will retrieve the current details of a transaction through its `transactionId`
* **`Transaction ID`**:
    * An identifier provided by a `Transaction` after it is processed    
    
#### Option 1: Async / Await
```
let result = await PaymentManager.shared.retrieveTransaction(transactionId: id)
if let error = result.error {
    print("Error: \(error.localizedDescription")")"
} else {
    print("Success!")
}
```
#### Option 2: Completion Handler
```
PaymentManager.shared.retrieveTransaction(transactionId: id) { result in
    if let error = result.error {
        print("Error: \(error.localizedDescription")")"
    } else {
        print("Success!")
    }
}
```

## General
### MobilePayments
The `MobilePayments` class is a utility singleton for initialization and setup.  Most of its contents are for UI behavior discussed in previous tutorials.  For Direct integration, there are only two relevant functions.

#### Initialize
```
initialize(environment: Environment, clientToken: String, businessLocationId: String?)
```
Initialization can be performed at any time, but must occur before using any SDK APIs.
  * Environment
    * The Environment the MobilePayments SDK should operate in.  Possible values are Environment.SANDBOX or Environment.PRODUCTION
  * Client Token
    * The alphanumeric string value provided when you created your merchant account
  * **(OPTIONAL)** Business Location ID
    * The ID of the store to associate with any payments made during this session

#### Business Location Id
```
setBusinessLocationId(businessLocationId: String?)
```
Update the Business Location ID and change the store associated with any payments made afterwards.  It is a supplementary/helper function used in the event the store or location can change after initialization.

#### Styles
```
setStyle(_ provider: MobilePaymentsStyleProvider) 
```
Update the styles used by the SDK. Color, fonts, and shapes can be customized here.
