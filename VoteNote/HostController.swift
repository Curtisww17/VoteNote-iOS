//
//  HostController.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/14/21.
//

import Foundation
import SwiftUI

var RoomName: String = ""
var RoomDescription: String = ""
var VotingEnabled: Bool = false
var AnonUsr: Bool = false
var RoomCapacity: Int = 20
var SongsPerUser: Int = 4
var ExplicitSongsAllowed: Bool = false
var AutoLike: Bool = false

struct HostController: View {
  @ObservedObject var spotify = sharedSpotify
  @Binding var isInRoom: Bool
  @State var showNav = true
  @State var notExited: Bool = false
  @State var isTiming = false

  @State var genres: [String]
  
  @State var currentView = 1
    @State var autoVote: Bool = false
        
  var body: some View {
    OperationQueue.main.addOperation {
      isInRoom = true
    }
    return VStack {
      VStack {
        HStack {
          Spacer()
            .frame(width: UIScreen.main.bounds.size.width / 4)
          Picker(selection: self.$currentView, label: Text("I don't know what this label is for")) {
            Text("Queue").tag(0)
            Text("Room").tag(1)
          }.pickerStyle(SegmentedPickerStyle())
          .frame(width: UIScreen.main.bounds.size.width / 2,  alignment: .center)
          VStack {
            if (currentView == 0) {
              NavigationLink(
                destination: AddMusicView(genres: genres).navigationBarTitle("Browse"),
                label: {
                  Text("Add")
                })
            } else {
              NavigationLink(
                destination: ProfileView(autoVote: $autoVote),
                label: {
                  Image(systemName: "person")
                    .resizable()
                    
                    .frame(width: 30, height: 30)
                })
            }
          }
          .frame(width: UIScreen.main.bounds.size.width/4)
          
        }
        .frame(width: UIScreen.main.bounds.size.width/4)
        
      }
      .frame(width: UIScreen.main.bounds.size.width, alignment: .top)
      
      if (currentView == 0) {
        Host_QueuePageView(autoVote: $autoVote)
          .animation(.default)
          .transition(.move(edge: .leading))
      } else {
        Host_RoomPageView(showNav: $showNav, notExited: $notExited, isTiming: $isTiming, autoVote: $autoVote, genres: $genres)
          .animation(.default)
          .transition(.move(edge: .trailing))
        
        
      }
    }.navigationTitle("Lobby")
    .navigationBarHidden(true).onAppear(perform: {
      notExited = false
      if (!isTiming) {
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
          if (!(sharedSpotify.isPaused ?? false)) {
            sharedSpotify.currentlyPlayingPos = (sharedSpotify.currentlyPlayingPos ?? 0) + 1000
            sharedSpotify.updateCurrentlyPlayingPosition()
          }
        }
        isTiming = true
      }
        
    getAutoVote { (setting, err) in
        if err == nil {
            self.autoVote = setting!
            print("\n\n\n\n\n\n\(autoVote)\n\n\n\n\n\n")
        }
        
    }

    }).navigate(to: LandingPageView(), when: $notExited).navigationViewStyle(StackNavigationViewStyle())
  }
  
}
