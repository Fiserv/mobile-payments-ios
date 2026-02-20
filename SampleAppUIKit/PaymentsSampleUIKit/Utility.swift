//
//  Utility.swift
//  PaymentsSampleUIKit
//
//  Created by Allan Cheng on 2/19/26.
//

import Foundation
import UIKit

func showPopup(title: String, message: String?, from viewController: UIViewController) {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    
    alert.addAction(cancelAction)
    
    viewController.present(alert, animated: true, completion: nil)
}
