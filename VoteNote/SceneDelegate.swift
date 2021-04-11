//
//  SceneDelegate.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import UIKit
import SwiftUI
import PartialSheet


class SceneDelegate: UIResponder, UIWindowSceneDelegate,
                     SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, SPTSessionManagerDelegate {
  
  static private let kAccessTokenKey = "access-token-key"
  private let redirectUri = URL(string:"VoteNote://SpotifyAuthentication")!
  private let clientIdentifier = "badf7b737e204baf818600b2c352a985"
  
  var window: UIWindow?
  
  lazy var configuration = SPTConfiguration(
    clientID: clientIdentifier,
    redirectURL: redirectUri
  )
  
  lazy var appRemote: SPTAppRemote = {
    let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
    let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
    appRemote.connectionParameters.accessToken = self.accessToken
    appRemote.delegate = self
    return appRemote
  }()
  
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
  
  var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
    didSet {
      let defaults = UserDefaults.standard
      defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
      //print(appRemote.connectionParameters.accessToken ?? "access token")
      sharedSpotify.appRemote = self.appRemote
    }
  }
  
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    sharedSpotify.sessionManager = self.sessionManager
    // Create the SwiftUI view that provides the window contents.
    let contentView = ContentView()
    
    //self.sessionManager.initiateSession(with: sharedSpotify.SCOPES, options: .default)
    
    // Use a UIHostingController as window root view controller.
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
    }
  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else {
      return
    }
    self.sessionManager.application(UIApplication.shared, open: url, options: [:])
    
    let parameters = appRemote.authorizationParameters(from: url)
    
    if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
      appRemote.connectionParameters.accessToken = access_token
      self.accessToken = access_token
    } else if let error = parameters?[SPTAppRemoteErrorDescriptionKey] {
      // Show the error
      print(error)
    }
    if let room_code = parameters?["room_code"] {
      print(room_code)
      sharedSpotify.isJoiningThroughLink = room_code
      sharedSpotify.login()
    }
    
    let sheetManager: PartialSheetManager = PartialSheetManager()
    let contentView = ContentView().environmentObject(sheetManager)

    // Use a UIHostingController as window root view controller.
    if let windowScene = scene as? UIWindowScene {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(
            rootView: contentView
        )
        self.window = window
        window.makeKeyAndVisible()
    }
    
  }
  
  func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
    //debugPrint("Track name: %@", playerState.track.name)
    sharedSpotify.isPaused = playerState.isPaused
    sharedSpotify.currentlyPlayingPos = playerState.playbackPosition
    sharedSpotify.currentlyPlayingPercent = (Float)(playerState.playbackPosition) / (Float)(playerState.track.duration)
    sharedSpotify.getTrackInfo(track_uri: String(playerState.track.uri.split(separator: ":").last ?? ""), completion: {(currPlaying) in
      if (currPlaying != nil) {
        OperationQueue.main.addOperation {
          sharedSpotify.currentlyPlaying = currPlaying
          
        }
      }
    })
    
  }
  
  
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    //    if let _ = self.appRemote.connectionParameters.accessToken {
    //      self.appRemote.connect()
    //    }
    if sharedSpotify.loggedIn {
      self.appRemote.connect()
    }
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    if self.appRemote.isConnected {
      self.appRemote.disconnect()
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
  
  // MARK: AppRemoteDelegate
  
  func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
    OperationQueue.main.addOperation {
      sharedSpotify.loggedIn = true
      sharedSpotify.appRemote = self.appRemote
      sharedSpotify.getCurrentUser(completion: { user in
        if sharedSpotify.currentUser == nil {
          appRemote.playerAPI?.pause(nil)
        }
        sharedSpotify.currentUser = user
        //login user to db
        firebaseLogin(name: (user?.display_name)!)
        
        sharedSpotify.getGenreList(completion: {genres in sharedSpotify.genreList = genres})
        
        
      })
      
    }
    
    //self.appRemote = appRemote
    self.appRemote.playerAPI?.delegate = self
    self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
      if let error = error {
        debugPrint(error.localizedDescription)
      }
    })
  }
  
  func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
    print("didFailConnectionAttemptWithError")
    print(error)
  }
  
  func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
    print("didDisconnectWithError")
    appRemote.connect()
  }
  
  func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
    self.appRemote.connectionParameters.accessToken = session.accessToken
    //self.appRemote.authorizeAndPlayURI("")
    self.appRemote.connect()
    
  }
  
  func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
    print(error)
    //print(error)
  }
  
  func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
    print("renew")
    //print(session)
  }
  
  func connect() {
    self.appRemote.authorizeAndPlayURI("")
  }
  
  
  
}

