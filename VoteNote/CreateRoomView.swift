//
//  CreateRoomView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI


struct CreateRoomView: View {
  
  var body: some View {
    return NavigationView {
      ZStack {
        Color.white
        VStack {
          Text("Create Room")
          NavigationLink(
            destination: Host_QueuePageView(),
            label: {
              Text("go to Host Queue Page")
            })
        }
      }
      .navigationBarHidden(true)
    }
  }
}

struct CreateRoomView_Previews: PreviewProvider {
  static var previews: some View {
    CreateRoomView()
  }
}
