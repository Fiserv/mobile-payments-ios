# Overview
The MobilePayments SDK provides a collection of self-contained UI elements, both in individual widgets as well as larger, more comprehensive containers.  No one look can suit every app out there, however, so an extensive customization suite has been added to control the look and feel of these UI elements.  With these tools, you should be able to make the MobilePayments UI fit nearly any application design and aesthetic.

# How to Customize
The MobilePayments SDK uses the `MobilePaymentsStyleProvider` in order to control the look and feel of the UI elements.  This provider can be manipulated at any time prior to UI initialization to change the UI along these axes:

  * [Color](#color)
  * [Font](#font)
  * [Shape](#shape)
  * [Copy](#copy)
  
**Note:** All desired customizations must be provided together by applying it like this:
```
let style = MobilePaymentsStyleProvider(colors: color, fonts: font, shapes: shape)
MobilePayments.shared.setStyle(style)
```
All styling parameters ([Color](#color), [Font](#font), [Shape](#shape)) are optional. You can customize only the properties you need. Any unspecified values will use the SDK defaults. Refer to the sections below for details on generating the configuration values to pass into this method

## Color
Color in the MobilePayments UI is handled through a series of channels, where UI elements in similar design situations are put on a given channel.  Each channel is then able to be freely changed to any desired color.

These channels are specified in the `MobilePaymentsColorProvider` protocol, with each color channel as a separate method:
```
protocol MobilePaymentsColorProvider {
    var primary: UIColor { get }
    var disabled: UIColor { get }
    var success: UIColor { get }
    var error: UIColor { get }
    var darkText: UIColor { get }
    var mediumText: UIColor { get }
    var lightBackground: UIColor { get }
    var lightText: UIColor { get }
    var background: UIColor { get }
}
```
In order to customize the colors, you simply implement this protocol in a custom class and set the colors you wish to change.  For example:
```
public class DarkColorProvider: MobilePaymentsColorProvider {
    public var background: UIColor {
        UIColor(fromRGBHex: "252829")
    }
    
    public var darkText: UIColor {
        UIColor(fromRGBHex: "FFFFFF")
    }
    
    public var lightBackground: UIColor {
        UIColor(fromRGBHex: "000000")
    }
    
    public var lightText: UIColor {
        UIColor(fromRGBHex: "FFFFFF")
    }
    
    public var mediumText: UIColor {
        UIColor(fromRGBHex: "9E9E9E")
    }
}
```
Once specified, you pass the new MobilePaymentsColorProvider as `colors: DarkColorProvider` to `MobilePaymentsStyleProvider`.
To customize only the color while using default values for other styling properties, pass only the color configuration
```
let color = DarkColorProvider()
let style = MobilePaymentsStyleProvider(colors: color)
MobilePayments.shared.setStyle(style)
```

### Example
<div class="container" style="width:100%; display: flex; justify-content: space-evenly;" align="center">
	<img src="/images/sheet_default_color.png" alt="MobilePaymentsPurchaseActivity with the default color provider" style="width:25%; height:auto;">&nbsp;&nbsp;<img src="/images/sheet_custom_color.png" alt="MobilePaymentsPurchaseActivity with the sample color provider" style="width:25%; height:auto;">
</div>

## Font
There are two fonts used in the MobilePayments UI, by default these are `OpenSans` and `Montserraf`.  Any valid font can be used to replace one or both of these as desired.

Similar to the above, these fonts are specified by the `MobilePaymentsFontProvider` interface:
```
protocol MobilePaymentsFontProvider {
    var headerFont: FontFamily { get }
    var bodyFont: FontFamily { get }
}
```
FontFamily is defined as:
```
protocol FontFamily {
    var regular: UIFont { get }
    var bold: UIFont { get }
}
```

Simply implement this protocol and create the FontFamily and set the fonts font you wish to replace, like so:
```
public class RobotoFontFamily: FontFamily {
    public var regular: UIFont {
        UIFont(name: "Roboto-Regular", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
    }
    
    public var bold: UIFont {
        UIFont(name: "Roboto-Bold", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold)
    }
}

public class CustomFontProvider: MobilePaymentsFontProvider {
    public var headerFont: FontFamily {
        RobotoFontFamily()
    }
    
    public var bodyFont: FontFamily {
        RobotoFontFamily()
    }
}
```
Once specified, you pass the new MobilePaymentsFontProvider as `fonts: CustomFontProvider()` to `MobilePaymentsStyleProvider`.
To customize only the font while using default values for other styling properties, pass only the color configuration
```
let color = CustomFontProvider()
let style = MobilePaymentsStyleProvider(fonts: font)
MobilePayments.shared.setStyle(style)
```

### Example
<div class="container" style="width:100%; display: flex; justify-content: space-evenly;" align="center">
	<img src="/images/sheet_default_font.png" alt="MobilePaymentsPurchaseActivity with the default font provider" style="width:25%; height:auto;">&nbsp;&nbsp;<img src="/images/sheet_custom_font.png" alt="MobilePaymentsPurchaseActivity with the sample font provider" style="width:25%; height:auto;">
</div>

## Shape
Shapes in the `MobilePaymentsStyleProvider` refers to general shaping of the app, typically rounded corner radii and border thickness.

These shapes are specified by the `MobilePaymentsShapeProvider` interface:
```
protocol MobilePaymentsShapeProvider {
    var buttonCornerRadius: CGFloat { get }
    var cornerRadius: CGFloat { get }
    var textFieldCornerRadius: CGFloat { get }
    var selectedBorderThickness: CGFloat { get }
    var borderThickness: CGFloat { get }
}
```
To change these parameters, simply implement and override as desired:
```
public class BlockShapeProvider: MobilePaymentsShapeProvider {
    public var buttonCornerRadius: CGFloat {
        4
    }
    
    public var cornerRadius: CGFloat {
        2
    }
    
    public var textFieldCornerRadius: CGFloat {
        1
    }
}
```
Once specified, you pass the new MobilePaymentsShapeProvider as `shapes: BlockShapeProvider()` to `MobilePaymentsStyleProvider`.
To customize only the font while using default values for other styling properties, pass only the color configuration
```
let color = CustomFontProvider()
let style = MobilePaymentsStyleProvider(fonts: font)
MobilePayments.shared.setStyle(style)
```

### Example
<div class="container" style="width:100%; display: flex; justify-content: space-evenly;" align="center">
	<img src="/images/sheet_default_shapes.png" alt="MobilePaymentsPurchaseActivity with the default shape provider" style="width:25%; height:auto;">&nbsp;&nbsp;<img src="/images/sheet_custom_shapes.png" alt="MobilePaymentsPurchaseActivity with the sample shape provider" style="width:25%; height:auto;">
</div>

## Copy
There is a small collection of string values baked into the UI elements, generally page titles and button labels, that are also freely customizable, utilizing the native platform’s string and localization management behavior.

**Warning:** Strings containing non-standard characters or of excessive length may impact UI negatively.  Test and review any changes before release to ensure compatibility with your designed copy.

The Mobile Payments iOS SDK utilizes the standard `Localizable.strings`, drawing from these values:
```
// Credit Cards
"mp_creditCardListTitle" = "Saved Cards";
"mp_creditCardAddCardButton" = "Add Credit Card";

// Credit Card List Item
"mp_creditCardItemNumber" = "•••• %@";
"mp_creditCardItemExpiration" = "Exp. %@/%@";
"mp_creditCardItemExpired" = "Expired";

// Credit Card Details
"mp_creditCardDetailsTitle" = "Card Info";
"mp_creditCardDetailsAddCardButton" = "Add Card";
"mp_creditCardDetailsAddCardAndPayButton" = "Pay %@";

"mp_creditCardDetailsName" = "Name on Card";
"mp_creditCardDetailsCardNumber" = "Credit Card Number";
"mp_creditCardDetailsExpiration" = "Exp. Date";
"mp_creditCardDetailsCvv" = "CVV";
"mp_creditCardDetailsPostalCode" = "Postal Code";

"mp_creditCardDetailsSaveLabel" = "Save card for future orders";
"mp_creditCardDetailsDefaultLabel" = "Set as default card";

// Purchase Button
"mp_purchaseButtonLabel" = "Purchase";
"mp_purchaseButtonAmountLabel" = "Total";
"mp_purchaseButtonAddCardAtCheckoutLabel" = "Pay With Card";
"mp_purchaseButtonAddCardAtCheckoutPaymentLabel" = "Pay with %@";

// Purchase View
"mp_purchaseActivityTitle" = "Pay Now";
"mp_purchasePaymentDivider" = "OR PAY WITH CARD";
```
To customize, simply add any of these string keys in your `Localizable.strings` file and change the value as desired.
For example, if you wish to change the purchase button's label, simply add
```
mp_purchaseButtonLabel = "<Your customized button label>";
```
to your `Localizable.strings` file
