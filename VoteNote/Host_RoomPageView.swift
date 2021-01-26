//
//  Host_RoomPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct Host_RoomPageView: View {
  
  var body: some View {
    return NavigationView {
      ZStack {
        VStack {
          Text("Host Room Page!")
        }
        .navigationTitle("Room Name")
      }
    }
  }
}

struct Host_RoomPageView_Previews: PreviewProvider {
  static var previews: some View {
    Host_RoomPageView()
  }
}
