//
//  AddMusicView.swift
//  VoteNote
//
//  Created by COMP401 on 2/15/21.
//

import Foundation
import SwiftUI

var selectedSongs: [song] = [song]()

/**
    Displays the UI for adding music
 */
struct AddMusicView: View {
  @State var currentSearch: String = "" { //iOS 13 and earlier uses observer
    didSet {
      if currentSearch != "" {
        sharedSpotify.searchSong(completion: { search in
          sharedSpotify.recentSearch = search
        },Query: currentSearch, limit: "20", offset: "0")
      }
    }
  }
  @State private var isEditing = false
  @State var songsPerUser: Int
  @State var explicitSongsAllowed: Bool
  
  @Environment(\.presentationMode) var presentationMode
    
  
    /**
        Adds the selected songs to the music queue both locally and on the DB
     */

  
    var body: some View {
        //NavigationView {
          ZStack{
            VStack {
              
              HStack {
                TextField("Search Music", text: $currentSearch).onChange(of: self.currentSearch, perform: { value in
                  sharedSpotify.searchSong(completion: { search in
                    sharedSpotify.recentSearch = search
                  },Query: currentSearch, limit: "20", offset: "0")
                })
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                  HStack {
                    Image(systemName: "magnifyingglass")
                      .foregroundColor(.gray)
                      .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                      .padding(.leading, 8)
                    
                    if isEditing {
                      Button(action: {
                        self.currentSearch = ""
                        
                      }) {
                        Image(systemName: "multiply.circle.fill")
                          .foregroundColor(.gray)
                          .padding(.trailing, 8)
                      }
                    }
                  }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                  self.isEditing = true
                }
                
                if isEditing {
                  Button(action: {
                    self.isEditing = false
                    self.currentSearch = ""
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                  }) {
                    Text("Cancel")
                  }
                  .padding(.trailing, 10)
                  .transition(.move(edge: .trailing))
                  .animation(.default)
                }
                
                Button(action: {songQueue.addMusic(songs: selectedSongs)
                  selectedSongs.removeAll()
                  presentationMode.wrappedValue.dismiss()
                }) {
                  Text("Add Songs")
                }
                .padding(.trailing)
              }
              
              List {
                //if you havent searched anything display options to see songs
                if( currentSearch == ""){
                    NavigationLink(destination: playListView(songsPerUser: songsPerUser, myPlaylists: sharedSpotify.userPlaylists?.items ?? [Playlist(id: "")], explicitSongsAllowed: $explicitSongsAllowed).navigationBarTitle("Playlists")) {
                           Text("View My Playlists")
                       }
                    NavigationLink(destination: likedSongsView(songsPerUser: songsPerUser, explicitSongsAllowed: $explicitSongsAllowed).navigationBarTitle("Liked Songs")){
                     Text("Liked Songs")
                     }
                    NavigationLink(destination: recomendedView(songsPerUser: songsPerUser, explicitSongsAllowed: $explicitSongsAllowed).navigationBarTitle("Recommended Songs")){
                        Text("Reccomended")
                    }
                }
                //if you have searched something display search results
                if currentSearch != "" {
                  ForEach((sharedSpotify.recentSearch?.tracks?.items ?? [SpotifyTrack(album: SpotifyAlbum(id: "", images: []), artists: [SpotifyArtist(id: "", name: "", uri: "", type: "")], available_markets: nil, disc_number: 0, duration_ms: 0, explicit: false, href: "", id: "", name: "Searching...", popularity: 0, preview_url: "", track_number: 0, type: "", uri: "")])) { song in
                    if (song.album?.images?.count ?? 0 > 0) {
                        if (!explicitSongsAllowed && !song.explicit!) || explicitSongsAllowed {
                            SearchEntry(songTitle: song.name, songArtist: (song.artists?[0].name)!, songID: song.id, imageURL: (song.album?.images?[0].url) ?? nil, isExplicit: song.explicit!, songsPerUser: songsPerUser)
                        }
                    }
                    else {
                        if (!explicitSongsAllowed && !song.explicit!) || explicitSongsAllowed {
                            SearchEntry(songTitle: song.name, songArtist: (song.artists?[0].name)!, songID: song.id, imageURL: nil, isExplicit: song.explicit!, songsPerUser: songsPerUser)
                        }
                    }
                  }
                }
              }
            }
            
          }.onAppear(perform: {
            sharedSpotify.userPlaylists(completion: {playlist in sharedSpotify.userPlaylists = playlist}, limit: "10")
          selectedSongs.removeAll()
        }).navigationViewStyle(StackNavigationViewStyle())
      }
    
}

