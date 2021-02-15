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
  
  @State var currentView = 0
  var body: some View {
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
          NavigationLink(
            destination: ProfileView(),
            label: {
              if (currentView == 0) {
                Text("Add")
              } else {
                Image(systemName: "person")
                  .resizable()
                  
                  .frame(width: 30, height: 30)
              }
            })
        }
        .frame(width: UIScreen.main.bounds.size.width/4)
        
      }
      .frame(width: UIScreen.main.bounds.size.width, alignment: .top)
      
      if (currentView == 0) {
        User_QueuePageView(isInRoom: $isInRoom)
          .animation(.default)
          .transition(.move(edge: .leading))
      } else {
        User_RoomPageView(roomName: "Primanti Bros.", roomDescription: "Description goes here", roomCapacity: 5, songsPerUser: 5)
          .animation(.default)
          .transition(.move(edge: .trailing))
      }
    }
    .navigationTitle("Lobby")
    .navigationBarHidden(true)
  }
}

