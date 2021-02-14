//
//  Spotify.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/31/21.
//

import Foundation

let sharedSpotify = Spotify()

class Spotify: ObservableObject {
  
  let SpotifyClientID = "badf7b737e204baf818600b2c352a985"
  let SpotifyRedirectURL = URL(string: "VoteNote://SpotifyAuthentication")!
  let SpotifyRedirectURLString = "VoteNote://SpotifyAuthentication"
  let scopes = "user-read-private playlist-read-private user-read-playback-state"
  private let kAccessTokenKey = "access-token-key"
  
  @Published var canLogin: Bool
  
  var sessionManager: SPTSessionManager? {
    didSet {
      self.canLogin = true
    }
  }
  var appRemote: SPTAppRemote? {
    didSet {
      //print("app remote set")
    }
  }
  
  lazy var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
    didSet {
      let defaults = UserDefaults.standard
      defaults.set(accessToken, forKey: kAccessTokenKey)
      //print(appRemote.connectionParameters.accessToken ?? "access token")
      sharedSpotify.appRemote = self.appRemote
    }
  }
  
  //scopes that we request access for, add more as needed
  let SCOPES: SPTScope = [ .userReadRecentlyPlayed, .userTopRead, .streaming, .userReadEmail, .appRemoteControl, .playlistModifyPrivate, .playlistModifyPublic, .playlistReadPrivate, .userModifyPlaybackState, .userReadPlaybackState, .userReadCurrentlyPlaying]
  
  @Published var loggedIn: Bool
  
  
  
  
  
  init() {
    //constructor stuff goes here
    self.loggedIn = false
    self.canLogin = false
  }
  
  func login() -> Bool {
    
    //let requestedScopes: SPTScope = [.appRemoteControl]
    self.sessionManager?.initiateSession(with: SCOPES, options: .default)
    return true
  }
  
  func logout() -> Bool {
    self.appRemote?.playerAPI?.pause(nil)
    self.appRemote?.disconnect()
    print(self.accessToken)
    self.accessToken = ""
    self.loggedIn = false
    return true
  }
  
  func pause() {
    self.appRemote?.playerAPI?.pause()
  }
  
  func isLoggedIn() -> Bool {
    if let rem: SPTAppRemote = self.appRemote {
      return rem.isConnected
    }
    return false
    // return loggedIn
  }
  
  func TestPlay() -> Bool {
    //appDel.appRemoteDidEstablishConnection(appDel.appRemote)
    //appDel.appRemote.authorizeAndPlayURI("spotify:track:20I6sIOMTCkB6w7ryavxtO")
    return true
  }
}
