//
//  AppDelegate.swift
//  Postboard
//
//  GIVEN, apart from one method: handleEventsForBackgroundURLSession is part
//  of Task 5 and is marked TODO below.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        EventLog.shared.log("--- app launched ---")
        return true
    }

    /// The system calls this when a background download finishes while your app
    /// is suspended or not running at all. It launches your app in the
    /// background purely to deliver the news, and lands here first.
    ///
    /// TODO (Task 5): implement this method.
    ///
    /// Two things are worth thinking about before you write it. What should
    /// happen to `completionHandler` - is this the right moment to call it, or
    /// does something have to happen first? And what has to exist by the time
    /// this method returns, for the delegate callbacks to reach you at all?
    ///
    /// Module 8 of the training material walks through this method and the
    /// sequence it starts.
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        EventLog.shared.log("handleEventsForBackgroundURLSession")
        // TODO (Task 5)
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
