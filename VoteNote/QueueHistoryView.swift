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
                    
                    //let jsonData = try! JSONEncoder().encode(songHistory)
                    //let jsonString = String(data: jsonData, encoding: .utf8)!
                    //let jsonObject: [String: Any] = [ ]
                    let jsonString = sharedSpotify.fillSavedPlaylist(playlist: songHistory)
                    
                    sharedSpotify.createPlaylist2(id: sharedSpotify.currentUser?.id ?? "", json: jsonString)
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
