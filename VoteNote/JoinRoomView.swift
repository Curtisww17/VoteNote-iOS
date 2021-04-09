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
  
  @ObservedObject var code = TextBindingManager(limit: 5)
  @State var joined = false
  @State private var isShowingScanner = false
  
  @State var roomName: String = ""
  @State var roomDescription: String = ""
  @State var roomCapacity: Int = 0
  @State var songsPerUser: Int = 0
  @State private var isShowingJoinAlert = false
  @State var votingEnabled: Bool = true
  @State var explicitSongsAllowed: Bool = false
  @State var anonUsr: Bool = false
  @State var prevJoinedRooms: [String] = []
  @State var showingAlert = false
  @State var alertMsg = ""
  
  func join(c: String) {
    joinRoom(code: c){ (ret, message) in
      if message != nil {
        alertMsg = message!
        showingAlert = true
      }else{
        storePrevRoom(code: c)
        self.joined = true
        if ret != nil {
          roomName = ret!.name
          roomDescription = (ret?.desc)!
          roomCapacity = ret!.capacity
          songsPerUser = ret!.spu
          votingEnabled = ret!.voting
          explicitSongsAllowed = ret!.explicit
          anonUsr = ret!.anonUsr
          //songsPerUser = ret. //not in db room object
          self.joined = true        }
      }
    }
  }
  
  
  var body: some View {
    Form {
      Section() {
        HStack {
          Image(systemName: "qrcode")
            .foregroundColor(.accentColor)
          Text("Join with QR Code")
          Spacer()
          Image(systemName: "chevron.forward")
            .frame(alignment: .trailing)
        }
        .frame(height: 60)
        .onTapGesture {
          self.isShowingScanner = true
        }
        HStack {
          Image(systemName: "textformat")
            .foregroundColor(.accentColor)
          Text("Join with Room Code")
          Spacer()
          Image(systemName: "chevron.forward")
            .frame(alignment: .trailing)
        }
        .frame(height: 60)
        .onTapGesture(perform: {
          isShowingJoinAlert.toggle()
        })
        if (isShowingJoinAlert) {
          TextField("Room Code", text: $code.text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          if code.text.count == 5 {
            Button(action: {
              join(c: code.text)
            }, label: {
              Text("Join")
            })
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 60, alignment: .center)
          }
        }
      }
      // Not implemented yet
       if (prevJoinedRooms.count > 0) {
       Section() {
       NavigationLink(
        destination: PreviouslyJoinedRoomsView(codes: prevJoinedRooms, isInRoom: $isInRoom).navigationBarHidden(true).navigationBarBackButtonHidden(true),
       label: {
       Text("Previously Joined Rooms")
       })
       }
       }
    }
    .alert(isPresented: $showingAlert) {
      Alert(title: Text("Cannot Join Room"), message: Text(alertMsg), dismissButton: .default(Text("Got it!")))
    }
    .onAppear(perform: {
      getPrevJoinedRooms(completion: {(codes, err) in
        if err != nil {
          print(err as Any)
        } else {
          prevJoinedRooms = codes ?? []
        }
      })
      if sharedSpotify.isJoiningThroughLink.count != 0 {
        join(c: sharedSpotify.isJoiningThroughLink)
      }
      
    })
    .navigationBarHidden(true)
    .sheet(isPresented: $isShowingScanner) {
      CodeScannerView(codeTypes: [.qr], simulatedData: "1QCXT", completion: self.handleScan)
    }
    .navigate(to: UserController(isInRoom: $isInRoom, roomName: roomName, roomDescription: roomDescription, roomCapacity: roomCapacity, songsPerUser: songsPerUser, votingEnabled: votingEnabled, anonUsr: anonUsr, explicitSongsAllowed: explicitSongsAllowed), when: $joined)
    .onAppear(perform: {
      sharedSpotify.pause()
      
    })
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  func handleScan(result: Result<String, CodeScannerView.ScanError>) {
    self.isShowingScanner = false
    // Handle the scan
    
    switch result {
    case .success(let code):
      join(c: code)
    case .failure( _):
      print("Scanning failed")
    }
    
  }
}

struct JoinRoomView_PreviewsContainer: View {
  //@State var spotify: Spotify = Spotify()
  @State var isInRoom = false
  var body: some View {
    JoinRoomView(isInRoom: $isInRoom)
  }
}

struct JoinRoomView_Previews: PreviewProvider {
  static var previews: some View {
    JoinRoomView_PreviewsContainer()
  }
}



