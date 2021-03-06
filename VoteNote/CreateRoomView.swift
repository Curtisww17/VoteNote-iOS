//
//  CreateRoomView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

/**
    The UI view for the Create Room View
 */
struct CreateRoomView: View {
  @Binding var isInRoom: Bool
  @ObservedObject var spotify: Spotify
  @State var showAlert: Bool = false
  
  @State var userCapacity: Int = 20 {
    didSet {
      if userCapacity < 1 {
        userCapacity = 1
      } else if userCapacity > 50 {
        userCapacity = 50
      }
    }
  }
  @State var songsPerUser: Int = 4 {
    didSet {
      if songsPerUser < 1 {
        songsPerUser = 1
      } else if songsPerUser > 10 {
        songsPerUser = 10
      }
    }
  }
  
  @ObservedObject var roomName = TextBindingManager(limit: 20)
  @ObservedObject var roomDescription = TextBindingManager(limit: 20)
  @State var votingEnabled: Bool = true
  @State var madeRoom: Bool = false
  @State var anonUsr: Bool = false
  @State var explicitSongsAllowed: Bool = false
  @State var prevHostedRooms: [String] = []
  @State var genres: Set<String> = []
  @State var showingAlert = false
  @State var alertMsg = ""
  @State var autoLike: Bool = false
  
  @Environment(\.presentationMode) var presentationMode
  
    /**
        Creates a new Room in the DB and saves the settings locally
     */
  func createRoom(){
    if (sharedSpotify.currentUser?.product ?? "" == "premium") {
      let newRoom: room = room(name: roomName.text, desc: roomDescription.text, anonUsr: anonUsr, capacity: userCapacity, explicit: explicitSongsAllowed, voting: votingEnabled, spu: songsPerUser, genres: Array(genres), currSong: (sharedSpotify.currentlyPlaying?.id ?? "6sFIWsNpZYqfjUpaCgueju"))
      let newcode = makeRoom(newRoom: newRoom)
      storePrevRoom(code: newcode)
      madeRoom = true
      
      RoomName = roomName.text
      RoomDescription = roomDescription.text
      VotingEnabled = votingEnabled
      AnonUsr = anonUsr
      RoomCapacity = userCapacity
      SongsPerUser = songsPerUser
      ExplicitSongsAllowed = explicitSongsAllowed
        
    } else {
      alertMsg = "Must be a premium member to host a room"
      showingAlert = true
    }
  }
  
  var body: some View {
    ZStack {
      Color.white
      VStack {
        
        Form {
          Section(header: Text("General Room Information")) {
            TextField("Room Name", text: $roomName.text)
            TextField("Room Description", text: $roomDescription.text)
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
            
            HStack{
                NavigationLink(
                    destination: playListBaseView(songsPerUser: songsPerUser, myPlaylists: sharedSpotify.userPlaylists?.items ?? [Playlist(id: "")])
                    .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                  label: {
                    Text("Base Room Off Playlist")
                  }).onAppear(perform: {
                    sharedSpotify.userPlaylists(completion: {playlist in sharedSpotify.userPlaylists = playlist}, limit: "10")
                  })
            }
            
            HStack{
                NavigationLink(
                    destination: GenreSelectView(genres: $genres)
                    .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                  label: {
                    Text("Genres Allowed")
                  })
            }
            
            HStack {
              Text("Explicit Songs Allowed")
              
              Toggle(isOn: $explicitSongsAllowed) {
                Text("")
              }
            }
            .padding(.trailing)
            
            HStack {
              Text("Anonymous Users")
              Toggle(isOn: $anonUsr) {
                Text("")
              }
            }
            .padding(.trailing)
            
            HStack {
              Text("Voting Enabled")
              Toggle(isOn: $votingEnabled) {
                Text("")
              }
            }
            .padding(.trailing)
          }
          
          if (prevHostedRooms.count > 0) {
            Section() {
              NavigationLink(
                destination: PreviouslyHostedRoomsView(codes: prevHostedRooms, isInRoom: $isInRoom)
                  .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                label: {
                  Text("Previously Hosted Rooms")
                })
            }
          }
        }
        
        if self.roomName.text != "" {
          Button(action: {createRoom()}) {
            Text("Create Room")
            
          }.padding()
        }
        
        Spacer()
      }
    }
    .navigationBarHidden(true)
    .navigate(to: HostController(isInRoom: $isInRoom, genres: Array(genres)), when: $madeRoom)
    .alert(isPresented: $showingAlert) {
      Alert(title: Text("Cannot Create Room"), message: Text(alertMsg), dismissButton: .default(Text("Got it!")))
    }
    .onAppear(perform: {
      (sharedSpotify.genreList?.genres ?? []).forEach {genre in
        genres.insert(genre)
      }
      getPrevHostedRooms(completion: {(codes, err) in
        if err != nil {
          print(err as Any)
        } else {
          prevHostedRooms = codes ?? []
        }
      })
    }).navigationViewStyle(StackNavigationViewStyle())
  }
}

class TextBindingManager: ObservableObject {
    @Published var text = "" {
        didSet {
            if text.count > characterLimit && oldValue.count <= characterLimit {
                text = oldValue
            }
        }
    }
    let characterLimit: Int
    
    init(limit: Int = 20) {
        characterLimit = limit
    }
    
    init(limit: Int = 20, text: String) {
        characterLimit = limit
        self.text = text
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

/**
    The UI view for chossing a rooms base playlist
 */
struct playListBaseView: View {
    @State var songsPerUser: Int
    @State var myPlaylists: [Playlist]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            VStack{
                HStack {
                  Button(action: {
                    presentationMode.wrappedValue.dismiss()
                  }, label: {
                      HStack {
                          Image(systemName: "chevron.left").resizable().frame(width: 12.5, height: 18.5)
                          Text("Back").font(.body)
                      }
                  })
                  .frame(alignment: .leading)
                  Spacer()
                }
                .padding(.leading)
                Form {
                    List{
                        ForEach(((sharedSpotify.userPlaylists?.items ?? [Playlist(description: "", id: "", images: nil, name: "", type: "", uri: "")]))) { list in
                            Button(list.name ?? "") {
                                sharedSpotify.playlistSongs(completion: {playlistSongs in sharedSpotify.PlaylistBase = playlistSongs}, id: list.id)
                                self.presentationMode.wrappedValue.dismiss()
                            }.foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                        }
                    }
                }
            }
        }
    }
}
