//
//  MenuViewController.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit

class MenuViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var router: MainRouter!
    @IBOutlet weak var gMapButton: UIButton! {
        didSet {
            gMapButton.layer.cornerRadius = gMapButton.frame.size.height / 2
        }
    }
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = loginButton.frame.size.height / 2
        }
    }
    
    // MARK: - Actions
    
    @IBAction func gMapButtonTapped(_ sender: UIButton) {
        
        router.showGMap()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        
        router.showLogin()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    // MARK: - App Logic
    
    private func setupNavigationBar() {
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBarsOnSwipe = true
        navigationItem.backButtonTitle = ""
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}
