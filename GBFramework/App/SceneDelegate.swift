//
//  SceneDelegate.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 18.08.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let notificationConfig = NotificationConfig.instance

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let controller: UIViewController
        controller = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(LoginViewController.self)
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        window?.rootViewController?.view.removeBlur()
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationConfig.notificationRequestId])
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        let blurStyle = window?.rootViewController?.view.traitCollection.userInterfaceStyle == .light
            ? UIBlurEffect.Style.light
            : UIBlurEffect.Style.dark
        window?.rootViewController?.view.addBlur(alpha: 1, style: blurStyle)
        
        let content = notificationConfig.content
        if content.title != "" {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
            let request = UNNotificationRequest(identifier: notificationConfig.notificationRequestId,
                                                content: content,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler:nil)
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}

