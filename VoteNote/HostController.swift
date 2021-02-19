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
    @State var notExited: Bool = false
  
    func exitRoom() {
        print("Left Room")
        leaveRoom()
        notExited = true
    }
    
  @State var currentView = 1
  var body: some View {
    OperationQueue.main.addOperation {
      isInRoom = true
    }
    return VStack {
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
        Host_QueuePageView()
          .animation(.default)
          .transition(.move(edge: .leading))
      } else {
        Host_RoomPageView(roomName: roomName, roomDescription: roomDescription, roomCapacity: 5, songsPerUser: 5, showNav: $showNav)
          .animation(.default)
          .transition(.move(edge: .trailing))
        
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
    .navigationTitle("Lobby")
    .navigationBarHidden(true).onAppear(perform: {
        notExited = false
    }).navigate(to: LandingPageView(), when: $notExited)
  }
}

struct HostController_PreviewContainer: View {
    @State var isInRoom: Bool = true

    var body: some View {
        HostController(isInRoom: $isInRoom, roomName: "Primanti Bros", roomDescription: "Description Goes Here")
    }
}

struct HostController_Previews: PreviewProvider {
  static var previews: some View {
    HostController_PreviewContainer()
  }
}
