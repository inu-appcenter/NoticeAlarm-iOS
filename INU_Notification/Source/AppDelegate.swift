//
//  AppDelegate.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/07/29.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            guard success else {
                return
            }
            print("Success in APNS registry")
        }
        application.registerForRemoteNotifications()
        return true
    }
    
    // MARK: Messaging
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        messaging.token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("Remote FCM registration token: \(token)")
                UserDefaults.standard.set(token, forKey: "FCMToken") // Token 저장
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // 앱이 foreground에 있을 때 푸시 알림이 오면 이 메서드가 호출된다.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                    -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.banner, .list, .sound]])
    }
    
    // 사용자가 push 알림을 터치하면 이 메서드가 호출된다.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("NOTIFICATION PUSH CLICKED")
        // Print full message.
        print(userInfo)
        print(userInfo["body"]!) // Optional(테스트링크)
        print(userInfo["keyword"]!) // Optional(장학)
        print(userInfo["title"]!) // Optional(테스트장학)
        
        completionHandler()
    }
}
