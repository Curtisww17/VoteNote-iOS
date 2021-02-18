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
  
  @State var code = ""
  @State var joined = false
  
  func join(c: String) {
    let ret = joinRoom(code: c)
    
    self.joined = true
    if ret != nil {
      self.joined = true
    }
    print("\n\n\n\(self.joined)")
  }
  
  
  var body: some View {
    return NavigationView {
      ZStack {
        //Color.white
        VStack {
          Text("Join Room")
          /*
          NavigationLink(
            destination: UserController(isInRoom: $isInRoom),
            label: {
              Text("go to User Queue Page")
            })*/
          TextField("Room Code", text: $code).multilineTextAlignment(.center)
          
          if self.code != "" {
              Button(action: {
                join(c: code)
                //print("\n\n\n\n\n\n\n\n\n\n\n\\n\(code)")
              }) {
                  Text("Join Room")
                      
              }.padding()
          }
        }
      }
      .navigationBarHidden(true)
    }.navigate(to: UserController( isInRoom: $isInRoom), when: $joined)
  }
}

/*struct JoinRoomView_Previews: PreviewProvider {
  static var previews: some View {
    JoinRoomView()
  }
}*/

struct JoinRoomView_PreviewContainer: View {
    
  @State var isInRoom = false
  @State var spotify: Spotify = Spotify()

    var body: some View {
      JoinRoomView(isInRoom: $isInRoom, spotify: spotify)
    }
}


struct JoinRoomView_Previews: PreviewProvider {
  static var previews: some View {
    
    JoinRoomView_PreviewContainer()
  }
}
