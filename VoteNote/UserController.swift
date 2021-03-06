//
//  UserController.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/14/21.
//

import Foundation
import SwiftUI

/**
    The UI for for the navigation bar on the Room and Queue pages for host's
 */
struct UserController: View {
  @ObservedObject var spotify = sharedSpotify
  @Binding var isInRoom: Bool
  @State var showNav = true;
  @State var notExited: Bool = false
  @State var isTiming: Bool = false
    
  @State var genres: [String] = []
  @State var isBanned = false
  @State var autoVote: Bool = false
    
  @State var currentView = 0
    
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
            
            getRoom(code: currentQR.roomCode, completion: {room, err in
                if (room != nil) {
                    sharedSpotify.getTrackInfo(track_uri: room!.currSong) { (track) in
                        var title = ""
                        var artist = ""
                        var imageUrl = ""
                        var id = ""
                        
                        if track != nil{
                            
                            for art in track!.artists! {
                                artist += art.name + " "
                            }
                            title = track!.name
                            imageUrl = track?.album?.images?[0].url ?? ""
                            id = track?.id ?? ""
                        }
                        
                        currentSongTitle = title
                        currentSongArtists = artist
                        currentSongImageURL = imageUrl
                        currentSongID = id
                    }
                }
            })
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
                                
                                getRoom(code: currentQR.roomCode, completion: {room, err in
                                    if (room != nil) {
                                        sharedSpotify.getTrackInfo(track_uri: room!.currSong) { (track) in
                                            var title = ""
                                            var artist = ""
                                            var imageUrl = ""
                                            var id = ""
                                            
                                            if track != nil{
                                                
                                                for art in track!.artists! {
                                                    artist += art.name + " "
                                                }
                                                title = track!.name
                                                imageUrl = track?.album?.images?[0].url ?? ""
                                                id = track?.id ?? ""
                                            }
                                            
                                            currentSongTitle = title
                                            currentSongArtists = artist
                                            currentSongImageURL = imageUrl
                                            currentSongID = id
                                        }
                                    }
                                })
                            }
                        }
                    }
        
      }
      .frame(width: UIScreen.main.bounds.size.width, alignment: .top)
      
      if (currentView == 0) {
        User_QueuePageView(genres: $genres)
          .animation(.default)
          .transition(.move(edge: .leading))
          .onAppear() {
            
            isTiming = true
            getRoom(code: currentQR.roomCode, completion: { (room, err) in
              if ((room!.bannedUsers ?? []).contains(getUID())) {
                  leaveRoom()
                  isTiming = false
                  notExited = true
              }
            })
          }
      } else {
        User_RoomPageView(isTiming: $isTiming, notExited: $notExited, genres: $genres, showNav: $showNav)
          .animation(.default)
          .transition(.move(edge: .trailing))
        
      }
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarHidden(true).onAppear(perform: {
        IsHost = false
        notExited = false
        
        getAutoVote { (setting, err) in
            if err == nil {
                self.autoVote = setting!
                print(setting)
            }
        }
    })
    }
  }
}

