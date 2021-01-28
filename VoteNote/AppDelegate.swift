//
//  AppDelegate.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate {
  
  
  let SpotifyClientID = "badf7b737e204baf818600b2c352a985"
  let SpotifyRedirectURL = URL(string: "VoteNote://SpotifyAuthentication")!
  
  lazy var configuration = SPTConfiguration(
    clientID: SpotifyClientID,
    redirectURL: SpotifyRedirectURL
  )
  lazy var sessionManager: SPTSessionManager = {
    if let tokenSwapURL = URL(string: "https://vote-note.herokuapp.com/api/token"),
       let tokenRefreshURL = URL(string: "https://vote-note.herokuapp.com/api/refresh_token") {
      self.configuration.tokenSwapURL = tokenSwapURL
      self.configuration.tokenRefreshURL = tokenRefreshURL
      self.configuration.playURI = ""
    }
    let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
    return manager
  }()
  
  
  
  //For Spotify Auth
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    self.sessionManager.application(app, open: url, options: options)
    return true
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    return true
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
  
  func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
    print("success", session)
  }
  func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
    print("fail", error)
  }
  func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
    print("renewed", session)
  }


}

