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
  @State var currentUser: SpotifyUser?
  
  var body: some View {
    //    spotify.getCurrentUser(completion: { user in
    //      self.currentUser = user
    //    })
    return VStack {
      Form {
        if(spotify.loggedIn) {
          Text("logged in as \(sharedSpotify.currentUser?.display_name ?? "Unknown")")
        }
        Button(action: {
          spotify.pause()
        }, label: {
          Text("pause")
        })
        if (spotify.loggedIn) {
          HStack {
            Spacer()
            Button(action: {
              spotify.logout()
            }, label: {
              Text("Log out of Spotify")
            })
            Spacer()
          }
        }
      }
      
    }
  }
}
