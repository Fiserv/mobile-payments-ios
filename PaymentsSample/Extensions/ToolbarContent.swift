//
//  ToolbarContent.swift
//  mobile-payments-ios
//
//  Created by Allan Cheng on 2/14/26.
//

import SwiftUI

internal extension ToolbarContent {
    @ToolbarContentBuilder
    func hideSharedBackground() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}
