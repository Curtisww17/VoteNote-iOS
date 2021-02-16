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
            if (currentView == 0) {
                NavigationLink(
                  destination: AddMusicView().navigationBarTitle("Browse"),
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
        Host_QueuePageView(isInRoom: $isInRoom)
          .animation(.default)
          .transition(.move(edge: .leading))
      } else {
        Host_RoomPageView(roomName: "Primanti Bros.", roomDescription: "Description goes here", roomCapacity: 5, songsPerUser: 5, showNav: $isInRoom)
          .animation(.default)
          .transition(.move(edge: .trailing))
      }
    }
    .navigationTitle("Lobby")
    .navigationBarHidden(true)
  }
}

struct HostController_PreviewContainer: View {
    @State var isInRoom: Bool = true

    var body: some View {
        HostController(isInRoom: $isInRoom)
    }
}

struct HostController_Previews: PreviewProvider {
  static var previews: some View {
    HostController_PreviewContainer()
  }
}
