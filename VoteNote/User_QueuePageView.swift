//
//  UserQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

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
    @ObservedObject var votingEnabled: ObservableBoolean
    @ObservedObject var selectedUser: user = user(name: "", profilePic: "")
    @ObservedObject var isHost: ObservableBoolean = ObservableBoolean(boolValue: false)
    
    let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
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
                        if self.songQueue.musicList[0].numVotes != nil && self.songQueue.musicList[1].numVotes != nil {
                            self.songQueue.musicList.sort { $0.numVotes! < $1.numVotes! }
                        }
                    }
                }
            }
        }
    }

    
  var body: some View {
    GeometryReader { geo in
        ZStack {
          VStack {
            HStack {
                Text("\(voteUpdateSeconds)").font(.largeTitle).multilineTextAlignment(.trailing).onReceive(refreshTimer) {
                    _ in
                    if self.voteUpdateSeconds > 0 {
                        self.voteUpdateSeconds -= 1
                    } else {
                        self.voteUpdateSeconds = 10
                        print("Updating Queue")
                        
                        updateQueue()
                    }
                }
            }.hidden().frame(width: 0, height: 0)
            Form {
                
                List {
                    ForEach(songQueue.musicList) { song in
                        QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songQueue, isViewingUser: isViewingUser, isDetailView: false, isUserQueue: false, votingEnabled: votingEnabled, selectedUser: selectedUser)
                                }
                }
            }
            
            NowPlayingViewHost(isPlaying: isPlaying, songQueue: songQueue, isHost: isHost)
            
          }
          .navigationBarHidden(true)
        }.onAppear(perform: {

                //makes the first song in the queue the first to play
                if nowPlaying == nil && songQueue.musicList.count > 0 /*&& (songsList ?? []).count > 0*/ {
                    nowPlaying = songQueue.musicList[0]
                    sharedSpotify.enqueue(songID: songQueue.musicList[0].id)
                    vetoSong(id: songQueue.musicList[0].id)
                }
                print("Updating Queue...")
                updateQueue()
                print("Queue Updated!")
                
        }).navigate(to: UserUserDetailView(user: selectedUser, songQueue: songQueue, votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue)), when: $isViewingUser.boolValue).navigationViewStyle(StackNavigationViewStyle())
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
