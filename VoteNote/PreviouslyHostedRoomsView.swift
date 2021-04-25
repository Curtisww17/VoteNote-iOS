//
//  PreviouslyHostedRoomsView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 3/17/21.
//

import Foundation
import SwiftUI


/**
    The UI for the list of previously hosted rooms
 */
struct PreviouslyHostedRoomsView: View {
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @State var codes: [String]
  @State var previousRooms: [room] = []
  
  @State var joined = false
  @Binding var isInRoom: Bool
  @State var genres: [String] = []
  
  @State var showingCouldNotJoinAlert: Bool = false
    @State var showingCouldNotJoinAlertPremium: Bool = false
  @State var backToLanding: Bool = false
    
    /**
        The function for joining a previously hosted VoteNote room
     */
  func join(c: String) {
    joinRoom(code: c){ (ret, message) in
      if message != nil {
        showingCouldNotJoinAlert = true
        presentationMode.wrappedValue.dismiss()
      } else if !(sharedSpotify.currentUser?.product ?? "" == "premium") {
        showingCouldNotJoinAlertPremium = true
        presentationMode.wrappedValue.dismiss()
      } else {
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
          openRoom()
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
    .navigate(to: HostController(isInRoom: $isInRoom, genres: genres), when: $joined)
    .onAppear(perform: {
      if (previousRooms.count == 0) {
        for code in codes {
          getRoom(code: code, completion: { (prevRoom, err) in
            previousRooms.append(prevRoom!)
                  })
        }
      }
    }).alert(isPresented: $showingCouldNotJoinAlert) {
        Alert(title: Text("Host Room"), message: Text("Could not Host Room"), dismissButton: .default(Text("Ok")) {
            showingCouldNotJoinAlert = false
            backToLanding = true
        })
      }.alert(isPresented: $showingCouldNotJoinAlertPremium) {
        Alert(title: Text("Host Room"), message: Text("Must be a Premium User to Host a Room"), dismissButton: .default(Text("Ok")) {
            showingCouldNotJoinAlertPremium = false
            backToLanding = true
        })
      }.navigate(to: LandingPageView(), when: $backToLanding)
  }
}
