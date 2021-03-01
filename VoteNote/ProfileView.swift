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
      Form {
        if(spotify.loggedIn) {
          RemoteImage(url: sharedSpotify.currentUser!.images?[0].url ?? "")
          Text("logged in as \(sharedSpotify.currentUser?.display_name ?? "Unknown")")
        }
        if (spotify.loggedIn) {
          HStack {
            Spacer()
            Button(action: {
              //spotify.logout()
              sharedSpotify.getAlbumArt(for: "0weAUscowxeqDtpCgtbpgp", completion: { image in
                print ("hi")
              })
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
