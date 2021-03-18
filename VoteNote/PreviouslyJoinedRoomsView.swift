//
//  PreviouslyJoinedRoomsView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 3/14/21.
//

import Foundation
import SwiftUI

struct PreviouslyJoinedRoomsView: View {
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @State var codes: [String]
  @State var previousRooms: [room] = []
  
  @State var joined = false
  @State var roomName: String = ""
  @State var roomDescription: String = ""
  @State var roomCapacity: Int = 0
  @State var songsPerUser: Int = 0
  @State var votingEnabled: Bool = true
  @State var explicitSongsAllowed: Bool = false
  @State var anonUsr: Bool = false
  @Binding var isInRoom: Bool
  
  
  func join(c: String) {
    joinRoom(code: c){ (ret, message) in
      if message != nil {
        //TODO: popup that they cannot join the room
      }else{
        self.joined = true
        if ret != nil {
          roomName = ret!.name
          roomDescription = (ret?.desc)!
          roomCapacity = ret!.capacity
          songsPerUser = ret!.spu
          votingEnabled = ret!.voting
          explicitSongsAllowed = ret!.explicit
          anonUsr = ret!.anonUsr
          //songsPerUser = ret. //not in db room object
          self.joined = true        }
      }
    }
  }
  
  
  var body: some View {
    return VStack {
      Form {
        ForEach(previousRooms, id: \.code) {currRoom in
          Button(action: {
            join(c: currRoom.code)
          }, label: {
            Text(currRoom.name)
              .foregroundColor(.primary)
          })
        }
      }
    }
    .navigate(to: UserController(isInRoom: $isInRoom, roomName: roomName, roomDescription: roomDescription, roomCapacity: roomCapacity, songsPerUser: songsPerUser, votingEnabled: votingEnabled, anonUsr: anonUsr, explicitSongsAllowed: explicitSongsAllowed), when: $joined)
    .onAppear(perform: {
      for code in codes {
        getRoom(code: code, completion: { (prevRoom, err) in
          previousRooms.append(prevRoom!)
                })
      }
    })
  }
}
