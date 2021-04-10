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
  @State var roomName: String = ""
  @State var roomDescription: String = ""
  @State var roomCapacity: Int = 0
  @State var songsPerUser: Int = 0
  @State var votingEnabled: Bool = true
  @State var explicitSongsAllowed: Bool = false
  @State var anonUsr: Bool = false
  @State var genres: [String] = sharedSpotify.genreList!.genres
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
            Text(currRoom.name)
              .foregroundColor(.primary)
          })
        }
      }
      .navigationBarBackButtonHidden(true)
    }
    .navigate(to: HostController(isInRoom: $isInRoom, roomName: roomName, roomDescription: roomDescription, votingEnabled: votingEnabled, anonUsr: anonUsr, roomCapacity: roomCapacity, songsPerUser: songsPerUser, explicitSongsAllowed: explicitSongsAllowed, genres: genres), when: $joined)
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
