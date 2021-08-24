//
//  Alerting.swift
//  GBShopping
//
//  Created by Grigory Stolyarov on 15.07.2021.
//

import UIKit

func showAlert(alertMessage: String, viewController: UIViewController) {
    let alertController = UIAlertController(title: "GBFramework",
                                            message: alertMessage,
                                            preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    viewController.present(alertController, animated: true, completion: nil)
}
