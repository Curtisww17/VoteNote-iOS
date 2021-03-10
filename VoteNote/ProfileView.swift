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
  @State var isAnon: Bool = false
  @State var anonName: String = ""
  
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
        Text("\(sharedSpotify.currentUser?.display_name ?? "Unknown")")
          .font(.title)
      }
      Form {
        HStack {
          Text("Anonymize Me")
          Toggle(isOn: $isAnon, label: {
            
          })
          .onTapGesture {
            anonName = generateAnonName()
          }
        }
        if (isAnon) {
          Text("Display Name: \(anonName)")
        } else {
          Text("Display Name: \(sharedSpotify.currentUser!.display_name ?? "Unknown")")
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
