//
//  QueueHistoryView.swift
//  VoteNote
//
//  Created by COMP 401 on 3/14/21.
//

import Foundation
import SwiftUI

/**
    The UI view for the Song History View
 */
struct QueueHistoryView: View {
    @State private var isEditing = false
    @State var currentSearch: String = ""
    @State var searchStr: String = ""
    @State var showingCreatePlaylistAlert: Bool = false
    
    var body: some View{
        GeometryReader { geo in
            ZStack{
                VStack{
                    
                    HStack {
                        
                        HStack {
                          TextField("Search History", text: $currentSearch).onChange(of: self.currentSearch, perform: { value in
                            sharedSpotify.searchSong(completion: { search in
                              sharedSpotify.recentSearch = search
                              
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
                                    self.isEditing = false
                                    self.currentSearch = ""
                                    
                                    // Dismiss the keyboard
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                  
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
                        }
                        Button("Create Playlist") {
                            showingCreatePlaylistAlert = createPlaylist()
                        }.padding(.trailing)
                    }
                    
                    //lists all songs previously played in the room
                    
                    Form {
                        List {
                            ForEach(songHistory.musicList) { song in
                                if (song.title!.lowercased().contains("\(currentSearch.lowercased())") || currentSearch == "") {
                                    QueueEntry(curSong: song, isDetailView: true, isUserQueue: false, isHistoryView: true, localVotes: ObservableInteger(intValue: song.numVotes!))
                                }
                            }
                        }
                    }
                }.alert(isPresented: $showingCreatePlaylistAlert) {
                    Alert(title: Text("Playlist Creation"), message: Text("Playlist Created Successfully!"), dismissButton: .default(Text("Ok")) {
                        showingCreatePlaylistAlert = false
                    })
                  }
            }
        }
    }
}

/**
    Creates a Spotify playlist using the songs in history
 */
func createPlaylist() -> Bool {
    sharedSpotify.createPlaylist(id: sharedSpotify.currentUser?.id ?? "")
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
    sharedSpotify.userPlaylists(completion: {playlist in sharedSpotify.userPlaylists = playlist}, limit: "10")
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
    sharedSpotify.playlistSongs(completion: {playlistSongs in sharedSpotify.savePlaylist = playlistSongs}, id: sharedSpotify.userPlaylists?.items?[0].id ?? "")
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
    
    sharedSpotify.addSongsToPlaylist(Playlist: sharedSpotify.savePlaylist?.id ?? "", songs: songHistory.musicList)
    
    return true
}
