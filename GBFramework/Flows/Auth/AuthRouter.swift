//
//  AuthRouter.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit

final class AuthRouter: BaseRouter {
    
    func showMain(login: String) {
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(MenuViewController.self)
        (controller as MenuViewController).userName = login
        let navigationController = UINavigationController(rootViewController: controller)
        show(navigationController, style: .root)
    }
    
    func showSignUp() {
        
        let controller = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(SignUpViewController.self)
        show(controller, style: .modal(animated: true))
    }
}
