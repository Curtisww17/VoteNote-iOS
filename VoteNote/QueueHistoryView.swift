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
                    var tracks: [[String: Any]] = []
                    for song in songHistory.musicList {
                        var track: [String: Any] = ["added_at":Date(), "added_by":sharedSpotify.currentUser!]
                        tracks.append(track)
                    }
                    //let jsonObject: [String: Any] = [ ]
                    //sharedSpotify.createPlaylist2(id: sharedSpotify.currentUser?.id ?? "", json: jsonObject)
                }
                
                //lists all songs previously played in the room
                
                Section(header: Text("History")) {
                    List {
                        ForEach(songHistory.musicList) { song in
                            QueueEntry(curSong: song, isDetailView: true, isUserQueue: false, isHistoryView: true, votingEnabled: ObservableBoolean(boolValue: false), localVotes: ObservableInteger(intValue: song.numVotes!))
                        }
                    }
                }
            }
        }
    }
}
