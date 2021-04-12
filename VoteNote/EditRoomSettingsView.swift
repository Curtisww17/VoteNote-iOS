//
//  EditRoomSettingsView.swift
//  VoteNote
//
//  Created by COMP401 on 3/24/21.
//

import Foundation
import SwiftUI

struct EditRoomView: View {
  @Binding var isInRoom: Bool
  @State var showAlert: Bool = false
    
  @Environment(\.presentationMode) var presentationMode
  
  @State var userCapacity: Int = RoomCapacity {
    didSet {
      if userCapacity < 1 {
        userCapacity = 1
      } else if userCapacity > 50 {
        userCapacity = 50
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
    @Binding var genres: [String]
  @State var genreSet: Set<String>
  
  func editRoom(){
    print("Room")
    let newRoom: room = room(name: roomName, desc: roomDescription, anonUsr: anonUsr, capacity: userCapacity, explicit: explicitSongsAllowed, voting: votingEnabled, code: currentQR.roomCode, spu: songsPerUser, genres: Array(genreSet))
    makeRoom(newRoom: newRoom)
    
    RoomName = roomName
    RoomDescription = roomDescription
    VotingEnabled = votingEnabled
    AnonUsr = anonUsr
    RoomCapacity = userCapacity
    SongsPerUser = songsPerUser
    ExplicitSongsAllowed = explicitSongsAllowed
    presentationMode.wrappedValue.dismiss()
    genres = Array(genreSet)
  }
  
  var body: some View {
    ZStack {
      VStack {
        
        Form {
          Section(header: Text("General Room Information")) {
            TextField("Room Name", text: $roomName).onChange(of: roomName, perform: { value in
                if roomName.count > 20 {
                    roomName.removeLast()
                }
            })
            TextField("Room Description", text: $roomDescription).onChange(of: roomDescription, perform: { value in
                if roomDescription.count > 20 {
                    roomDescription.removeLast()
                }
            })
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
                    destination: GenreSelectView(genres: $genreSet)
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
            
            /*HStack {
              Text("Anonymous Users")
              Toggle(isOn: $anonUsr) {
                Text("")
              }
            }*/
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
    }
    .navigationBarHidden(true)
    .navigate(to: HostController(isInRoom: $isInRoom, genres: Array(genres)), when: $madeRoom)
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
