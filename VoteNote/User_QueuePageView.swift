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
    @ObservedObject var selectedSong: song = song(addedBy: "Nil User", artist: "", genres: [""], id: "", length: 0, numVotes: 0, title: "None Selected", imageUrl: "")
    @ObservedObject var songQueue: MusicQueue = MusicQueue()
    @ObservedObject var songHistory: MusicQueue
    @ObservedObject var votingEnabled: ObservableBoolean
    @ObservedObject var selectedUser: user = user(name: "", profilePic: "")
    @ObservedObject var isHost: ObservableBoolean = ObservableBoolean(boolValue: false)
    @Binding var isTiming: Bool
    @State var canMaximize: Bool = false
    
//    let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
    /**
        Updates the music queue after a specified time interval
     */
    func updateQueue() {
        getQueue(){(songs, err) in
            if songs != nil {
                if songs!.count > 0 {
                    songQueue.musicList.removeAll()
                    var count: Int = 0
                    while count < songs!.count {
                        songQueue.musicList.append(songs![count])
                        count = count + 1
                    }
                    
                    if votingEnabled.boolValue {
                        if self.songQueue.musicList.count > 1 {
                            if self.songQueue.musicList[0].numVotes != nil && self.songQueue.musicList[1].numVotes != nil {
                                self.songQueue.musicList.sort { $0.numVotes! > $1.numVotes! }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateHistory() {
        getHistory(){(songs, err) in
            if songs != nil {
                if songs!.count > 0 {
                    songHistory.musicList.removeAll()
                    var count: Int = 0
                    while count < songs!.count {
                        songHistory.musicList.append(songs![count])
                        count = count + 1
                    }
                }
            }
        }
    }

    
  var body: some View {
    GeometryReader { geo in
        ZStack {
          VStack {
            Form {
                
                List {
                    ForEach(songQueue.musicList) { song in
                        QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songQueue, isViewingUser: isViewingUser, isDetailView: false, isUserQueue: true, isHistoryView: false, votingEnabled: votingEnabled, selectedUser: selectedUser, localVotes: ObservableInteger(intValue: song.numVotes!))
                                }
                }
            }
            
//            Text("\(voteUpdateSeconds)").font(.largeTitle).multilineTextAlignment(.trailing).onReceive(refreshTimer) {
//                _ in
//                if self.voteUpdateSeconds > 0 {
//                    self.voteUpdateSeconds -= 1
//                } else {
//                    self.voteUpdateSeconds = 10
//                    print("Updating Queue")
//
//                    updateQueue()
//                    updateHistory()
//                }
//            }.hidden().frame(width: 0, height: 0)
            
            NowPlayingViewHostMinimized(isPlaying: isPlaying, songQueue: songQueue, historyQueue: songHistory, isHost: isHost, isMaximized: $canMaximize, sheetManager: PartialSheetManager())
                .padding(.bottom)
            
          }
          .navigationBarHidden(true)
        }.onAppear(perform: {

          if (!isTiming) {
            let _ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
              songQueue.updateQueue()
              updateHistory()
              print("Queue Updated!")
            }
            isTiming = true
          }
                print("Updating Queue...")
                updateQueue()
                print("Queue Updated!")
                
        }).navigate(to: UserUserDetailView(user: selectedUser, songQueue: songQueue, votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue), songHistory: songHistory), when: $isViewingUser.boolValue).navigationViewStyle(StackNavigationViewStyle())
    }
  }
}

/*struct User_QueuePageView_PreviewContainer: View {
    @State var isInRoom: Bool = true

    var body: some View {
        User_QueuePageView(votingEnabled: ObservableBoolean(boolValue: true))
    }
}

struct User_QueuePageView_Previews: PreviewProvider {
  static var previews: some View {
    User_QueuePageView_PreviewContainer()
  }
}*/
