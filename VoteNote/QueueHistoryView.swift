//
//  QueueHistoryView.swift
//  VoteNote
//
//  Created by COMP 401 on 3/14/21.
//

import Foundation
import SwiftUI

struct QueueHistoryView: View {
    @State private var isEditing = false
    @State var currentSearch: String = ""
    @State var searchStr: String = ""

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
                            
                            sharedSpotify.createPlaylist(id: sharedSpotify.currentUser?.id ?? "")
                            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
                            sharedSpotify.userPlaylists(completion: {playlist in sharedSpotify.userPlaylists = playlist}, limit: "10")
                            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
                            sharedSpotify.playlistSongs(completion: {playlistSongs in sharedSpotify.savePlaylist = playlistSongs}, id: sharedSpotify.userPlaylists?.items?[0].id ?? "")
                            
                            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
                            
                            sharedSpotify.addSongsToPlaylist(Playlist: sharedSpotify.savePlaylist?.id ?? "", songs: songHistory.musicList)
                            
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
                }
            }
        }
    }
}
