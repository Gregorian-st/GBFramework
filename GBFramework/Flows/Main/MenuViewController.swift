//
//  MenuViewController.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 26.08.2021.
//

import UIKit

class MenuViewController: UIViewController {
    
    private var avatarImage: UIImage?
    private let avatarStorageService = AvatarStorageService()
    var userName = String()
    
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
    @IBOutlet weak var avatarView: UIImageView! {
        didSet {
            avatarView.layer.cornerRadius = avatarView.frame.size.height / 2
            avatarView.clipsToBounds = true
            avatarView.layer.borderColor = UIColor.systemBlue.cgColor
            avatarView.layer.borderWidth = 2
            avatarView.layer.backgroundColor = UIColor(white: 1, alpha: 0.1).cgColor
        }
    }
    
    // MARK: - Actions
    
    @IBAction func gMapButtonTapped(_ sender: UIButton) {
        
        router.showGMap(avatarImage: avatarImage)
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        
        router.showLogin()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavigationBar()
        setupAvatarView()
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
    
    private func setupAvatarView() {
    
        avatarView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarImageTapped(tapGestureRecognizer:)))
        avatarView.addGestureRecognizer(tapRecognizer)
        
        if let image = avatarStorageService.loadAvatar(userName: userName) {
            avatarImage = image
            avatarView.image = avatarImage
            avatarView.contentMode = .scaleAspectFill
        } else {
            avatarView.image = UIImage(systemName: "camera")
            avatarView.contentMode = .center
        }
    }
    
    @objc private func avatarImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .camera
                imagePicker.cameraDevice = .front
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        
        present(photoSourceRequestController, animated: true, completion: nil)
    }
}

extension MenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = extractImage(from: info) {
            avatarImage = image
            avatarView.image = avatarImage
            avatarView.contentMode = .scaleAspectFill
            avatarStorageService.saveAvatar(image: avatarImage, userName: userName)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        
        if let image = info[.editedImage] as? UIImage {
            return image
        }
        if let image = info[.originalImage] as? UIImage {
            return image
        }
        return nil
    }
}
