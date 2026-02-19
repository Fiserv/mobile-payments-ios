//
//  Decimal.swift
//  PaymentsSample
//
//  Created by Allan Cheng on 2/13/26.
//

import Foundation

extension Decimal {
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .bankers) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }
}
