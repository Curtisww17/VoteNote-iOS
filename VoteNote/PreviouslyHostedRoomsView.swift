//
//  PreviouslyHostedRoomsView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 3/17/21.
//

import Foundation
import SwiftUI


/*
 view to see rooms that the user has previously hosted
 */
struct PreviouslyHostedRoomsView: View {
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @State var codes: [String]
  @State var previousRooms: [room] = []
  
  @State var joined = false
  @Binding var isInRoom: Bool
  @State var genres: [String] = []
  
  @State var showingCouldNotJoinAlert: Bool = false
  @State var backToLanding: Bool = false
    
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
        
        /*ZStack {
            HStack {
              Image(systemName: "chevron.left")
                .resizable()
                .frame(width: 15, height: 20)
                .padding(.leading)
              Text("Back")
            }
              .foregroundColor(Color.blue)
          NavigationLink(destination: LandingPageView())  {
                EmptyView()
            }.hidden()
        }
        .padding(.vertical)
        Spacer()*/
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
      }.navigate(to: LandingPageView(), when: $backToLanding)
  }
}
