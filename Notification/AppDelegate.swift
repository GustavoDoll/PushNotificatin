//
//  AppDelegate.swift
//  Notification
//
//  Created by Gustavo Henrique Souza Silva Doll - GDO on 17/04/20.
//  Copyright © 2020 Gustavo Henrique Souza Silva Doll - GDO. All rights reserved.
//

import UIKit
import FirebaseMessaging
import Firebase
import AcousticMobilePush
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureNotifications(application)
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        MCESdk.shared.handleApplicationLaunch()
        return true
    }
    private func configureNotifications(_ application: UIApplication) {
           UNUserNotificationCenter.current().delegate = self
           let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
           UNUserNotificationCenter.current().requestAuthorization(
               options: authOptions,
               completionHandler: {_, _ in })
           inboxUpdate()
           NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.inboxUpdate), name:
               MCENotificationName.InboxCountUpdate.rawValue, object: nil)

           // This can be used to not present push notifications while app is running
           MCESdk.shared.presentNotification = {(userInfo) -> Bool in
               return true
           }
           application.registerForRemoteNotifications()
           UserDefaults.standard.register(defaults: ["action":"update", "standardType":"dial",  "standardDialValue":"\"8774266006\"",  "standardUrlValue":"\"http://acoustic.co\"",  "customType":"sendEmail",  "customValue":"{\"subject\":\"Hello from Sample App\",  \"body\": \"This is an example email body\",  \"recipient\":\"fake-email@fake-site.com\"}",  "categoryId":"example", "button1":"Accept", "button2":"Reject"])
           let options: UNAuthorizationOptions = {
               if #available(iOS 12.0, *) {
                   return [.alert, .sound, .carPlay, .badge, .providesAppNotificationSettings]
               }
               return [.alert, .sound, .carPlay, .badge]
           }()

           let center = UNUserNotificationCenter.current()
           center.requestAuthorization(options: options, completionHandler: { (granted, error) in
               if let error = error {
                   print("Could not request authorization from APNS \(error.localizedDescription)")
               }
               center.setNotificationCategories( self.notificationCategories() )
           })
       }
    @objc func inboxUpdate() {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = Int(MCEInboxDatabase.shared.unreadMessageCount())
            }
        }
    func notificationCategories() -> Set<UNNotificationCategory> {
         // iOS 10+ Example static action category:
         let acceptAction = UNNotificationAction(identifier: "Accept", title: "Accept", options: [.foreground])
         let rejectAction = UNNotificationAction(identifier: "Reject", title: "Reject", options: [.destructive])
         let category = UNNotificationCategory(identifier: "example", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [.customDismissAction])

         return Set(arrayLiteral: category)
     }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      completionHandler(UIBackgroundFetchResult.newData)
    }

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

    //Cange this to work with foreground notifications
    completionHandler([])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    // THIS METHOD IS THE ONE HOW MAKE THIS WORK PERFECT !!!!!!
    completionHandler()
  }

}

