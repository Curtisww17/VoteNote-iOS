//
//  LoginWithSpotifyView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct LoginWithSpotifyView: View {
  @Binding var isLoggedIn: Bool
  var body: some View {
    return HStack {
      Button(action: {
        //these are the scopes that our app requests
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
        let del = UIApplication.shared.delegate as! AppDelegate
        del.sessionManager.initiateSession(with: scope, options: .default)
        isLoggedIn = true
      }) {
        Text("Login With Spotify")
      }
    }
  }
}
