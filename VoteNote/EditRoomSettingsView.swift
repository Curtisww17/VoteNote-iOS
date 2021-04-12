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
  
  @State var userCapacity: Int = RoomCapacity {
    didSet {
      if userCapacity < 1 {
        userCapacity = 1
      }
    }
  }
  @State var songsPerUser: Int = SongsPerUser {
    didSet {
      if songsPerUser < 1 {
        songsPerUser = 1
      }
    }
  }
  
    //TO-DO: limit chars when editing
    //@ObservedObject var roomName = TextBindingManager(limit: 20, text: RoomName.trimmingCharacters(in: .whitespacesAndNewlines))
    //@ObservedObject var roomDescription = TextBindingManager(limit: 20, text: RoomDescription.trimmingCharacters(in: .whitespacesAndNewlines))
    @State var roomName: String = RoomName
    @State var roomDescription = RoomDescription
    @State var votingEnabled: Bool = VotingEnabled
    @State var madeRoom: Bool = false
    @State var anonUsr: Bool = AnonUsr
    @State var explicitSongsAllowed: Bool = ExplicitSongsAllowed
    @State var genres: Set<String>
    @State var autoLike: Bool
  
  func editRoom(){
    print("Room")
    let newRoom: room = room(name: roomName, desc: roomDescription, anonUsr: anonUsr, capacity: userCapacity, explicit: explicitSongsAllowed, voting: votingEnabled, code: currentQR.roomCode, spu: songsPerUser, genres: Array(genres))
    makeRoom(newRoom: newRoom)
    
    RoomName = roomName
    RoomDescription = roomDescription
    VotingEnabled = votingEnabled
    AnonUsr = anonUsr
    RoomCapacity = userCapacity
    SongsPerUser = songsPerUser
    ExplicitSongsAllowed = explicitSongsAllowed
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
            
            HStack {
              Text("Allow Auto Liking Favorites")
              Toggle(isOn: $autoLike) {
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
    .navigate(to: HostController(isInRoom: $isInRoom, genres: Array(genres)), when: $madeRoom)
    .onAppear(perform: {
//        getCurrRoom(completion: {code, err in
//          if err == nil {
//            self.currentRoom.update(roomCode: code)
//          }
//        })
        
        //RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
        /*var curRoom: room = room(name: "", anonUsr: false, capacity: 0, explicit: false, voting: true)
        getRoom(code: currentQR.roomCode, completion: {room, err in
            if (room != nil) {
                curRoom = room!*/
              
              /*roomName.text = RoomName
              roomDescription.text = RoomDescription
              votingEnabled = VotingEnabled
              anonUsr = AnonUsr
              songsPerUser = SongsPerUser
              userCapacity = RoomCapacity
              explicitSongsAllowed = ExplicitSongsAllowed
              genres = Set(Genres)*/
            /*}
        })*/
        
        //RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
    })
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
