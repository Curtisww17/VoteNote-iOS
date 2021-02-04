//
//  CreateRoomView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI


struct CreateRoomView: View {
    //TODO: Send Room info to Database
    //TODO: Create second version of this view to take in info from an existing room
  @Binding var isInRoom: Bool
    @State var showAlert: Bool = false
    
    @State var userCapacity: Int = 20 {
        didSet {
            if userCapacity < 1 {
                userCapacity = 1
            }
        }
    }
  @State var songsPerUser: Int = 4 {
    didSet {
        if songsPerUser < 1 {
            songsPerUser = 1
        }
    }
  }
    
  @State var roomName: String = ""
  @State var roomDescription: String = ""
    
  var body: some View {
    return NavigationView {
      ZStack {
        Color.white
        VStack {
            
            Form {
                Section(header: Text("General Room Information")) {
                    TextField("Room Name", text: $roomName)
                    TextField("Room Description", text: $roomDescription)
                }
                
                Section(header: Text("Settings")) {
                    HStack {
                        Text("User Capacity")
                            .padding(.trailing)
                        Stepper("\(userCapacity)", onIncrement: { userCapacity+=1}, onDecrement: { userCapacity-=1})
                            .padding(.leading)
                    }
                    HStack {
                        Text("Songs Per User")
                            .padding(.trailing)
                        Stepper("\(songsPerUser)", onIncrement: { songsPerUser+=1}, onDecrement: { songsPerUser-=1})
                            .padding(.leading)
                    }
                }
            }
            
            if self.roomName == "" || self.roomDescription == "" {
                NavigationLink(
                  destination: Host_QueuePageView(isInRoom: $isInRoom),
                  label: {
                    Text("Create Room")
                  })
                  .padding(.vertical)
            }
          
          Spacer()
        }
      }
      .navigationBarHidden(true)
    }
  }
}

struct CreateRoomView_PreviewContainer: View {
  
    @State var userCapacity: Int = 20
    @State var songsPerUser: Int = 4
  @State var isInRoom = false
    
    var body: some View {
      CreateRoomView(isInRoom: $isInRoom, userCapacity: userCapacity, songsPerUser: songsPerUser)
    }
}

struct CreateRoomView_Previews: PreviewProvider {
  static var previews: some View {
    
    CreateRoomView_PreviewContainer()
  }
}
