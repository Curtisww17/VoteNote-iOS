//
//  LoginWithSpotifyView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct LoginWithSpotifyView: View {
  @ObservedObject var spotify: Spotify
  var body: some View {
    return HStack {
      Button(action: {
        //these are the scopes that our app requests
        spotify.login()
      }) {
        Text("Login With Spotify")
      }
    }
  }
}
