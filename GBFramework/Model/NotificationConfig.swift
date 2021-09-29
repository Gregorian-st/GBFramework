//
//  NotificationConfig.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 20.09.2021.
//

import UserNotifications

class NotificationConfig {
    
    static let instance = NotificationConfig()
    
    let content = UNMutableNotificationContent()
    
    let notificationRequestId = "GBFramework.recordingRemainder"
    let categoryId = "GBFramework.recordingAction"
    let stopRecordingActionId = "GBFramework.stopRecording"
    let cancelActionId = "GBFramework.cancel"
    
    private init() {}
}
