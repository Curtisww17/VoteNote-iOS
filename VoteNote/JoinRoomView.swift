//
//  JoinRoomView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI
import CodeScanner


struct JoinRoomView: View {
  @Binding var isInRoom: Bool
  //@ObservedObject var spotify: Spotify = sharedSpotify
  
  @State var code = ""
  @State var joined = false
  @State private var isShowingScanner = false
  
  @State var roomName: String = ""
  @State var roomDescription: String = ""
  @State var roomCapacity: Int = 0
  @State var songsPerUser: Int = 0
  
  func join(c: String) {
    joinRoom(code: c){ (ret, message) in
      if message != nil {
        //TODO: popup that they cannot join the room
      }else{
      
        self.joined = true
        if ret != nil {
          roomName = ret!.name
          roomDescription = (ret?.desc)!
          roomCapacity = ret!.capacity
          //songsPerUser = ret. //not in db room object
          self.joined = true
        }
      }
    }
    //print("\n\n\nyou joined \(c)\n\n\n")
  }
  
  
  var body: some View {
    //return NavigationView {
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
        Button(action: {
          self.isShowingScanner = true
        }, label: {
          Text("Join with QR")
        })
        
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
    .onAppear(perform: {
      if sharedSpotify.isJoiningThroughLink.count != 0 {
        join(c: sharedSpotify.isJoiningThroughLink)
      }
    })
    .navigationBarHidden(true)
    .sheet(isPresented: $isShowingScanner) {
      CodeScannerView(codeTypes: [.qr], simulatedData: "1QCXT", completion: self.handleScan)
    }
    /*}*/.navigate(to: UserController(isInRoom: $isInRoom, roomName: roomName, roomDescription: roomDescription, roomCapacity: roomCapacity, songsPerUser: songsPerUser), when: $joined).onAppear(perform: {sharedSpotify.pause()}).navigationViewStyle(StackNavigationViewStyle())
  }
  
  func handleScan(result: Result<String, CodeScannerView.ScanError>) {
    self.isShowingScanner = false
    // Handle the scan
    
    switch result {
    case .success(let code):
      join(c: code)
    case .failure(let error):
      print("Scanning failed")
    }
    
  }
}

/*struct JoinRoomView_Previews: PreviewProvider {
 static var previews: some View {
 JoinRoomView()
 }
 }*/

struct JoinRoomView_PreviewContainer: View {
  
  @State var isInRoom = false
  //@State var spotify: Spotify = Spotify()
  
  var body: some View {
    JoinRoomView(isInRoom: $isInRoom)
  }
}


struct JoinRoomView_Previews: PreviewProvider {
  static var previews: some View {
    
    JoinRoomView_PreviewContainer()
  }
}
