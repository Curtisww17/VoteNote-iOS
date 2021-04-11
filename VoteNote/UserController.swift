//
//  UserController.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/14/21.
//

import Foundation
import SwiftUI

struct UserController: View {
  @ObservedObject var spotify = sharedSpotify
  @Binding var isInRoom: Bool
  @State var showNav = true;
  @State var roomName: String
  @State var roomDescription: String
  @State var roomCapacity: Int
  @State var songsPerUser: Int
  @State var votingEnabled: Bool
  @State var anonUsr: Bool
  @State var explicitSongsAllowed: Bool
  @State var notExited: Bool = false
  @State var isTiming: Bool = false
  @State var genres: [String]
    
  @State var currentView = 0
    
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
                    destination: AddMusicView(songsPerUser: songsPerUser, explicitSongsAllowed: explicitSongsAllowed).navigationBarTitle("Browse"),
                  label: {
                  Text("Add")
                  })
            } else {
                NavigationLink(
                  destination: ProfileView(),
                  label: {
                      Image(systemName: "person")
                        .resizable()
                        
                        .frame(width: 30, height: 30)
                  })
            }
        }
        .frame(width: UIScreen.main.bounds.size.width/4)
        
      }
      .frame(width: UIScreen.main.bounds.size.width, alignment: .top)
      
      if (currentView == 0) {
        User_QueuePageView(votingEnabled: ObservableBoolean(boolValue: votingEnabled))
          .animation(.default)
          .transition(.move(edge: .leading))
      } else {
        User_RoomPageView(roomName: roomName, roomDescription: roomDescription, roomCapacity: roomCapacity, songsPerUser: songsPerUser, votingEnabled: votingEnabled, anonUsr: $anonUsr, isTiming: $isTiming, notExited: $notExited, genres: $genres, showNav: $showNav)
          .animation(.default)
          .transition(.move(edge: .trailing))
        
      }
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarHidden(true).onAppear(perform: {
        notExited = false
    }).navigate(to: LandingPageView(), when: $notExited).navigationViewStyle(StackNavigationViewStyle())
    }
  }
}

