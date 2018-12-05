//
//  ToastMessage.swift
//  MijnEPDTest
//
//  Created by Denise van Diermen on 07-08-18.
//  Copyright © 2018 Floor van Lieshout. All rights reserved.
//
//  Class beschrijft het ToastMessage object die kan worden aangemaakt in elke wenselijk viewController

import Foundation
import UIKit

class ToastMessage {
    
    init() {
    }
    
    /**
     Toont een toastmessage met eigen tekst en duur
     - Parameter message: de tekst die je wilt tonen in de toastmessage
     - Parameter duration: aantal seconden dat het bericht op het scherm blijft staan
     - Parameter viewController: de viewController waarop het bericht wordt getoond
    */
    func displayToast(message: String, duration: Double, viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        viewController.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
}
