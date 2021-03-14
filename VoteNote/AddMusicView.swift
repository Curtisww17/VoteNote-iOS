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
  func addMusic(){
    
    //set the first song if nothing is playing
    if nowPlaying == nil && selectedSongs.count > 0 {
      print("Song Added")
      nowPlaying = selectedSongs[0]
      sharedSpotify.enqueue(songID: selectedSongs[0].id)
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
      sharedSpotify.skip() //need to clear out queue still before playing, clears out one song for now
      sharedSpotify.pause()
      selectedSongs.remove(at: 0)
    }
    
    for i in selectedSongs {
        print("Added")
        addsong(id: i.id)
        print("Done")
    }
    
    selectedSongs.removeAll()
    
    self.presentationMode.wrappedValue.dismiss()
  }
  
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
            
            Button(action: {addMusic()}) {
              Text("Add Songs")
            }
            .padding(.trailing)
          }
          
          List {
            //list of search results
            //TO-DO: have a function to print all artist names
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
        
        selectedSongs.removeAll()
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
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
                        
                        Button(action: {addMusic()}) {
                            Text("Add Songs")
                        }
                        .padding(.trailing)
                    }
                    
                    List {
                        
                        if( currentSearch == ""){
                            NavigationLink(destination: playListView(myPlaylists: sharedSpotify.userPlaylists?.items ?? [Playlist(id: "")])) {
                                   Text("View My Playlists")
                               }
                            /*NavigationLink(destination: likedSongsView()){
                                Text("Liked Songs")
                            }*/
                               /*.onTapGesture {
                                print("~~~~")
                                sharedSpotify.userPlaylists(completion: {playlist in sharedSpotify.userPlaylists = playlist}, limit: "3")
                               }*/
                               
                        }
                        
                        //list of search results
                        //TO-DO: have a function to print all artist names
                        if currentSearch != "" {
                            ForEach((sharedSpotify.recentSearch?.tracks?.items ?? [songStub(artists: [artistStub(href: "", id: "", name: "", type: "", uri: "")], available_markets: nil, disc_number: 0, duration_ms: 0, explicit: false, href: "", id: "", is_local: false, name: "Searching...", popularity: 0, preview_url: "", track_number: 0, type: "", uri: "")])) { song in
                                SearchEntry(songTitle: song.name, songArtist: (song.artists?[0].name)!, songID: song.id)
                            }
                        }
                    }
                }
                
            }
        }.navigationBarHidden(true).onAppear(perform: {
            selectedSongs.removeAll()
        }).navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: {
            sharedSpotify.userPlaylists(completion: {playlist in sharedSpotify.userPlaylists = playlist}, limit: "10")
        })
    }
}

struct playListView: View {
    @State var myPlaylists: [Playlist]
    
    var body: some View {
        ZStack{
            VStack{
                List{
                    ForEach(((sharedSpotify.userPlaylists?.items ?? [Playlist(collaborative: false, description: "", id: "", images: nil, name: "", type: "", uri: "")]))) { list in
                        NavigationLink(destination: uniquePlaylistView( playlistInfo: list)) {
                            Text(playlistEntry(playlistName: list.name!, playlistID: list.id, playlistDesc: list.description!).playlistName)
                        }
                        //myPlaylist: sharedSpotify.currentPlaylist ?? uniquePlaylist(id: "" ),
                        
                        
                    }
                    
                    //[playlistStub(items: [Playlist(collaborative: false, description: "", id: "", images: nil, name: "", type: "", uri: "")])]
                }
            }
        }

    }
}

struct likedSongsView: View{
    
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    func addMusic(){
        
        //select the first song if nothing is playing
        if nowPlaying == nil && selectedSongs.count > 0 {
            print("Song Added")
            nowPlaying = selectedSongs[0]
            sharedSpotify.enqueue(songID: selectedSongs[0].id)
            selectedSongs.remove(at: 0)
        }
        
        for i in selectedSongs {
            print("Added")
            addsong(id: i.id) //there's an issue here
            print("Done")
        }
        
        selectedSongs.removeAll()
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View{
        ZStack{
            VStack{
                HStack {
                    
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
                    
                    Button(action: {addMusic()}) {
                        Text("Add Songs")
                    }
                    .padding(.trailing)
                }
                
                List{
                    ForEach((sharedSpotify.currentPlaylist?.tracks?.items ?? [songTimeAdded(track: songStub(id: "", name: ""))]), id: \.track.id){ songs in
                        SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name) ?? "", songID: songs.track.id)
                    }
                }
            }
        }.onAppear(perform: {
            
            sharedSpotify.savedSongs(completion: {playlistSongs in sharedSpotify.currentPlaylist = playlistSongs})
        })
    }
}

struct uniquePlaylistView: View{
    
    //@State var myPlaylist: uniquePlaylist
    @State var playlistInfo: Playlist
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    func addMusic(){
        
        //select the first song if nothing is playing
        if nowPlaying == nil && selectedSongs.count > 0 {
            print("Song Added")
            nowPlaying = selectedSongs[0]
            sharedSpotify.enqueue(songID: selectedSongs[0].id)
            selectedSongs.remove(at: 0)
        }
        
        for i in selectedSongs {
            print("Added")
            addsong(id: i.id) //there's an issue here
            print("Done")
        }
        
        selectedSongs.removeAll()
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View{
        ZStack{
            VStack{
                HStack {
                    
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
                    
                    Button(action: {addMusic()}) {
                        Text("Add Songs")
                    }
                    .padding(.trailing)
                }
                
                List{
                    ForEach((sharedSpotify.currentPlaylist?.tracks?.items ?? [songTimeAdded(track: songStub(id: "", name: ""))]), id: \.track.id){ songs in
                        SearchEntry(songTitle: songs.track.name, songArtist: (songs.track.artists?[0].name) ?? "", songID: songs.track.id)
                    }
                }
            }
        }.onAppear(perform: {
            
            sharedSpotify.playlistSongs(completion: {playlistSongs in sharedSpotify.currentPlaylist = playlistSongs}, id: playlistInfo.id)
        })
    }
}

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
                print("Selected Song. Currently Selected this many songs: \(selectedSongs.count)")
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
