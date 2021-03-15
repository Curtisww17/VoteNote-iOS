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
    @ObservedObject var selectedSong: song = song(addedBy: "Nil User", artist: "", genres: [""], id: "", length: 0, numVotes: 0, title: "None Selected", imageUrl: "")
    var body: some View{
        ZStack{
            VStack{
                Section(header: Text("History")) {
                    List {
                        ForEach(songHistory.musicList) { song in
                            QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songHistory, isViewingUser: hostControllerHidden, isDetailView: true, isUserQueue: false, isHistoryView: true, votingEnabled: ObservableBoolean(boolValue: false), selectedUser: user(name: song.addedBy, profilePic: ""))
                        }
                    }
                }
            }
        }
    }
}
