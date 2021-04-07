//
//  UserQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI
import PartialSheet

/**
    The UI for the host's version of the Queue View
 */
struct User_QueuePageView: View {
    @State var currentView = 0
    @ObservedObject var spotify = sharedSpotify
    @State var queueRefreshSeconds = 60
    @State var voteUpdateSeconds = 10
    @ObservedObject var isViewingUser: ObservableBoolean = ObservableBoolean(boolValue: false)
    @ObservedObject var votingEnabled: ObservableBoolean
    @ObservedObject var isHost: ObservableBoolean = ObservableBoolean(boolValue: false)
    @State var isTiming: Bool = false
    @State var canMaximize: Bool = false
    
  var body: some View {
    GeometryReader { geo in
          VStack {
            Form {
                List {
                    ForEach(songQueue.musicList) { song in
                        QueueEntry(curSong: song, isDetailView: false, isUserQueue: true, isHistoryView: false, votingEnabled: votingEnabled, localVotes: ObservableInteger(intValue: song.numVotes!))
                    }
                }
            }
            
            NowPlayingViewHostMinimized(isPlaying: isPlaying, songQueue: songQueue, historyQueue: songHistory, isHost: isHost, isMaximized: $canMaximize, sheetManager: PartialSheetManager())
                .padding(.bottom)

          }
          .frame(width: geo.size.width, height: geo.size.height)
          .navigationBarHidden(true)
          .onAppear(perform: {
            songQueue.updateQueue()
            if (!isTiming) {
              let _ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
                songQueue.updateQueue()
                songHistory.updateHistory()
              }
              isTiming = true
            }
                  
          })
    }
  }
}