//view users locally saved playlists
struct playListView: View {
    @State var songsPerUser: Int
    @State var myPlaylists: [Playlist]
    @Binding var explicitSongsAllowed: Bool
    @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
    @State var searchStr: String = ""
    @State private var isEditing = false
    
    var body: some View {
        ZStack{
            VStack{
                
                TextField("Search Playlists", text: $searchStr).onChange(of: self.searchStr, perform: { value in
                    currentSearch.stringValue = searchStr
                })
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                  HStack {
                    Image(systemName: "magnifyingglass")
                      .foregroundColor(.gray)
                      .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                      .padding(.leading, 8)
                    
                    if isEditing {
                      Button(action: {
                        self.searchStr = ""
                        
                      }) {
                        Image(systemName: "multiply.circle.fill")
                          .foregroundColor(.gray)
                          .padding(.trailing, 8)
                      }
                    }
                  }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                  self.isEditing = true
                }
                
                List{
                    
                    ForEach(((sharedSpotify.userPlaylists?.items ?? [Playlist(description: "", id: "", images: nil, name: "", type: "", uri: "")]))) { list in
                        
                        if (list.name!.contains("\(currentSearch.stringValue)") || currentSearch.stringValue == "") {
                            NavigationLink(destination: uniquePlaylistView( playlistInfo: list, explicitSongsAllowed: $explicitSongsAllowed, songsPerUser: songsPerUser).navigationBarTitle(list.name!)) {
                                Text(playlistEntry(playlistName: list.name!, playlistID: list.id, playlistDesc: list.description!).playlistName)
                            }
                        }
                        //myPlaylist: sharedSpotify.currentPlaylist ?? uniquePlaylist(id: "" ),
                    }
                    //[playlistStub(items: [Playlist(collaborative: false, description: "", id: "", images: nil, name: "", type: "", uri: "")])]
                }
            }
        }
    }
}

//view recommened songs to add to the queue
struct recomendedView: View{
    @State var songsPerUser: Int
    @State private var isEditing = false
    @Binding var explicitSongsAllowed: Bool
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
    @State var searchStr: String = ""
    
