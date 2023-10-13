//
//  AlertController.swift
//  CalenderReceommendations
//
//  Created by Sriteja Chilakamarri on 12/10/2023.
//

import UIKit

class AlertManager {
    static func showAlertWithActions(
        title: String,
        message: String,
        viewController: UIViewController,
        actions: [UIAlertAction],
        completion: (() -> Void)?
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        viewController.present(alertController, animated: true, completion: completion)
    }
    
    static func showAlert(title: String, message: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
