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
  @State var roomName: String
  @State var roomDescription: String
  @State var roomCapacity: Int
  @State var songsPerUser: Int
  @State var votingEnabled: Bool
  @Binding var anonUsr: Bool
  @ObservedObject var currentRoom: CurrentRoom = CurrentRoom()
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
              Section(header: Text(roomName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .padding(.top)) {
                //Other Buttons will be added here
                
              }
              
              Section() {
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
                NavigationLink(destination: UsersListView(isHost: isHost, votingEnabled: votingEnabled)
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
                if roomDescription == "" {
                    Text("A VoteNote room")
                } else {
                    Text(roomDescription)
                }
                HStack{
                  Text("Room Capacity")
                  Spacer()
                  Text("\(roomCapacity)")
                }
                
                HStack{
                  Text("Songs Per User")
                  Spacer()
                  Text("\(songsPerUser)")
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
                    if votingEnabled {
                        Text("Voting Enabled")
                    } else {
                        Text("Voting Disabled")
                    }
                }
                
                HStack{
                  Text("Anonymize All Users:")
                  Spacer()
                    if anonUsr {
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
          .navigationTitle("Room")
          .navigationBarHidden(true).navigationViewStyle(StackNavigationViewStyle())

        }.frame(height: geo.size.height)
    }
    //return NavigationView {
    
  }
  
  
}



