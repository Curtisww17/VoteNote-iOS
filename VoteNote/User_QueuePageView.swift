//
//  UserQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct User_QueuePageView: View {
    @State var currentView = 0
  @ObservedObject var spotify = sharedSpotify
  //@State var songsList: [song]?
    @State var queueRefreshSeconds = 60
    @State var voteUpdateSeconds = 10
    @ObservedObject var songQueue: MusicQueue = MusicQueue()
    
    let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  
  var body: some View {
      VStack {
        
        HStack {
            Text("\(voteUpdateSeconds)").font(.largeTitle).multilineTextAlignment(.trailing).onReceive(refreshTimer) {
                _ in
                if self.voteUpdateSeconds > 0 {
                    self.voteUpdateSeconds -= 1
                } else {
                    self.voteUpdateSeconds = 10
                    print("Updating Queue")
                    
                    getQueue(){(songs, err) in
                        if songs != nil {
                            if songs!.count > 0 {
                                songQueue.musicList.removeAll()
                                var count: Int = 0
                                while count < songs!.count {
                                    songQueue.musicList.append(songs![count])
                                    count = count + 1
                                }
                            }
                        }
                    }
                }
            }
        }.hidden()
        
        List {
            ForEach(songQueue.musicList) { song in
                UserQueueEntry(curSong: song)
            }
        }
        
        NowPlayingViewUser()
      }
      .navigationBarHidden(true).onAppear(perform: {
        print("Updating Queue...")
        
        getQueue(){(songs, err) in
            if songs != nil {
                if songs!.count > 0 {
                    songQueue.musicList.removeAll()
                    var count: Int = 0
                    while count < songs!.count {
                        songQueue.musicList.append(songs![count])
                        count = count + 1
                    }
                }
            }
        }
        print("Queue Updated!")
      })
  }
  //}
}

struct UserQueueEntry: View {
    //TODO- Get current song info
    //TODO- swiping for vetoing songs and viewing the user
    @State var curSong: song
    @State var showingExtras: Bool = false
    
    let width : CGFloat = 60
    @State var offset = CGSize.zero
    @State var scale : CGFloat = 0.5
    @State var opened = false
    
    func upVoteSong(){
        //TODO- Implement Upvoting
    }
    
    func downVoteSong(){
        //TODO- Implement Downvoting
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 35.0, height: 35.0)
                    VStack {
                        HStack {
                            Text(curSong.title)
                            Spacer()
                        }
                        HStack {
                            Text(curSong.artist).font(.caption)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    if curSong.numVotes != nil {
                        Text("0")
                    } /*else {
                        Text("\(curSong.numVotes!)")
                    }*/
                    
                    Button(action: {upVoteSong()}) {
                        Image(systemName: "hand.thumbsup").resizable().frame(width: 30.0, height: 30.0)
                    }
                    Button(action: {downVoteSong()}) {
                        Image(systemName: "hand.thumbsdown").resizable().frame(width: 30.0, height: 30.0)
                    }
                }
            }
        }.background(Color.white)
    }
}


struct NowPlayingViewUser: View {
    //TODO- needs the title, artist, votes, and image of the current song

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Image(systemName: "person.crop.square.fill").resizable().frame(width: 40.0, height: 40.0)
                VStack {
                    HStack {
                        if nowPlaying == nil {
                            Text("None Selected").padding(.leading)
                        } else {
                            Text(nowPlaying!.title).padding(.leading)
                        }
                        Spacer()
                    }
                    HStack {
                        if nowPlaying != nil {
                            Text(nowPlaying!.artist).font(.caption)
                                .foregroundColor(Color.gray).padding(.leading)
                        }
                        Spacer()
                    }
                }
                Spacer()
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct User_QueuePageView_PreviewContainer: View {
    @State var isInRoom: Bool = true

    var body: some View {
        User_QueuePageView()
    }
}

struct User_QueuePageView_Previews: PreviewProvider {
  static var previews: some View {
    User_QueuePageView_PreviewContainer()
  }
}
