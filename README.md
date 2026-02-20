# Overview
The MobilePayments SDK is a library containing a suite of payment tools designed to be simple and easy to integrate into an existing, or new, mobile application.  It is a collection of easy to use UI widgets that can support varying levels of integration, everything from an isolated full-screen takeover to individual widgets that can be embedded into an existing UI, with extensive customization to fit nearly any look and feel.

In addition, for those looking for a truly custom experience, the full underlying Payments API is available to be plugged directly into a custom-built UI.

<div class="container" style="width:100%; display: flex; justify-content: space-evenly;" align="center">
	<img src="/images/sheet.png" alt="Sheet" style="width:25%; height:auto;">&nbsp;&nbsp;<img src="/images/singlecardmode.png" alt="Single Card Mode" style="width:25%; height:auto;">&nbsp;&nbsp;<img src="/images/uicomponents.png" alt="UI Components" style="width:25%; height:auto;">
</div>


# Getting Started

## Prerequisites
To use the MobilePayments SDK on iOS, there is a minimum requirement of

1. `iOS 16.4`
2. `Xcode 26`
	
In addition, you must set up a merchant account and associated payment configurations with Fiserv

## Installation
The Mobile Payments SDK is available through either [CocoaPods](https://www.cocoapods.org/) or [Swift Package Manager](swift.org/package-manager/) 

- To integrate using `CocoaPods`, specify the following pod in your [Podfile](https://guides.cocoapods.org/syntax/podfile.html): `pod 'FiservMobilePayments'` 
+ To integrate using `Swift Package Manager`, follow [this guide](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) and use `https://github.com/fiserv/mobile-payments-ios` as the repository URL.

**Note:** If you integrate with `Cocoapods`, you may run into rsync errors when building because of its build scripts. To ensure those scripts are execute correctly, you must disable `User Script Sandboxing`. You can do this by following these steps:
1. In Xcode, select the project file at the very top of the Project Navigator on the left.
2. Select your `target` under `Targets`
3. Go to the `Build Settings` tab
4. Search for `User Script Sandboxing`
5. Set it to `No`

## Running the Sample App
A sample app is included in this repository to demonstrate SDK integration.

Before running the project, open `Configurations.swift` and replace the placeholder values with your own configuration values.

# Initialization
Initialization can be performed at any time, but must occur before using any SDK APIs.  Here, you will provide:
  1. the Environment (SANDBOX or PRODUCTION) you wish to run the SDK on
  2. the clientToken provided when your merchant account was configured
  3. **(OPTIONAL)** the ID of a store within your merchant, that will assign transactions and payments made to that store

The invocation will look like this:
```
import FiservMobilePayments

// ... inside your AppDelegate or App struct ...

MobilePayments.shared.initialize(
  environment: .sandbox,
  clientToken: "<clientToken>",
  businessLocationId: "<businessLocationId>"
)
```

## Optional Parameters
In addition, you are able to configure certain optional parameters to control and influence the behavior of the MobilePayments SDK.  These are:

  - A customer ID value (typically an account ID or otherwise unique identifier for a customer).  This will allow a customer with this ID value to access previously saved Credit Cards for use in future payments.
    ```
    MobilePayments.shared.setCustomerId("<CUSTOMER_ID>")
    ```
    
  * The ID of a store within your merchant, this is the same value that can be passed into inititalize.  This will direct payments to that location specifically as well as ensure payment configurations are accurate to the specific store in the event of different configurations within the same merchant.
    ```
    MobilePayments.shared.setBusinessLocationId("<STORE_ID>"
    ```

  + A styling configuration to configure the fonts, colors, and shape of the application. Refer to the `Customization` section below
    ```
    MobilePayments.shared.setStyle(style)
    ```

# Customization
The Mobile Payments SDK has an extensive Customization suite available to finetune the look and feel of the provided UI to match the host application.  You can find details in the [Customization](/docs/customization.md) walkthrough

# Integration
The first step to integrating the MobilePayments SDK is determining what method of integration is right for you.

The simplest and easiest of the available options is Sheets. This is as quick and easy as firing off an intent and monitoring the response.  This is by far the easiest path to go, but simultaneously the least flexible.

If you require more flexibility, but don’t want to deal with customer information directly, or just want a personalized touch to the user experience, then using the MobilePayments UI Components is the way to go.

If even that’s not enough, and you really must have a unique UI, then you’re looking to interface with MobilePayments Directly.  This will take the most work, and you will have to collect user information to pass to MobilePayments, but you will be able to make your app look and behave exactly the way you want to.

**Quick Links**

- [Sheets](/docs/sheets.md)
* [UI Components](/docs/ui_components.md)
+ [Direct](/docs/direct.md)
* [Apple Pay](/docs/apple_pay.md)
- [API References](https://fiserv.github.io/mobile-payments-ios/documentation/fiservmobilepayments/)
