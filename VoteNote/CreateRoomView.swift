//
//  CreateRoomView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI


struct CreateRoomView: View {
    //TODO: Create second version of this view to take in info from an existing room
  @Binding var isInRoom: Bool
  @ObservedObject var spotify: Spotify
    @State var showAlert: Bool = false
    
    @State var userCapacity: Int = 20 {
        didSet {
            if userCapacity < 1 {
                userCapacity = 1
            }
        }
    }
  @State var songsPerUser: Int = 4 {
    didSet {
        if songsPerUser < 1 {
            songsPerUser = 1
        }
    }
  }
    
  @State var roomName: String = ""
  @State var roomDescription: String = ""
    @State var madeRoom: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    func createRoom(){
        //TO-DO- send info to room, songs per user
        print("Room")
        var newRoom: room = room(name: roomName, desc: roomDescription, anonUsr: false, capacity: userCapacity, explicit: false, voting: true)
        makeRoom(newRoom: newRoom)
        madeRoom = true
        self.presentationMode.wrappedValue.dismiss()
    }
    
  var body: some View {
    //return NavigationView {
      ZStack {
        Color.white
        VStack {
            
            Form {
                Section(header: Text("General Room Information")) {
                    TextField("Room Name", text: $roomName)
                    TextField("Room Description", text: $roomDescription)
                }
                
                Section(header: Text("Settings")) {
                    HStack {
                        Text("User Capacity")
                            .padding(.trailing)
                        Stepper("\(userCapacity)", onIncrement: { userCapacity+=1}, onDecrement: { userCapacity-=1})
                            .padding(.leading)
                    }
                    HStack {
                        Text("Songs Per User")
                            .padding(.trailing)
                        Stepper("\(songsPerUser)", onIncrement: { songsPerUser+=1}, onDecrement: { songsPerUser-=1})
                            .padding(.leading)
                    }
                }
            }
            
            if self.roomName != "" {
                Button(action: {createRoom()}) {
                    Text("Create Room")
                        
                }.padding()
            }
          
          Spacer()
        }
      //}
    }.navigationBarHidden(true).navigate(to: HostController(isInRoom: $isInRoom, roomName: roomName, roomDescription: roomDescription), when: $madeRoom).onAppear(perform: {sharedSpotify.pause()}).navigationViewStyle(StackNavigationViewStyle())
  }
}
  
struct CreateRoomView_PreviewContainer: View {
    
  @State var songsPerUser: Int = 4
  @State var userCapacity: Int = 20
  @State var isInRoom = false
  @State var spotify: Spotify = Spotify()

    var body: some View {
        CreateRoomView(isInRoom: $isInRoom, spotify: spotify, userCapacity: userCapacity, songsPerUser: songsPerUser)
    }
}

struct CreateRoomView_Previews: PreviewProvider {
  static var previews: some View {
    
    CreateRoomView_PreviewContainer()
  }
}

//Derived from George_E on Stack Overflow
//Available at: https://stackoverflow.com/questions/56437335/go-to-a-new-view-using-swiftui
extension View {

    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)

                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
    }
}
