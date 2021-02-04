//
//  User_RoomPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct User_RoomPageView: View {
  
  var body: some View {
    return NavigationView {
      ZStack {
        VStack {
          Text("User Room Page!")
          Button(action: actionSheet) {
            Text("Share")
          }
        }
      }
      .navigationTitle("Room Name")
    }
  }
  
  func actionSheet() {
          let data = "Room Code"
          let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
          UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
      }
}

struct User_RoomPageView_Previews: PreviewProvider {
  static var previews: some View {
    User_RoomPageView()
  }
}
