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
        },Query: currentSearch, limit: "30", offset: "0")
      }
    }
  }
    
  @State private var isEditing = false
  @State var genres: [String]
  @State var hasSelectedSongs: Bool = false
  
  @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
          VStack {
            
            HStack {
              TextField("Search Music", text: $currentSearch).onChange(of: self.currentSearch, perform: { value in
                sharedSpotify.searchSong(completion: { search in
                  sharedSpotify.recentSearch = search
                  
                  print("Starting Len: \(sharedSpotify.recentSearch?.tracks?.items?.count)")
                  
                  //filtering for allowed genres
                  if (genres.count != 126 && genres.count != 0) {
                      var count = 0
                      
                      if (sharedSpotify.recentSearch?.tracks?.items! != nil) {
                          while (count < (sharedSpotify.recentSearch?.tracks?.items!.count)!) {
                              var found = false
                              
                              sharedSpotify.getSongGenre(artistID: (sharedSpotify.recentSearch?.tracks?.items![count].artists![0].id)!, completion: { currentGenres in
                                  sharedSpotify.songGenres = currentGenres
                              })
                              
                              genres.forEach { currentGenre in
                                  
                                  sharedSpotify.songGenres?.artists[0].genres?.forEach { curGenre in
                                      
                                      if (currentGenre.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == curGenre.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) {
                                          found = true
                                          print("Did match")
                                      }
                                  }
                              }
                              
                              if (!found) {
                                  sharedSpotify.recentSearch?.tracks?.items!.remove(at: count)
                              } else {
                                  count = count + 1
                              }
                          }
                      }
                  }
                  
                  print("Ending Len: \(sharedSpotify.recentSearch?.tracks?.items?.count)")
                  
                },Query: currentSearch, limit: "30", offset: "0")
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
              
              Button(action: {if selectedSongs.count > 0 {
                  songQueue.addMusic(songs: selectedSongs)
                    selectedSongs.removeAll()
                    presentationMode.wrappedValue.dismiss()
              }
              }) {
                  Text("Add Songs").foregroundColor(hasSelectedSongs ? .blue : .gray)
              }
              .padding(.trailing).disabled(!hasSelectedSongs)
            }
            
            List {
              //if you havent searched anything display options to see songs
              if( currentSearch == ""){
                  NavigationLink(destination: playListView(myPlaylists: sharedSpotify.userPlaylists?.items ?? [Playlist(id: "")], genres: genres).navigationBarTitle("Playlists")) {
                         Text("View My Playlists")
                     }
                  NavigationLink(destination: likedSongsView(genres: genres).navigationBarTitle("Liked Songs")){
                   Text("Liked Songs")
                   }
                  NavigationLink(destination: recomendedView(genres: genres).navigationBarTitle("Recommended Songs")){
                      Text("Recommended")
                  }
              }
              //if you have searched something display search results
              if currentSearch != "" {
                ForEach((sharedSpotify.recentSearch?.tracks?.items ?? [SpotifyTrack(album: SpotifyAlbum(id: "", images: []), artists: [SpotifyArtist(id: "", name: "", uri: "", type: "")], available_markets: nil, disc_number: 0, duration_ms: 0, explicit: false, href: "", id: "", name: "Searching...", popularity: 0, preview_url: "", track_number: 0, type: "", uri: "")])) { song in
                  
                  if (song.album?.images?.count ?? 0 > 0) {
                      if (!ExplicitSongsAllowed && !song.explicit!) || ExplicitSongsAllowed {
                          SearchEntry(songTitle: song.name, songArtist: (song.artists?[0].name)!, songID: song.id, imageURL: (song.album?.images?[0].url) ?? nil, isExplicit: song.explicit!, hasSelectedSongs: $hasSelectedSongs)
                      }
                  }
                  else {
                      if (!ExplicitSongsAllowed && !song.explicit!) || ExplicitSongsAllowed {
                          SearchEntry(songTitle: song.name, songArtist: (song.artists?[0].name)!, songID: song.id, imageURL: nil, isExplicit: song.explicit!, hasSelectedSongs: $hasSelectedSongs)
                      }
                  }
                }
              }
            }
          }
          
        }.onAppear(perform: {
          sharedSpotify.userPlaylists(completion: {playlist in sharedSpotify.userPlaylists = playlist}, limit: "10")
        selectedSongs.removeAll()
        }).onDisappear(perform: {
          songQueue.updateQueue()
          
          
          
        }).navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
        Button(action : {
            selectedSongs.removeAll()
            self.presentationMode.wrappedValue.dismiss()
        }){
          HStack {
              Image(systemName: "chevron.left").resizable().frame(width: 12.5, height: 18.5)
              Text("Cancel").font(.body)
          }
    }).navigationViewStyle(StackNavigationViewStyle())
    }
}

