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
  @State var isAnon: Bool = sharedSpotify.isAnon
  @Binding var autoVote: Bool
  
  var body: some View {
    return VStack {
      if (spotify.loggedIn) {
        if (sharedSpotify.currentUser!.images != nil) {
          if (sharedSpotify.currentUser!.images!.count > 0) {
            HStack {
              Spacer()
              RemoteImage(url: sharedSpotify.currentUser!.images?[0].url ?? "")
                .frame(width: 150, height: 150)
                .clipShape(Circle())
              Spacer()
            }
          }
        }
        Text("\(spotify.currentUser?.display_name ?? "Unknown")")
          .font(.title)
      }
      Form {
        HStack {
          Text("Anonymize Me")
          Toggle(isOn: $isAnon, label: {})
            .onChange(of: self.isAnon) { newValue in
              print("anon")
              setAnon(isAnon: isAnon)
              spotify.isAnon = isAnon
            }
        }
        .frame(height:50)
        if (spotify.isAnon) {
          HStack {
            Text("Display Name: \(spotify.anon_name)")
            Spacer()
            Image(systemName: "arrow.clockwise")
              .onTapGesture {
                let newName = generateAnonName()
                setAnonName(name: newName)
                spotify.anon_name = newName
              }
          }
          .frame(height: 50)
        } else {
          Text("Display Name: \(spotify.currentUser!.display_name ?? "Unknown")")
            .frame(height: 50)
        }
        HStack {
          Text("Auto Like Favorite Songs")
          Toggle(isOn: $autoVote) {
            Text("")
          }.onChange(of: self.autoVote, perform: { value in
            print("hits here")
            setAutoVote(setting: autoVote)
          })
        }
        .padding(.trailing)
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
      
    }.navigationViewStyle(StackNavigationViewStyle())  }
}
