//
//  ToastMessage.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 07-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//

import Foundation
import UIKit

class ToastMessage {
    
    init() {
    }
    
    func displayToast(message: String, duration: Double, viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        viewController.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
}
