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
  @Binding var isInRoom: Bool
  @State var genres: [String] = []
    
  @State var showingCouldNotJoinAlert: Bool = false
  
  
  func join(c: String) {
    joinRoom(code: c){ (ret, message) in
      if message != nil {
        showingCouldNotJoinAlert = true
      }else{
        self.joined = true
        if ret != nil {
          RoomName = ret!.name
          RoomDescription = (ret?.desc)!
          RoomCapacity = ret!.capacity
          SongsPerUser = ret!.spu
          VotingEnabled = ret!.voting
          ExplicitSongsAllowed = ret!.explicit
          AnonUsr = ret!.anonUsr
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
            if (!currRoom.closed) {
              join(c: currRoom.code)
            }
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
    .navigate(to: UserController(isInRoom: $isInRoom, genres: genres), when: $joined)
    .onAppear(perform: {
      for code in codes {
        getRoom(code: code, completion: { (prevRoom, err) in
          if (!(prevRoom!.bannedUsers ?? []).contains(getUID())) {
          previousRooms.append(prevRoom!)
          }
                })
      }
    }).alert(isPresented: $showingCouldNotJoinAlert) {
        Alert(title: Text("Joining Room"), message: Text("Could not Join Room"), dismissButton: .default(Text("Ok")) {
            showingCouldNotJoinAlert = false
        })
      }
  }
}
