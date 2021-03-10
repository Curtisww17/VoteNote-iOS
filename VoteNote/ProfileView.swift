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
    return VStack {
      if (spotify.loggedIn) {
        HStack {
          Spacer()
          RemoteImage(url: sharedSpotify.currentUser!.images?[0].url ?? "")
            .frame(width: 150, height: 150)
            .clipShape(Circle())
          Spacer()
        }
      }
      Form {
        if(spotify.loggedIn) {
          Text("logged in as \(sharedSpotify.currentUser?.display_name ?? "Unknown")")
        }
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
      
    }.navigationViewStyle(StackNavigationViewStyle())
//    .onAppear(perform: {
//      sharedSpotify.getAlbumArt(for: "0weAUscowxeqDtpCgtbpgp", completion: { image in
//        print ("hi")
//      })
//    })
  }
}
