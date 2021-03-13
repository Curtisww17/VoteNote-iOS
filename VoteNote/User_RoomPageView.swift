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
  @Binding var notExited: Bool
  
  @Binding var showNav: Bool
  
    /**
        Causes the current user to leave the room
     */
  func exitRoom() {
      leaveRoom()
      notExited = true
  }
  
  
  var body: some View {
    //return NavigationView {
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
            NavigationLink(destination: UsersListView()
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
            NavigationLink(destination: RoomCodeView(currentRoom: currentRoom)
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
      .navigationBarHidden(true)
    }
    
  }
  
  
}



