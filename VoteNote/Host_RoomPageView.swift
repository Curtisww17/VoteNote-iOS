//
//  Host_RoomPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct Host_RoomPageView: View {
    @State var currentView = 1
    @Binding var roomName: String
    @Binding var roomDescription: String
    @Binding var roomCapacity: Int
    @Binding var songsPerUser: Int
    
  var body: some View {
    return NavigationView {
      ZStack {
        VStack {
            
            Picker(selection: self.$currentView, label: Text("I don't know what this label is for")) {
              Text("Queue").tag(0)
              Text("Room").tag(1)
            }.pickerStyle(SegmentedPickerStyle())
            .frame(width: UIScreen.main.bounds.size.width / 2,  alignment: .center)

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
            }
        }.navigationBarHidden(true)
      }
    }
  }
}

struct Host_RoomPageView_PreviewContainer: View {
    
    @State var roomName: String = "Room Name"
    @State var roomDescription: String = "This is an example room"
    @State var roomCapacity: Int = 20
    @State var songsPerUser: Int = 4

    var body: some View {
        Host_RoomPageView(roomName: $roomName, roomDescription: $roomDescription, roomCapacity: $roomCapacity, songsPerUser: $songsPerUser)
    }
}

struct Host_RoomPageView_Previews: PreviewProvider {
  static var previews: some View {
    Host_RoomPageView_PreviewContainer()
  }
}