    var body: some View{
        ZStack{
            VStack{
                HStack {
                    
                    TextField("Search Playlists", text: $searchStr).onChange(of: self.searchStr, perform: { value in
                        currentSearch.stringValue = searchStr
                    })
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                      HStack {
                        Image(systemName: "magnifyingglass")
                          .foregroundColor(.gray)
                          .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                          .padding(.leading, 8)
                        
                        if isEditing {
                          Button(action: {
                            self.searchStr = ""
                            
                          }) {
                            Image(systemName: "multiply.circle.fill")
                              .foregroundColor(.gray)
                              .padding(.trailing, 8)
                          }
                        }
                      }
                    )
                    .padding(.horizontal, 10)
                    .onTapGesture {
                      self.isEditing = true
                    }
                    
                    if isEditing {
                        Button(action: {
                            self.isEditing = false
                            
                            // Dismiss the keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Text("Cancel")
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                    }
                    
                    Spacer()
                    
                  Button(action: {songQueue.addMusic(songs: selectedSongs)
                    selectedSongs.removeAll()
                    presentationMode.wrappedValue.dismiss()
                  }) {
                        Text("Add Songs")
                    }
                    .padding(.trailing)
                }
                
                List{
                    ForEach((sharedSpotify.recommendedSongs?.tracks ?? [SpotifyTrack(album: nil, id: "", name: "")]), id: \.id){ songs in
                        
                        if (songs.name.contains("\(currentSearch.stringValue)") || currentSearch.stringValue == "") {
                            if (songs.album?.images?.count ?? 0 > 0) {
                                if (!explicitSongsAllowed && !songs.explicit!) || explicitSongsAllowed {
                                    SearchEntry(songTitle: songs.name, songArtist: (songs.artists?[0].name)!, songID: songs.id, imageURL: (songs.album?.images?[0].url) ?? nil, isExplicit: songs.explicit!, songsPerUser: songsPerUser)
                                }
                            }
                            else {
                                if (songs.explicit != nil) {
                                    if (!explicitSongsAllowed && !songs.explicit!) || explicitSongsAllowed {
                                        SearchEntry(songTitle: songs.name, songArtist: (songs.artists?[0].name)!, songID: songs.id, imageURL: nil, isExplicit: songs.explicit!, songsPerUser: songsPerUser)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear(perform: {
            
            sharedSpotify.recomendations(artistSeed: "4NHQUGzhtTLFvgF5SZesLK", genre: "classical", trackSeed: "0c6xIDDpzE81m2q797ordA",completion: {playlistSongs in sharedSpotify.recommendedSongs = playlistSongs})
        })
    }
    
}

//view songs (spotify) liked by the user to add them to the queue
struct likedSongsView: View{
    
    @State var songsPerUser: Int
    @State private var isEditing = false
    @Binding var explicitSongsAllowed: Bool
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
    @State var searchStr: String = ""
    
    var body: some View{
        ZStack{
            VStack{
                HStack {
                    
                    TextField("Search Playlists", text: $searchStr).onChange(of: self.searchStr, perform: { value in
                        currentSearch.stringValue = searchStr
                    })
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                      HStack {
                        Image(systemName: "magnifyingglass")
                          .foregroundColor(.gray)
                          .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                          .padding(.leading, 8)
                        
                        if isEditing {
                          Button(action: {
                            self.searchStr = ""
                            
                          }) {
                            Image(systemName: "multiply.circle.fill")
                              .foregroundColor(.gray)
                              .padding(.trailing, 8)
                          }
                        }
                      }
                    )
                    .padding(.horizontal, 10)
                    .onTapGesture {
                      self.isEditing = true
                    }
                    
                    if isEditing {
                        Button(action: {
                            self.isEditing = false
                            
                            // Dismiss the keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Text("Cancel")
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                    }
                    
                    Spacer()
                    
                  Button(action: {songQueue.addMusic(songs: selectedSongs)
                    selectedSongs.removeAll()
                    presentationMode.wrappedValue.dismiss()
                  }) {
                        Text("Add Songs")
                    }
                    .padding(.trailing)
                }
                
                List{
                    ForEach((sharedSpotify.usersSavedSongs?.items ?? [songTimeAdded(track: SpotifyTrack(album: nil, id: "", name: ""))]), id: \.track.id){ songs in
                        
                        if (songs.track.name.contains("\(currentSearch.stringValue)") || currentSearch.stringValue == "") {
                            if (songs.track.album?.images?.count ?? 0 > 0) {
                                if (!explicitSongsAllowed && !songs.track.explicit!) || explicitSongsAllowed {
                                    SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name)!, songID: songs.track.id, imageURL: (songs.track.album?.images?[0].url) ?? nil, isExplicit: songs.track.explicit!, songsPerUser: songsPerUser)
                                }
                            }
                            else {
                                if (songs.track.explicit != nil) {
                                    if (!explicitSongsAllowed && !songs.track.explicit!) || explicitSongsAllowed {
                                        SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name)!, songID: songs.track.id, imageURL: nil, isExplicit: songs.track.explicit!, songsPerUser: songsPerUser)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear(perform: {
            
            sharedSpotify.savedSongs(completion: {playlistSongs in sharedSpotify.usersSavedSongs = playlistSongs})
        })
    }
}

//view songs in a playlist to add to a queue
struct uniquePlaylistView: View{
    
    //@State var myPlaylist: uniquePlaylist
    @State var playlistInfo: Playlist
    @State private var isEditing = false
    @Binding var explicitSongsAllowed: Bool
    @Environment(\.presentationMode) var presentationMode
    @State var songsPerUser: Int
    @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
    @State var searchStr: String = ""
  
    
    var body: some View{
        ZStack{
            VStack{
                HStack {
                    
                    TextField("Search Playlists", text: $searchStr).onChange(of: self.searchStr, perform: { value in
                        currentSearch.stringValue = searchStr
                    })
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                      HStack {
                        Image(systemName: "magnifyingglass")
                          .foregroundColor(.gray)
                          .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                          .padding(.leading, 8)
                        
                        if isEditing {
                          Button(action: {
                            self.searchStr = ""
                            
                          }) {
                            Image(systemName: "multiply.circle.fill")
                              .foregroundColor(.gray)
                              .padding(.trailing, 8)
                          }
                        }
                      }
                    )
                    .padding(.horizontal, 10)
                    .onTapGesture {
                      self.isEditing = true
                    }
                    
                    if isEditing {
                        Button(action: {
                            self.isEditing = false
                            
                            // Dismiss the keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Text("Cancel")
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                    }
                    
                    Spacer()
                    
                  Button(action: {songQueue.addMusic(songs: selectedSongs)
                    selectedSongs.removeAll()
                    presentationMode.wrappedValue.dismiss()
                  }) {
                        Text("Add Songs")
                    }
                    .padding(.trailing)
                }
                
                List{
                    ForEach((sharedSpotify.currentPlaylist?.tracks?.items ?? [songTimeAdded(track: SpotifyTrack(album: nil, id: "", name: ""))]), id: \.track.id){ songs in
                        
                        if (songs.track.name.contains("\(currentSearch.stringValue)") || currentSearch.stringValue == "") {
                            if (songs.track.album?.images?.count ?? 0 > 0) {
                                if (!explicitSongsAllowed && !songs.track.explicit!) || explicitSongsAllowed {
                                    SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name)!, songID: songs.track.id, imageURL: (songs.track.album?.images?[0].url) ?? nil, isExplicit: songs.track.explicit!, songsPerUser: songsPerUser)
                                }
                            }
                            else {
                                if (songs.track.explicit != nil) {
                                    if (!explicitSongsAllowed && !songs.track.explicit!) || explicitSongsAllowed {
                                        SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name)!, songID: songs.track.id, imageURL: nil, isExplicit: songs.track.explicit!, songsPerUser: songsPerUser)
                                    }
                                }
                            }
                        }
                    }
                }
            }.onAppear(perform: {
            sharedSpotify.playlistSongs(completion: {playlistSongs in sharedSpotify.currentPlaylist = playlistSongs}, id: playlistInfo.id)
            })
        }
    }
}

//formatting for displaying songs in user playlists
struct playlistEntry: View{
    
    @State var playlistName: String
    @State var playlistID: String
    @State var playlistDesc: String
    
    
    func selectPlaylist(){
        print(playlistID)
    }
    var body: some View {
        ZStack{
            Button(action: {selectPlaylist()}) {
                HStack {
                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 35.0, height: 35.0)
                    VStack {
                        HStack {
                            Text(playlistName)
                            Spacer()
                        }
                        
                        HStack {
                            Text(playlistDesc)
                                .font(.caption)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    /*if !selectedSong {
                        Image(systemName: "plus.circle")
                            .padding(.trailing)
                    } else {
                        Image(systemName: "checkmark")
                            .padding(.trailing)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }*/
                }
            }
            
        }
    }
    
}

/**
    The UI template for a single search entry when searching for music
 */
struct SearchEntry: View {
  @State var selectedSong: Bool = false
  
  @State var songTitle: String
  @State var songArtist: String
  @State var songID: String
  
  @State var addedBy: String = ""
  @State var genres: [String] = ["Placeholder"]
  @State var length: Int = 0
  @State var numVotes: Int? = 0
  @State var imageURL: String?
  @State var isExplicit: Bool
  @State var songsPerUser: Int
    
  @State var hasHitMaxSongs: Bool = false
  
  func selectSong() {
    if songTitle != "Searching..." {
        selectedSong = !selectedSong
        if selectedSong {
            
            var numAdded: Int = 0
            getQueue(){(songs, err) in
                if songs != nil {
                    for x in songs! {
                        if x.addedBy == getUID() {
                            numAdded = numAdded + 1
                        }
                    }
                }
            }
            numAdded = numAdded + selectedSongs.count
            
            if numAdded >= songsPerUser {
                hasHitMaxSongs = true
            }
            
            if numAdded < songsPerUser {
                selectedSongs.append(song(addedBy: self.addedBy, artist: self.songArtist, genres: self.genres, id: self.songID, length: self.length, numVotes: self.numVotes, title: self.songTitle, imageUrl: self.imageURL ?? ""))
            } else {
                selectedSong = false
            }
        } else {
          var songIndex: Int = 0
          while songIndex < selectedSongs.count {
            if selectedSongs[songIndex].id == songID
            {
              selectedSongs.remove(at: songIndex)
            }
            songIndex = songIndex + 1
          }
        }
    }
  }
  
  var body: some View {
    ZStack{
      Button(action: {selectSong()}) {
        HStack {
          if imageURL != nil {
            RemoteImage(url: self.imageURL!)
              .frame(width: 40, height: 40)
          } else {
            Image(systemName: "person.crop.square.fill").resizable().frame(width: 35.0, height: 35.0)
          }
          VStack {
            HStack {
              Text(songTitle)
              Spacer()
            }
            
            HStack {
              Text(songArtist)
                .font(.caption)
                .foregroundColor(Color.gray)
              Spacer()
            }
          }
          
          Spacer()
            if songTitle != "Searching..." {
                if !selectedSong {
                  Image(systemName: "plus.circle")
                    .padding(.trailing)
                } else {
                  Image(systemName: "checkmark")
                    .padding(.trailing)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
            }
        }
      }
      
    }.onAppear(perform: {
        hasHitMaxSongs = false
    }).alert(isPresented: $hasHitMaxSongs) {
        Alert(title: Text("Limit Reached"), message: Text("You have reached your maximum number of songs added to the queue."), dismissButton: .default(Text("Ok")))
    }
  }
}

/*struct AddMusicView_PreviewsContainer: View {
  //@State var spotify: Spotify = Spotify()
  
  var body: some View {
    AddMusicView(songsPerUser: 5, explicitSongsAllowed: false)
  }
}

struct AddMusicView_Previews: PreviewProvider {
  static var previews: some View {
    AddMusicView_PreviewsContainer()
  }
}*/

