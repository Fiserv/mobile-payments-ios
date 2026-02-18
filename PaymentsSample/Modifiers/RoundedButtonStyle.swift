//
//  RoundedButtonStyle.swift
//  PaymentsSample
//
//  Created by Allan Cheng on 2/13/26.
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    @SwiftUI.Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(isEnabled ? .blue : .gray)
            .foregroundStyle(isEnabled ? .white : .black.opacity(0.5))
            .font(.system(size: 16, weight: .bold))
            .minimumScaleFactor(0.2)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
