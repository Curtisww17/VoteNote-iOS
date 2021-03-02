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
  @State var showNav = true;
  @State var roomName: String
  @State var roomDescription: String
  @State var roomCapacity: Int
  @State var songsPerUser: Int
  @State var notExited: Bool = false
    
  @State var currentView = 0
    
    func exitRoom() {
        print("Left Room")
        leaveRoom()
        notExited = true
    }
    
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
        User_QueuePageView()
          .animation(.default)
          .transition(.move(edge: .leading))
      } else {
        User_RoomPageView(roomName: roomName, roomDescription: roomDescription, roomCapacity: roomCapacity, songsPerUser: songsPerUser, showNav: $showNav)
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
    .navigationBarHidden(true).onAppear(perform: {
        notExited = false
    }).navigate(to: LandingPageView(), when: $notExited).navigationViewStyle(StackNavigationViewStyle())
  }
}

