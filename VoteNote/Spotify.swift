//
//  Spotify.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/31/21.
//

import Foundation


class Spotify: ObservableObject {
  
  let appDel = UIApplication.shared.delegate as! AppDelegate
  
  //scopes that we request access for, add more as needed
  let SCOPES: SPTScope = [.appRemoteControl, .playlistModifyPrivate, .playlistModifyPublic, .playlistReadPrivate, .userModifyPlaybackState]
  
  @Published var loggedIn: Bool
  
  
  init() {
    //constructor stuff goes here
    self.loggedIn = false
  }
  
  func login() -> Bool {
    
    let requestedScopes: SPTScope = [.appRemoteControl]
    appDel.sessionManager.initiateSession(with: requestedScopes, options: .default)
    self.loggedIn = true
    return true
  }
  
  func logout() -> Bool {
    appDel.appRemote.disconnect()
    return true
  }
  
  func isLoggedIn() -> String {
    if (loggedIn) {
      return "true"
    } else {
      return "false"
    }
   // return loggedIn
  }
}