/**
    View for users locally saved playlists
 */
struct playListView: View {
    @State var myPlaylists: [Playlist]
    @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
    @State var searchStr: String = ""
    @State private var isEditing = false
    @State var genres: [String]
    
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
                        
                        if (list.name!.lowercased().contains("\(currentSearch.stringValue.lowercased())") || currentSearch.stringValue == "") {
                            NavigationLink(destination: uniquePlaylistView( playlistInfo: list, genres: genres).navigationBarTitle(list.name!)) {
                                Text(playlistEntry(playlistName: list.name!, playlistID: list.id, playlistDesc: list.description!).playlistName)
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
    View for recommened songs to add to the queue
 */
struct recomendedView: View{
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
    @State var searchStr: String = ""
    @State var genres: [String]
    @State var hasSelectedSongs: Bool = false
    
    var body: some View{
        ZStack{
            VStack{
                HStack {
                    
                    TextField("Search Songs", text: $searchStr).onChange(of: self.searchStr, perform: { value in
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
                    
                    Button(action: { if selectedSongs.count > 0 {
                        songQueue.addMusic(songs: selectedSongs)
                        selectedSongs.removeAll()
                        presentationMode.wrappedValue.dismiss()
                    }
                  }) {
                        Text("Add Songs").foregroundColor(hasSelectedSongs ? .blue : .gray)
                    }
                    .padding(.trailing).disabled(!hasSelectedSongs)
                }
                
                List{
                    ForEach((sharedSpotify.recommendedSongs?.tracks ?? [SpotifyTrack(album: nil, id: "", name: "")]), id: \.id){ songs in
                        
                        if (songs.name.lowercased().contains("\(currentSearch.stringValue.lowercased())") || currentSearch.stringValue == "") {
                            if (songs.album?.images?.count ?? 0 > 0) {
                                if (!ExplicitSongsAllowed && !songs.explicit!) || ExplicitSongsAllowed {
                                    SearchEntry(songTitle: songs.name, songArtist: (songs.artists?[0].name)!, songID: songs.id, imageURL: (songs.album?.images?[0].url) ?? nil, isExplicit: songs.explicit!, hasSelectedSongs: $hasSelectedSongs)
                                }
                            }
                            else {
                                if (songs.explicit != nil) {
                                    if (!ExplicitSongsAllowed && !songs.explicit!) || ExplicitSongsAllowed {
                                        SearchEntry(songTitle: songs.name, songArtist: (songs.artists?[0].name)!, songID: songs.id, imageURL: nil, isExplicit: songs.explicit!, hasSelectedSongs: $hasSelectedSongs)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear(perform: {
            selectedSongs.removeAll()

            sharedSpotify.recomendations(artistSeed: sharedSpotify.currentlyPlaying?.artists?[0].id ?? "4NHQUGzhtTLFvgF5SZesLK", trackSeed: sharedSpotify.currentlyPlaying?.id ?? "0c6xIDDpzE81m2q797ordA",completion: {playlistSongs in sharedSpotify.recommendedSongs = playlistSongs})
            
            print("Starting Len: \(sharedSpotify.recommendedSongs?.tracks.count)")
            
            //filtering for allowed genres
            if (genres.count != 126 && genres.count != 0) {
                var count = 0
                
                if (sharedSpotify.recommendedSongs?.tracks != nil) {
                    while (count < (sharedSpotify.recommendedSongs?.tracks.count)!) {
                        var found = false
                        
                        sharedSpotify.getSongGenre(artistID: (sharedSpotify.recommendedSongs?.tracks[count].artists![0].id)!, completion: { currentGenres in
                            sharedSpotify.songGenres = currentGenres
                        })
                        
                        genres.forEach { currentGenre in
                            
                            sharedSpotify.songGenres?.artists[0].genres?.forEach { curGenre in
                                
                                if (currentGenre.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == curGenre.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) {
                                    found = true
                                    print("Did match")
                                }
                            }
                        }
                        
                        if (!found) {
                            sharedSpotify.recommendedSongs?.tracks.remove(at: count)
                        } else {
                            count = count + 1
                        }
                    }
                }
            }
            
            print("Ending Len: \(sharedSpotify.recommendedSongs?.tracks.count)")
        }).navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
        Button(action : {
            selectedSongs.removeAll()
            self.presentationMode.wrappedValue.dismiss()
        }){
          HStack {
              Image(systemName: "chevron.left").resizable().frame(width: 12.5, height: 18.5)
              Text("Cancel").font(.body)
          }
        })
    }
}

/**
    View for songs (spotify) liked by the user to add them to the queue
 */
struct likedSongsView: View{
    
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
    @State var searchStr: String = ""
    @State var genres: [String]
    @State var hasSelectedSongs: Bool = false
    
    var body: some View{
        ZStack{
            VStack{
                HStack {
                    
                    TextField("Search Songs", text: $searchStr).onChange(of: self.searchStr, perform: { value in
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
                    
                    Button(action: { if selectedSongs.count > 0 {
                        songQueue.addMusic(songs: selectedSongs)
                        selectedSongs.removeAll()
                        presentationMode.wrappedValue.dismiss()
                    }
                  }) {
                        Text("Add Songs").foregroundColor(hasSelectedSongs ? .blue : .gray)
                    }
                    .padding(.trailing).disabled(!hasSelectedSongs)
                }
                
                List{
                    ForEach((sharedSpotify.usersSavedSongs?.items ?? [songTimeAdded(track: SpotifyTrack(album: nil, id: "", name: ""))]), id: \.track.id){ songs in
                        
                        if (songs.track.name.lowercased().contains("\(currentSearch.stringValue.lowercased())") || currentSearch.stringValue == "") {
                            if (songs.track.album?.images?.count ?? 0 > 0) {
                                if (!ExplicitSongsAllowed && !songs.track.explicit!) || ExplicitSongsAllowed {
                                    SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name)!, songID: songs.track.id, imageURL: (songs.track.album?.images?[0].url) ?? nil, isExplicit: songs.track.explicit!, hasSelectedSongs: $hasSelectedSongs)
                                }
                            }
                            else {
                                if (songs.track.explicit != nil) {
                                    if (!ExplicitSongsAllowed && !songs.track.explicit!) || ExplicitSongsAllowed {
                                        SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name)!, songID: songs.track.id, imageURL: nil, isExplicit: songs.track.explicit!, hasSelectedSongs: $hasSelectedSongs)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear(perform: {
            selectedSongs.removeAll()
            
            sharedSpotify.savedSongs(completion: {playlistSongs in sharedSpotify.usersSavedSongs = playlistSongs})
            
            //filtering for allowed genres
            if (genres.count != 126 && genres.count != 0) {
                var count = 0
                
                if (sharedSpotify.usersSavedSongs?.items != nil) {
                    while (count < (sharedSpotify.usersSavedSongs?.items?.count)!) {
                        var found = false
                        
                        sharedSpotify.getSongGenre(artistID: (sharedSpotify.usersSavedSongs?.items![count].track.artists![0].id)!, completion: { currentGenres in
                            sharedSpotify.songGenres = currentGenres
                        })
                        
                        genres.forEach { currentGenre in
                            
                            sharedSpotify.songGenres?.artists[0].genres?.forEach { curGenre in
                                
                                if (currentGenre.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == curGenre.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) {
                                    found = true
                                    print("Did match")
                                }
                            }
                        }
                        
                        if (!found) {
                            sharedSpotify.usersSavedSongs?.items!.remove(at: count)
                        } else {
                            count = count + 1
                        }
                    }
                }
            }
            
            print("Ending Len: \(sharedSpotify.recommendedSongs?.tracks.count)")
        }).navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
        Button(action : {
            selectedSongs.removeAll()
            self.presentationMode.wrappedValue.dismiss()
        }){
          HStack {
              Image(systemName: "chevron.left").resizable().frame(width: 12.5, height: 18.5)
              Text("Cancel").font(.body)
          }
        })
    }
}

/**
    View for songs in a playlist to add to a queue
 */
struct uniquePlaylistView: View{
    
    @State var playlistInfo: Playlist
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
    @State var searchStr: String = ""
    @State var genres: [String]
    @State var hasSelectedSongs: Bool = false
  
    
    var body: some View{
        ZStack{
            VStack{
                HStack {
                    
                    TextField("Search Songs", text: $searchStr).onChange(of: self.searchStr, perform: { value in
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
                    
                    Button(action: { if selectedSongs.count > 0 {
                        songQueue.addMusic(songs: selectedSongs)
                        selectedSongs.removeAll()
                        presentationMode.wrappedValue.dismiss()
                    }
                  }) {
                        Text("Add Songs").foregroundColor(hasSelectedSongs ? .blue : .gray)
                    }
                    .padding(.trailing).disabled(!hasSelectedSongs)
                }
                
                List{
                    ForEach((sharedSpotify.currentPlaylist?.tracks?.items ?? [songTimeAdded(track: SpotifyTrack(album: nil, id: "", name: ""))]), id: \.track.id){ songs in
                        
                        if (songs.track.name.lowercased().contains("\(currentSearch.stringValue.lowercased())") || currentSearch.stringValue == "") {
                            if (songs.track.album?.images?.count ?? 0 > 0) {
                                if (!ExplicitSongsAllowed && !songs.track.explicit!) || ExplicitSongsAllowed {
                                    SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name)!, songID: songs.track.id, imageURL: (songs.track.album?.images?[0].url) ?? nil, isExplicit: songs.track.explicit!, hasSelectedSongs: $hasSelectedSongs)
                                }
                            }
                            else {
                                if (songs.track.explicit != nil) {
                                    if (!ExplicitSongsAllowed && !songs.track.explicit!) || ExplicitSongsAllowed {
                                        SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name)!, songID: songs.track.id, imageURL: nil, isExplicit: songs.track.explicit!, hasSelectedSongs: $hasSelectedSongs)
                                    }
                                }
                            }
                        }
                    }
                }
            }.onAppear(perform: {
                selectedSongs.removeAll()
                
            sharedSpotify.playlistSongs(completion: {playlistSongs in sharedSpotify.currentPlaylist = playlistSongs}, id: playlistInfo.id)
            })
        }.navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
        Button(action : {
            selectedSongs.removeAll()
            self.presentationMode.wrappedValue.dismiss()
        }){
          HStack {
              Image(systemName: "chevron.left").resizable().frame(width: 12.5, height: 18.5)
              Text("Cancel").font(.body)
          }
    })
    }
}

/**
    UI view for formatting songs in user playlists
 */
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
  
  @State var addedBy: String = getUID()
  @State var genres: [String] = ["Placeholder"]
  @State var length: Int = 0
  @State var numVotes: Int? = 0
  @State var imageURL: String?
  @State var isExplicit: Bool
    
  @State var hasHitMaxSongs: Bool = false
  @Binding var hasSelectedSongs: Bool
    
    /**
        Function for selecting a song to add to the Queue from the search list
     */
  func selectSong() {
    hasHitMaxSongs = false
    
    if songTitle != "Searching..." {
        selectedSong = !selectedSong
        if selectedSong {
            
            var numAdded: Int = 0
            for x in songQueue.musicList {
                if x.addedBy == getUID() {
                    numAdded = numAdded + 1
                }
            }
            
            numAdded = numAdded + selectedSongs.count
            print(numAdded)
            print(selectedSongs.count)
            
            if numAdded >= SongsPerUser {
                hasHitMaxSongs = true
            }
            
            if numAdded < SongsPerUser {
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
        
        hasSelectedSongs = selectedSongs.count > 0
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
