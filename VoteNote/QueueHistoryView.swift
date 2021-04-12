//
//  QueueHistoryView.swift
//  VoteNote
//
//  Created by COMP 401 on 3/14/21.
//

import Foundation
import SwiftUI

struct QueueHistoryView: View {
    @ObservedObject var hostControllerHidden: ObservableBoolean = ObservableBoolean(boolValue: false)
    @ObservedObject var songHistory: MusicQueue

    var body: some View{
        ZStack{
            VStack{
                
                //button to add history as a playlist on spotify
                Button("create Playlist") {
                    
                    sharedSpotify.createPlaylist(id: sharedSpotify.currentUser?.id ?? "")
                    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
                    sharedSpotify.userPlaylists(completion: {playlist in sharedSpotify.userPlaylists = playlist}, limit: "10")
                    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
                    sharedSpotify.playlistSongs(completion: {playlistSongs in sharedSpotify.savePlaylist = playlistSongs}, id: sharedSpotify.userPlaylists?.items?[0].id ?? "")
                    
                    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
                    
                    sharedSpotify.addSongsToPlaylist(Playlist: sharedSpotify.savePlaylist?.id ?? "", songs: songHistory.musicList)
                    
                }
                
                //lists all songs previously played in the room
                
                Section(header: Text("History")) {
                    List {
                        ForEach(songHistory.musicList) { song in
                            QueueEntry(curSong: song, isDetailView: true, isUserQueue: false, isHistoryView: true, localVotes: ObservableInteger(intValue: song.numVotes!))
                        }
                    }
                }
            }
        }
    }
}
