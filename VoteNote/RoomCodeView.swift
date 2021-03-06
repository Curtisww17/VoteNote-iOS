//
//  RoomCodeView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/23/21.
//

import Foundation
import SwiftUI

/**
    The UI view of the Room Code View
 */
struct RoomCodeView: View {
  
  var body: some View {
    return VStack {
      if currentQR.roomQR != nil {
        Image(uiImage: currentQR.roomQR!)
      }
      Text(currentQR.roomCode)
        .font(.title)
      
      Spacer()
      List {
        Button(action: {
          actionSheet()
        }, label: {
          HStack {
            Spacer()
            Text("Share")
              .foregroundColor(Color.accentColor)
            Spacer()
          }
        })
      }
    }
  }
  
  func actionSheet() {
    let link = "VoteNote://SpotifyAuthentication/?room_code=" + currentQR.roomCode
    let data = [currentQR.roomQR!, link] as [Any]
    let av = UIActivityViewController(activityItems: data, applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    
  }
}
