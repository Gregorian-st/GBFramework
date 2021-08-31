//
//  BaseRouter.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit

class BaseRouter: NSObject {
    
    @IBOutlet weak var controller: UIViewController!
    
    func show(_ controller: UIViewController, style: ShowStyle) {
        
        switch style {
        case .push(animated: let animated):
            self.controller.navigationController?.pushViewController(controller, animated: animated)
        case .modal(animated: let animated):
            self.controller.present(controller, animated: animated, completion: nil)
        case .root:
            UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController = controller
        }
    }
}

extension BaseRouter {
    
    enum ShowStyle {
        case push(animated: Bool)
        case modal(animated: Bool)
        case root
    }
}
