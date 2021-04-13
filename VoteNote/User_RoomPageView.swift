//
//  User_RoomPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

/**
    The UI for the user's version of the Room View
 */
struct User_RoomPageView: View {
  @State var currentView = 1
  @Binding var isTiming: Bool
  @Binding var notExited: Bool
    
  @Binding var genres: [String]
  
  @Binding var showNav: Bool
  let isHost = false
    
    /**
        Causes the current user to leave the room
     */
  func exitRoom() {
      leaveRoom()
      isTiming = false
      notExited = true
  }
  
  
  var body: some View {
    GeometryReader { geo in
        ZStack {
          VStack {
            
            Form {
              Section(header: Text(RoomName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .padding(.top)) {
              }
              
              Section() {
                NavigationLink(destination: QueueHistoryView().navigationTitle("History")
                                .onAppear(perform: {
                                  showNav = false
                                })
                                .onDisappear(perform: {
                                  showNav = true
                                }), label: {
                                  HStack {
                                    Image(systemName: "clock")
                                      .foregroundColor(Color.accentColor)
                                      .padding()
                                    Text("History")
                                  }
                                })
                NavigationLink(destination: UsersListView(isHost: isHost, votingEnabled: VotingEnabled).navigationTitle("Users")
                                .onAppear(perform: {
                                  showNav = false
                                })
                                .onDisappear(perform: {
                                  showNav = true
                                }), label: {
                                  HStack {
                                    Image(systemName: "person.3")
                                      .foregroundColor(Color.accentColor)
                                      .padding()
                                    Text("Users")
                                  }
                                })
                NavigationLink(destination: RoomCodeView()
                                .onAppear(perform: {
                                  showNav = false
                                })
                                .onDisappear(perform: {
                                  showNav = true
                                }), label: {
                                  HStack {
                                    Image(systemName: "qrcode")
                                      .foregroundColor(Color.accentColor)
                                      .padding()
                                    Text("Code")
                                  }
                                })
              }
              
              Section(header: Text("Room Settings")) {
                if RoomDescription == "" {
                    Text("A VoteNote room")
                } else {
                    Text(RoomDescription)
                }
                HStack{
                  Text("Room Capacity")
                  Spacer()
                  Text("\(RoomCapacity)")
                }
                
                HStack{
                  Text("Songs Per User")
                  Spacer()
                  Text("\(SongsPerUser)")
                }
                
                NavigationLink(
                  destination: GenreView(genres: $genres).navigationTitle("Genres"),
                  label: {
                    HStack{
                      Text("Genres Allowed")
                      Spacer()
                    }
                  })
                
                HStack{
                    if VotingEnabled {
                        Text("Voting Enabled")
                    } else {
                        Text("Voting Disabled")
                    }
                }
                
                HStack{
                  Text("Anonymize All Users:")
                  Spacer()
                    if AnonUsr {
                        Text("True")
                    } else {
                        Text("False")
                    }
                }
              }
              
              Section() {
                Button(action: {
                    exitRoom()
                }, label: {
                  HStack {
                    Spacer()
                    Text("Leave Room")
                        .foregroundColor(Color.red)
                    Spacer()
                  }
                })
                .padding(.vertical)
              }
            }
          }
          .navigationTitle("Room").onAppear(perform: {
            sharedSpotify.pause()
            var curRoom: room = room(name: "", anonUsr: false, capacity: 0, explicit: false, voting: true)
            getRoom(code: currentQR.roomCode, completion: {room, err in
                if (room != nil) {
                
                  curRoom = room!
                    
                  RoomName = curRoom.name
                  RoomDescription = curRoom.desc!
                  VotingEnabled = curRoom.voting
                  AnonUsr = curRoom.anonUsr
                  SongsPerUser = curRoom.spu
                  RoomCapacity = curRoom.capacity
                  ExplicitSongsAllowed = curRoom.explicit
                  genres = curRoom.genres
                }
            })
          })
          .navigationBarHidden(true).navigationViewStyle(StackNavigationViewStyle())

        }.frame(height: geo.size.height)
    }
  }
}



