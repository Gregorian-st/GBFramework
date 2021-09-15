//
//  SignUpViewController.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
    
    lazy var dataService = CoreDataService()
    let disposeBag = DisposeBag()
    
    // MARK: - Outlets
    @IBOutlet weak var loginTextFootnote: UILabel!
    @IBOutlet weak var passwordTextFootnote: UILabel!
    @IBOutlet weak var repeatPasswordTextFootnote: UILabel!
    
    @IBOutlet weak var loginTextField: UITextField! {
        didSet {
            loginTextField.tag = 1
            loginTextField.delegate = self
            loginTextField
                .rx
                .controlEvent(.editingChanged)
                .withLatestFrom(loginTextField.rx.text.orEmpty)
                .subscribe(onNext: { text in
                    if text.trimmingCharacters(in: [" "]).isEmpty {
                        self.loginTextFootnote.textColor = .systemRed
                        self.loginTextFootnote.text = "𐄂 Field is empty"
                    } else {
                        self.loginTextFootnote.textColor = .systemGreen
                        self.loginTextFootnote.text = "✓ Field is not empty"
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tag = 2
            passwordTextField.delegate = self
            passwordTextField
                .rx
                .controlEvent(.editingChanged)
                .withLatestFrom(passwordTextField.rx.text.orEmpty)
                .subscribe(onNext: { text in
                    if text.trimmingCharacters(in: [" "]).count < SecurityConfig.minPasswordLength {
                        self.passwordTextFootnote.textColor = .systemRed
                        self.passwordTextFootnote.text = "𐄂 Password length is less than \(SecurityConfig.minPasswordLength) characters"
                    } else {
                        self.passwordTextFootnote.textColor = .systemGreen
                        self.passwordTextFootnote.text = "✓ Password length is ok"
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet weak var repeatPasswordTextField: UITextField! {
        didSet {
            repeatPasswordTextField.tag = 3
            repeatPasswordTextField.delegate = self
            repeatPasswordTextField
                .rx
                .controlEvent(.editingChanged)
                .withLatestFrom(repeatPasswordTextField.rx.text.orEmpty)
                .subscribe(onNext: { text in
                    if text.trimmingCharacters(in: [" "]).count < SecurityConfig.minPasswordLength {
                        self.repeatPasswordTextFootnote.textColor = .systemRed
                        self.repeatPasswordTextFootnote.text = "𐄂 Field is not matching 'Password' field"
                    } else {
                        self.repeatPasswordTextFootnote.textColor = .systemGreen
                        self.repeatPasswordTextFootnote.text = "✓ Field is matching 'Password' field"
                    }
                })
                .disposed(by: disposeBag)
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
