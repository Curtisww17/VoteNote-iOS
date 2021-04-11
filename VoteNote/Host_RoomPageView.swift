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
  let isHost = true
    
  @Binding var genres: [String]
  
    /**
        Causes the current user to leave the room
     */
  func exitRoom() {
    closeRoom()
    leaveRoom()
    isTiming = false
    notExited = true
  }
    //@State var notExited: Bool = true
  //TODO- make the room capacity actually do stuff
  
  var body: some View {
    GeometryReader { geo in
    //return NavigationView {
    /*return*/ ZStack {
      VStack {
        
        Form {
          Section(header: Text(RoomName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .padding(.top)) {
            //Other Buttons will be added here
            
          }
          
            Section(footer: NavigationLink(destination: EditRoomView(isInRoom: $inRoom)) {
                Text("Edit").foregroundColor(Color.blue)
            }) {
            NavigationLink(destination: QueueHistoryView( songHistory: songHistory)
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
              NavigationLink(destination: UsersListView(isHost: isHost, votingEnabled: VotingEnabled)
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
                destination: GenreView(genres: $genres),
              label: {
                HStack{
                  Text("Genres Allowed")
                  Spacer()
                    //Text("\(sharedSpotify.PlaylistBase?.name ?? "no base")")
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
                  Text("Close Room")
                    .foregroundColor(Color.red)
                  Spacer()
                }
              })
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
