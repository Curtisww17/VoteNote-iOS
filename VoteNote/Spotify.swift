//
//  Spotify.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/31/21.
//

import Foundation
import SwiftHTTP

let sharedSpotify = Spotify()

class Spotify: ObservableObject {
  
  let SpotifyClientID = "badf7b737e204baf818600b2c352a985"
  let SpotifyRedirectURL = URL(string: "VoteNote://SpotifyAuthentication")!
  let SpotifyRedirectURLString = "VoteNote://SpotifyAuthentication"
  let scopes = "user-read-private playlist-read-private user-read-playback-state"
  private let kAccessTokenKey = "access-token-key"
  
  @Published var canLogin: Bool
  private var httpRequester: HttpRequester
  
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
    httpRequester = HttpRequester()
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
    self.appRemote?.playerAPI?.pause({ (_, error) in
      print(error)
    })
  }
  
  func resume(){
    self.appRemote?.playerAPI?.resume({ (_, error) in
      print(error)
    })
  }
  
  func enqueue(songID: String){
    self.appRemote?.playerAPI?.enqueueTrackUri(songID, callback: { (_, error) in
      print(error)
    })
  }
  
  func skip(){
    self.appRemote?.playerAPI?.skip(toNext: { (_, error) in
      print(error)
    })
  }
  
  //need to add call back(?)
  func getPlayerState(){
    self.appRemote?.playerAPI?.getPlayerState({ (_, error) in
      print(error)
    })
  }
  
  func searchSong(Query: String, limit: String, offset:String) -> HTTP{
    
    return self.httpRequester.headerParamGet(url: "https://api.spotify.com/v1/search", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ], param: ["q" : Query, "type": "track,artist", "limit": limit])
  }
  
  func userPlaylists(limit: String) -> HTTP{
    return self.httpRequester.headerGet(url: "https://api.spotify.com/v1/me/playlists", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ])
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
