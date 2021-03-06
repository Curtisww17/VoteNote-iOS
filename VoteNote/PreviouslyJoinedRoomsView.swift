//
//  PreviouslyJoinedRoomsView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 3/14/21.
//

import Foundation
import SwiftUI

/**
    The UI for the list of previously joined rooms
 */
struct PreviouslyJoinedRoomsView: View {
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @State var codes: [String]
  @State var previousRooms: [room] = []
  
  @State var joined = false
  @Binding var isInRoom: Bool
  @State var genres: [String] = []
    
  @State var showingCouldNotJoinAlert: Bool = false
  @State var backToLanding: Bool = false
  
    /**
        The function for joining a previously joined VoteNote room
     */
  func join(c: String) {
    joinRoom(code: c){ (ret, message) in
      if message != nil {
        showingCouldNotJoinAlert = true
        presentationMode.wrappedValue.dismiss()
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
                Image(systemName: "chevron.left").resizable().frame(width: 12.5, height: 18.5)
                Text("Back").font(.body)
            }
        })
        .frame(alignment: .leading)
        Spacer()
      }
      .padding(.leading)
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
            backToLanding = true
        })
      }.navigate(to: LandingPageView(), when: $backToLanding)
  }
}
