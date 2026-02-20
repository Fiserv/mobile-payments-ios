//
//  Styles.swift
//  PaymentsSampleUIKit
//
//  Created by Allan Cheng on 2/19/26.
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
        UIColor(fromRGBHex: "9E9E9E")
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
}

public class RobotoFontFamily: FontFamily {
    public var regular: UIFont {
        // Loads in the Roboto-Regular font that is provided in the fonts folder and added to info.plist
        UIFont(name: "Roboto-Regular", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
    }
    
    public var bold: UIFont {
        // Loads in the Roboto-Bold font that is provided in the fonts folder and added to info.plist
        UIFont(name: "Roboto-Bold", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold)
    }
}

public class PoppinsFontFamily: FontFamily {
    public var regular: UIFont {
        // Loads in the Poppins-Regular font that is provided in the fonts folder and added to info.plist
        UIFont(name: "Poppins-Regular", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
    }
    
    public var bold: UIFont {
        // Loads in the Poppins-Bold font that is provided in the fonts folder and added to info.plist
        UIFont(name: "Poppins-Bold", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold)
    }
}

public class RalewayFontFamily: FontFamily {
    public var regular: UIFont {
        // Loads in the Raleway font that is provided in the fonts folder and added to info.plist
        UIFont(name: "Raleway", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
    }
    
    public var bold: UIFont {
        // Loads in the Raleway-Bold font that is provided in the fonts folder and added to info.plist
        UIFont(name: "Raleway-Bold", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold)
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

public class DarkFontProvider: MobilePaymentsFontProvider {
    public var headerFont: FontFamily {
        PoppinsFontFamily()
    }
    
    public var bodyFont: FontFamily {
        RalewayFontFamily()
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

