//
//  ProfileView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI


struct ProfileView: View {
  @ObservedObject var spotify: Spotify = sharedSpotify
  
  var body: some View {
    return VStack {
      if(spotify.isLoggedIn()) {
      Text("logged in")
      } else {
        Text("not logged in")
      }
      Button(action: {
        spotify.pause()
      }, label: {
        Text("pause")
      })
    }
  }
}
