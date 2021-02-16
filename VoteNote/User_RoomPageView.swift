//
//  User_RoomPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct User_RoomPageView: View {
  
  @State var currentView = 1
  var roomName: String = "Primanti Bros."
  var roomDescription: String = "Description goes here"
  var roomCapacity: Int = 5
  var songsPerUser: Int = 5
  
  var body: some View {
    return NavigationView {
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
            
            Section(header: Text("Room Settings")) {
              Text(roomDescription)
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
            }
            
            Button(action: {
              actionSheet()
            }, label: {
              HStack {
                Spacer()
                Text("Share Room Code")
                  .foregroundColor(Color.accentColor)
                Spacer()
              }
            })
          }
        }
        .navigationTitle("Room")
        .navigationBarHidden(true)
      }
    }
  }
  
  func actionSheet() {
    let data = "Room Code"
    let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
  }
}


struct User_RoomPageView_PreviewContainer: View {
  
  @State var roomName: String = "Room Name"
  @State var roomDescription: String = "This is an example room"
  @State var roomCapacity: Int = 20
  @State var songsPerUser: Int = 4
  
  var body: some View {
    User_RoomPageView(roomName: roomName, roomDescription: roomDescription, roomCapacity: roomCapacity, songsPerUser: songsPerUser)
  }
}

struct User_RoomPageView_Previews: PreviewProvider {
  static var previews: some View {
    User_RoomPageView_PreviewContainer()
  }
}


