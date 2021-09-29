//
//  AvatarStorageService.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 22.09.2021.
//

import UIKit

final class AvatarStorageService {
    
    private let avatarFileName = "avatar.png"
    
    func saveAvatar(image: UIImage?, userName: String) {
        
        guard let avatarImage = image,
              let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
        }
        
        let imagesDirectory = documentsDirectory.appendingPathComponent("images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
            try? FileManager.default.createDirectory(at: imagesDirectory,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        let avatarFile = imagesDirectory.appendingPathComponent("\(userName)_\(avatarFileName)").path
        if FileManager.default.fileExists(atPath: avatarFile) {
            try? FileManager.default.removeItem(atPath: avatarFile)
        }
        let urlAvatarFile = URL(fileURLWithPath: avatarFile)
        try? avatarImage.pngData()?.write(to: urlAvatarFile)
    }
    
    func loadAvatar(userName: String) -> UIImage? {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return nil
        }
        let imagesDirectory = documentsDirectory.appendingPathComponent("images", isDirectory: true)
        let avatarFile = imagesDirectory.appendingPathComponent("\(userName)_\(avatarFileName)").path
        if FileManager.default.fileExists(atPath: avatarFile) {
            let image = UIImage(contentsOfFile: avatarFile)
            return image
        } else {
            return nil
        }
    }
    
}
