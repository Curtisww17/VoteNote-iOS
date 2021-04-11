//
//  PreviouslyHostedRoomsView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 3/17/21.
//

import Foundation
import SwiftUI


struct PreviouslyHostedRoomsView: View {
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @State var codes: [String]
  @State var previousRooms: [room] = []
  
  @State var joined = false
  @Binding var isInRoom: Bool
  
  
  func join(c: String) {
    joinRoom(code: c){ (ret, message) in
      if message != nil {
        //TODO: popup that they cannot join the room
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
          Genres = ret!.genres
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
            Text(currRoom.name)
              .foregroundColor(.primary)
          })
        }
      }
      .navigationBarBackButtonHidden(true)
    }
    .navigate(to: HostController(isInRoom: $isInRoom), when: $joined)
    .onAppear(perform: {
      if (previousRooms.count == 0) {
        for code in codes {
          getRoom(code: code, completion: { (prevRoom, err) in
            previousRooms.append(prevRoom!)
                  })
        }
      }
    })
  }
}
