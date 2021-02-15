//
//  JoinRoomView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI


struct JoinRoomView: View {
  @Binding var isInRoom: Bool
  @ObservedObject var spotify: Spotify = sharedSpotify
  
  
  var body: some View {
    return NavigationView {
      ZStack {
        Color.white
        VStack {
          Text("Join Room")
          NavigationLink(
            destination: UserController(isInRoom: $isInRoom),
            label: {
              Text("go to User Queue Page")
            })
        }
      }
      .navigationBarHidden(true)
    }
  }
}

/*struct JoinRoomView_Previews: PreviewProvider {
  static var previews: some View {
    JoinRoomView()
  }
}*/
