//
//  Styles.swift
//  mobile-payments-ios
//
//  Created by Allan Cheng on 2/13/26.
//
import FiservMobilePayments
import SwiftUI

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
        UIColor(fromRGBHex: "E0E0E0")
    }
    
    public var highlight: UIColor {
        UIColor(fromRGBHex: "D5FFFF")
    }
}

public class CustomColorProvider: MobilePaymentsColorProvider {
    public var primary: UIColor {
        UIColor(fromRGBHex: "FEC400")
    }
    
    public var lightText: UIColor {
        UIColor(fromRGBHex: "654431")
    }
    
    public var error: UIColor {
        UIColor(fromRGBHex: "F28D8D")
    }
    
    public var background: UIColor {
        UIColor(fromRGBHex: "F2F0EF")
    }
    
    public var highlight: UIColor {
        UIColor(fromRGBHex: "FCE992")
    }
    
    public var mediumText: UIColor {
        UIColor(fromRGBHex: "9E9E9E")
    }
    
    public var disabledText: UIColor {
        UIColor(fromRGBHex: "757575")
    }
}

public class SystemFontFamily: FontFamily {
    public var regular: UIFont {
        UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
    }
    
    public var bold: UIFont {
        UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold)
    }
}

public class CustomFontProvider: MobilePaymentsFontProvider {
    public var headerFont: FontFamily {
        SystemFontFamily()
    }
    
    public var bodyFont: FontFamily {
        SystemFontFamily()
    }
}

public class CustomShapeProvider: MobilePaymentsShapeProvider {
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
