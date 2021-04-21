//
//  Host_RoomPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

/**
    The UI for the host's version of the Room View
 */
struct Host_RoomPageView: View {
  @State var currentView = 1
  @Binding var showNav: Bool
  @Binding var notExited: Bool
  @Binding var isTiming: Bool
  @State var inRoom: Bool = true
  @State var autoLike: Bool = false
  @Binding var autoVote: Bool
  let isHost = true
  //@Binding var isInRoom: Bool

  @Binding var genres: [String]
  
    /**
        Causes the current user to leave the room
     */
  func exitRoom() {
    closeRoom()
    leaveRoom()
    isTiming = false
    notExited = true
    //isInRoom = false
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
          
          Section(footer: NavigationLink(destination: EditRoomView(isInRoom: $inRoom, genres: $genres, genreSet: Set(genres))) {
                Text("Edit").foregroundColor(Color.blue)
            }) {
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
            
            HStack{
              Text("Base Playlist")
              Spacer()
                Text("\(sharedSpotify.PlaylistBase?.name ?? "no base")")
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
                if ExplicitSongsAllowed {
                    Text("Explicit Songs Allowed")
                } else {
                    Text("Explicit Songs Not Allowed")
                }
            }
            
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
                    Text("Enabled")
                } else {
                    Text("Disabled")
                }
            }
          }
          Section() {
            
            ZStack {
              Text("Close Room")
                  .foregroundColor(Color.red)
              NavigationLink(destination: LandingPageView().onAppear(perform: {
                exitRoom()
                print("Did the exit stuff")
            }))  {
                    EmptyView()
                }.hidden()
            }
            .padding(.vertical)
          }
        }
      }
      .navigationTitle("Room")
      .navigationBarHidden(true).navigationViewStyle(StackNavigationViewStyle())
        
    }
    .frame(height: geo.size.height).navigationViewStyle(StackNavigationViewStyle())
    }
  }
}
