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
  @State var genres: [String] = []
  
  
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
          genres = ret!.genres
          //songsPerUser = ret. //not in db room object
          self.joined = true        }
      }
    }
  }
  
  
  var body: some View {
    return VStack {
      HStack {
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }, label: {
          HStack {
            Image(systemName: "chevron.left")
              .resizable()
              .frame(width: 15, height: 20)
              .padding(.leading)
            Text("Back")
          }
        })
        .frame(alignment: .leading)
        Spacer()
      }
      Form {
        ForEach(previousRooms, id: \.code) {currRoom in
          Button(action: {
            join(c: currRoom.code)
          }, label: {
            if (currRoom.closed) {
              Text(currRoom.name)
                .foregroundColor(.gray)
            } else {
            Text(currRoom.name)
              .foregroundColor(.primary)
            }
          })
        }
      }
    }
    .navigate(to: UserController(isInRoom: $isInRoom, roomName: roomName, roomDescription: roomDescription, roomCapacity: roomCapacity, songsPerUser: songsPerUser, votingEnabled: votingEnabled, anonUsr: anonUsr, explicitSongsAllowed: explicitSongsAllowed, genres: genres), when: $joined)
    .onAppear(perform: {
      for code in codes {
        getRoom(code: code, completion: { (prevRoom, err) in
          if (!(prevRoom!.bannedUsers ?? []).contains(getUID())) {
          previousRooms.append(prevRoom!)
          }
                })
      }
    })
  }
}
