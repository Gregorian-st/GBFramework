//
//  SignUpViewController.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit

class SignUpViewController: UIViewController {
    
    lazy var dataService = CoreDataService()
    
    // MARK: - Outlets
    
    @IBOutlet weak var loginTextField: UITextField! {
        didSet {
            loginTextField.tag = 1
            loginTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tag = 2
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var repeatPasswordTextField: UITextField! {
        didSet {
            repeatPasswordTextField.tag = 3
            repeatPasswordTextField.delegate = self
        }
    }
    @IBOutlet weak var registerButton: UIButton! {
        didSet {
            registerButton.layer.cornerRadius = registerButton.frame.size.height / 2
        }
    }
    
    // MARK: - Actions
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        register()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    // MARK: - App Logic
    
    private func register() {
        
        let loginText = loginTextField.text?.trimmingCharacters(in: [" "]) ?? ""
        let passwordText = passwordTextField.text?.trimmingCharacters(in: [" "]) ?? ""
        let repeatPasswordText = repeatPasswordTextField.text?.trimmingCharacters(in: [" "]) ?? ""
        if validateRegistrationInfo(loginText: loginText, passwordText: passwordText, repeatPasswordText: repeatPasswordText) {
            if !dataService.authSignUp(login: loginText, password: passwordText) {
                showAlert(alertMessage: "Internal Error!", viewController: self)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func validateRegistrationInfo(loginText: String, passwordText: String, repeatPasswordText: String) -> Bool {

        if loginText.isEmpty ||
            passwordText.isEmpty ||
            repeatPasswordText.isEmpty {
            showAlert(alertMessage: "All fields except 'Additional Info' must be filled out!", viewController: self)
            return false
        }
        
        if passwordText != repeatPasswordText {
            showAlert(alertMessage: "Please check password match in 'Password' and 'Repeat Password' fields!", viewController: self)
            return false
        }
        
        return true
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
}
