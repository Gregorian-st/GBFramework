//
//  MainRouter.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit

final class MainRouter: BaseRouter {
    
    func showLogin() {
        
        let controller = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(LoginViewController.self)
        show(controller, style: .root)
    }
    
    func showGMap(avatarImage: UIImage?) {
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(GMapViewController.self)
        (controller as GMapViewController).avatarImage = avatarImage
        show(controller, style: .push(animated: true))
    }
}
