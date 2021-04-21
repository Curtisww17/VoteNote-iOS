//
//  HostController.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/14/21.
//

import Foundation
import SwiftUI

//the global room settings
var RoomName: String = ""
var RoomDescription: String = ""
var VotingEnabled: Bool = false
var AnonUsr: Bool = false
var RoomCapacity: Int = 20
var SongsPerUser: Int = 4
var ExplicitSongsAllowed: Bool = false
var AutoLike: Bool = false
var IsHost: Bool = false

/**
    The UI for for the navigation bar on the Room and Queue pages for host's
 */
struct HostController: View {
  @ObservedObject var spotify = sharedSpotify
  @Binding var isInRoom: Bool
  @State var showNav = true
  @State var notExited: Bool = false
  @State var isTiming = false

  @State var genres: [String]
  
  @State var currentView = 1
  @State var autoVote: Bool = false
        
  let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State var queueRefreshSeconds = 10
    
  var body: some View {
    OperationQueue.main.addOperation {
      isInRoom = true
    }
    return VStack {
      VStack {
        HStack {
            Button(action: {
                songQueue.updateQueue()
                songHistory.updateHistory()
                setCurrSong(id: sharedSpotify.currentlyPlaying!.id)
            }) {
                Image(systemName: "arrow.clockwise").resizable().frame(width: 25, height: 30)
            }.frame(width: UIScreen.main.bounds.size.width / 4)
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
            
            //the refresh timer for the host
            Text("\(queueRefreshSeconds)").frame(width: 0, height: 0).hidden().onReceive(refreshTimer) {
                            _ in
                            if self.queueRefreshSeconds > 0 {
                                self.queueRefreshSeconds -= 1
                            } else {
                                self.queueRefreshSeconds = 10
                                
                                if (isTiming) {
                                    print("Updating Queue")
                                        
                                    songQueue.updateQueue()
                                    songHistory.updateHistory()
                                    if (sharedSpotify.currentlyPlaying != nil) {
                                        setCurrSong(id: sharedSpotify.currentlyPlaying!.id)
                                    }
                                }
                            }
                        }
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
      IsHost = true
      notExited = false
      isTiming = true
    })
  }
}
