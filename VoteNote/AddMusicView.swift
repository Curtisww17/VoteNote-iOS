//
//  AddMusicView.swift
//  VoteNote
//
//  Created by COMP401 on 2/15/21.
//

import Foundation
import SwiftUI

var selectedSongs: [song] = [song]()

struct AddMusicView: View {
    @State var currentSearch: String = "" { //iOS 13 and earlier uses observer
        didSet {
            if currentSearch != " " {
                sharedSpotify.searchSong(completion: { search in
                    sharedSpotify.recentSearch = search
                  },Query: currentSearch + " ", limit: "20", offset: "0")
            }
        }
    }
    @State private var isEditing = false
    //@ObservedObject var spotify = sharedSpotify
    
    @Environment(\.presentationMode) var presentationMode
    
    //TO-DO: Have songs filtered by search
    
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
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    
                    HStack {
                        TextField("Search Music", text: $currentSearch).onChange(of: self.currentSearch, perform: { value in
                            sharedSpotify.searchSong(completion: { search in
                                sharedSpotify.recentSearch = search
                              },Query: currentSearch  + " ", limit: "20", offset: "0")
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
    }
}

struct SearchEntry: View {
    //TODO- Get current song info
    //TODO- swiping for vetoing songs and viewing the user
    @State var selectedSong: Bool = false
    
    @State var songTitle: String
    @State var songArtist: String
    @State var songID: String
    
    //TO-DO: Use actual values
    @State var addedBy: String = ""
    @State var genres: [String] = ["Placeholder"]
    @State var length: Int = 0
    @State var numVotes: Int? = 0
    
    func selectSong() {
        selectedSong = !selectedSong
        if selectedSong {
            selectedSongs.append(song(addedBy: self.addedBy, artist: self.songArtist, genres: self.genres, id: self.songID, length: self.length, numVotes: self.numVotes, title: self.songTitle))
            print("Selected Song. Currently Selected this many songs: \(selectedSongs.count)")
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
    
    var body: some View {
        ZStack{
            Button(action: {selectSong()}) {
                HStack {
                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 35.0, height: 35.0)
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
    }
}

struct AddMusicView_PreviewsContainer: View {
    //@State var spotify: Spotify = Spotify()

    var body: some View {
        AddMusicView()
    }
}

struct AddMusicView_Previews: PreviewProvider {
  static var previews: some View {
    AddMusicView_PreviewsContainer()
  }
}
