//
//  LoginViewController.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    lazy var dataService = CoreDataService()
    
    // MARK: - Outlets
    
    @IBOutlet var router: AuthRouter!
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.layer.cornerRadius = usernameTextField.frame.size.height / 2
            usernameTextField.layer.borderWidth = 0.5
            usernameTextField.layer.borderColor = UIColor.systemGray2.cgColor
            usernameTextField.layer.masksToBounds = true
            usernameTextField.tag = 1
            usernameTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.layer.cornerRadius = passwordTextField.frame.size.height / 2
            passwordTextField.layer.borderWidth = 0.5
            passwordTextField.layer.borderColor = UIColor.systemGray2.cgColor
            passwordTextField.layer.masksToBounds = true
            passwordTextField.tag = 2
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = loginButton.frame.size.height / 2
        }
    }
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        login()
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        router.showSignUp()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    // MARK: - App Logic
    
    private func login() {
        
        guard
            let loginText = usernameTextField.text?.trimmingCharacters(in: [" "]),
            let passwordText = passwordTextField.text
        else {
            showAlert(alertMessage: "All fields must be filled out!", viewController: self)
            return
        }
        
        if loginText.isEmpty || passwordText.isEmpty {
            showAlert(alertMessage: "All fields must be filled out!", viewController: self)
            return
        }
        if dataService.authLogin(login: loginText, password: passwordText) {
            router.showMain()
        } else {
            showAlert(alertMessage: "Wrong credentials!", viewController: self)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == passwordTextField.tag {
            login()
            return true
        }
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
