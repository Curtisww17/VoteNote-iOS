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
  
  
  var body: some View {
    return NavigationView {
      ZStack {
        Color.white
        VStack {
          Text("Join Room")
          NavigationLink(
            destination: User_QueuePageView(isInRoom: $isInRoom),
            label: {
              Text("go to User Queue Page")
            })
        }
      }
      .navigationBarHidden(true)
    }
  }
}
