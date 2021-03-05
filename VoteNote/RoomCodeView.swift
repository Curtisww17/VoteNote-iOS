//
//  RoomCodeView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/23/21.
//

import Foundation
import SwiftUI

struct RoomCodeView: View {
  @ObservedObject var currentRoom: CurrentRoom
  
  var body: some View {
    return VStack {
      if currentRoom.roomQR != nil {
        Image(uiImage: currentRoom.roomQR!)
        //.interpolation(.none)
        //.resizable()
        //.scaledToFit()
        //.frame(width: 200, height: 200)
        
      }
      Text(currentRoom.roomCode)
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
    }.onAppear(perform: {
      getCurrRoom(completion: {code, err in
        if err == nil {
          self.currentRoom.update(roomCode: code)
        }
      })
    })
  }
  
  func actionSheet() {
    let link = "VoteNote://SpotifyAuthentication/?room_code=" + currentRoom.roomCode
    let data = [currentRoom.roomCode, currentRoom.roomQR!, link] as [Any]
    let av = UIActivityViewController(activityItems: data, applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    
  }
}
