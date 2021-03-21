//
//  HostController.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/14/21.
//

import Foundation
import SwiftUI


struct HostController: View {
  @ObservedObject var spotify = sharedSpotify
  @Binding var isInRoom: Bool
  @State var showNav = true
  @State var roomName: String
  @State var roomDescription: String
  @State var votingEnabled: Bool
  @State var anonUsr: Bool
  @State var roomCapacity: Int
  @State var songsPerUser: Int
  @State var explicitSongsAllowed: Bool
  @State var notExited: Bool = false
  @ObservedObject var songHistory: MusicQueue = MusicQueue()
  @State var isTiming = false

  
  
  @State var currentView = 1
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
        .frame(width: UIScreen.main.bounds.size.width/4)
        
      }
      .frame(width: UIScreen.main.bounds.size.width, alignment: .top)
      
      if (currentView == 0) {
        Host_QueuePageView(songHistory: songHistory, votingEnabled: ObservableBoolean(boolValue: votingEnabled))
          .animation(.default)
          .transition(.move(edge: .leading))
      } else {
        Host_RoomPageView(roomName: roomName, roomDescription: roomDescription, roomCapacity: roomCapacity, songsPerUser: songsPerUser, votingEnabled: votingEnabled, anonUsr: $anonUsr, showNav: $showNav, notExited: $notExited, songHistory: songHistory)
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
    }).navigate(to: LandingPageView(), when: $notExited).navigationViewStyle(StackNavigationViewStyle())
  }
  
}

/*struct HostController_PreviewContainer: View {
 @State var isInRoom: Bool = true
 
 var body: some View {
 HostController(isInRoom: $isInRoom, roomName: "Primanti Bros", roomDescription: "Description Goes Here")
 }
 }
 
 struct HostController_Previews: PreviewProvider {
 static var previews: some View {
 HostController_PreviewContainer()
 }
 }*/
