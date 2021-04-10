//
//  EditRoomSettingsView.swift
//  VoteNote
//
//  Created by COMP401 on 3/24/21.
//

import Foundation
import SwiftUI

struct EditRoomView: View {
  //TODO: Create second version of this view to take in info from an existing room
  @Binding var isInRoom: Bool
  @State var showAlert: Bool = false
    
  @Environment(\.presentationMode) var presentationMode
  
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
  @State var votingEnabled: Bool = true
  @State var madeRoom: Bool = false
  @State var anonUsr: Bool = false
  @State var explicitSongsAllowed: Bool = false
  @State var genres: Set<String> = []
  
  func editRoom(){
    //TO-DO- send info to room, songs per user
    print("Room")
    /*let newRoom: room = room(name: roomName, desc: roomDescription, anonUsr: anonUsr, capacity: userCapacity, explicit: explicitSongsAllowed, voting: votingEnabled, spu: songsPerUser)
    let newcode = makeRoom(newRoom: newRoom)
    storePrevRoom(code: newcode)
    madeRoom = true*/
    presentationMode.wrappedValue.dismiss()
  }
  
  var body: some View {
    //return NavigationView {
    ZStack {
      //Color.white
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
            
            HStack{
                NavigationLink(
                    destination: GenreSelectView(genres: $genres)
                    .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                  label: {
                    Text("Genres Allowed")
                  })
            }
            
            HStack {
              Text("Explicit Songs Allowed")
              
              Toggle(isOn: $explicitSongsAllowed) {
                Text("")
              }
            }
            .padding(.trailing)
            
            HStack {
              Text("Anonymous Users")
              Toggle(isOn: $anonUsr) {
                Text("")
              }
            }
            .padding(.trailing)
            
            HStack {
              Text("Voting Enabled")
              Toggle(isOn: $votingEnabled) {
                Text("")
              }
            }
            .padding(.trailing)
          }
          
        }
        
        if self.roomName != "" {
          Button(action: {editRoom()}) {
            Text("Save Room Edits")
            
          }.padding()
        }
        
        Spacer()
      }
      //}
    }
    .navigationBarHidden(true)
    .navigate(to: HostController(isInRoom: $isInRoom, roomName: roomName, roomDescription: roomDescription, votingEnabled: votingEnabled, anonUsr: anonUsr, roomCapacity: userCapacity, songsPerUser: songsPerUser, explicitSongsAllowed: explicitSongsAllowed, genres: Array(genres)), when: $madeRoom)
    .onAppear(perform: {
//        getCurrRoom(completion: {code, err in
//          if err == nil {
//            self.currentRoom.update(roomCode: code)
//          }
//        })
        
        //RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
        var curRoom: room = room(name: "", anonUsr: false, capacity: 0, explicit: false, voting: true)
        getRoom(code: currentQR.roomCode, completion: {room, err in
            if (room != nil) {
                curRoom = room!
              
              roomName = curRoom.name
              roomDescription = curRoom.desc!
              votingEnabled = curRoom.voting
              anonUsr = curRoom.anonUsr
              explicitSongsAllowed = curRoom.explicit
              genres = Set(curRoom.genres)
            }
        })
        
        //RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
//        roomName = curRoom.name
//        roomDescription = curRoom.desc!
//        votingEnabled = curRoom.voting
//        anonUsr = curRoom.anonUsr
//        explicitSongsAllowed = curRoom.explicit
    })
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
