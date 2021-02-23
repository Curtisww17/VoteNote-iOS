//
//  HostQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

var nowPlaying: song?
var isPlaying: Bool = false //should be false by default
//TO-DO: enqueue next song when only so much time is left

struct Host_QueuePageView: View {
    @State var currentView = 0
    @ObservedObject var spotify = sharedSpotify
    //@State var songsList: [song]?
    @State var queueRefreshSeconds = 60
    @State var voteUpdateSeconds = 10
    @ObservedObject var songQueue: MusicQueue = MusicQueue()
    
    let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  var body: some View {
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
                QueueEntry(curSong: song)
            }
            
        }
        
        NowPlayingViewHost(isPlaying: isPlaying, songsList: songQueue.musicList)
        
        //Text("Host Queue Page!")
        
        /*Button(action: {
          //these are the scopes that our app requests
          spotify.appDel.appRemoteDidEstablishConnection(spotify.appDel.appRemote)
          spotify.TestPlay()
        }) {
          Text("play that one about falling down the stairs")
        }*/
      }
      .navigationBarHidden(true)
    }.onAppear(perform: {
        //makes the first song in the queue to first to play
        if nowPlaying == nil && songQueue.musicList.count > 0 /*&& (songsList ?? []).count > 0*/ {
            nowPlaying = songQueue.musicList[0]
            sharedSpotify.enqueue(songID: songQueue.musicList[0].id)
            vetoSong(id: songQueue.musicList[0].id)
        }
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
        
    }).navigationViewStyle(StackNavigationViewStyle())
  }
}

class MusicQueue: Identifiable, ObservableObject {
    var musicList: [song] = [song]()
}

struct QueueEntry: View {
    //TODO- Get current song info
    //TODO- swiping for vetoing songs and viewing the user
    //SWIPING NOT DONE
    @State var curSong: song
    @State var showingExtras: Bool = false
    
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
                    
                    if showingExtras {
                        Button(action: {vetoSong(id: curSong.id)}) {
                            Text("Veto")
                        }
                        .foregroundColor(/*@START_MENU_TOKEN@*/.red/*@END_MENU_TOKEN@*/)
                    }
                }
            }
        }
    }
}

struct NowPlayingViewHost: View {
    @State var isMinimized: Bool = true //should start as true
    @State var isPlaying: Bool
  @State var songsList: [song]
    //TODO- needs the title, artist, votes, and image of the current song, as well as the song itself
    
    func playSong(){
        //TODO- check remaining time in song
        //if nowPlaying != nil {
            sharedSpotify.resume()
            isPlaying = true
        //}
    }
    
    func pauseSong(){
        //if nowPlaying != nil {
            sharedSpotify.pause()
            print("Pause")
            isPlaying = false
        //}
    }
    
    //TO-DO: Add based on number of votes
    func skipSong(){
        if /*nowPlaying != nil &&*/ songsList.count > 0 {
            sharedSpotify.enqueue(songID: songsList[0].id) //borked
            sharedSpotify.skip()
            nowPlaying = songsList[0]
            vetoSong(id: songsList[0].id)
            songsList.remove(at: 0)
        }
    }
    
    func previousSong(){
        //TODO- implement going to previous song
    }
    
    func favoriteSong(){
        //TODO- implement song favoriting
    }

    var body: some View {
        ZStack {
            Button(action: {
                    isMinimized = !isMinimized
                
            }) {
                if isMinimized {
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
                } else {
                    VStack {
                        Image(systemName: "person.crop.square.fill").resizable().frame(width: 160.0, height: 160.0)
                        HStack {
                            Spacer()
                            if nowPlaying == nil {
                                Text("None Selected")
                                    .padding(.leading)
                            } else {
                                Text(nowPlaying!.title)
                                    .padding(.leading)
                            }
                            Spacer()
                        }
                        
                        if nowPlaying != nil {
                            Text(nowPlaying!.artist)
                                .font(.caption)
                        }
                        
                        HStack {
                            if nowPlaying != nil {
                                Text("\(nowPlaying!.numVotes!)")
                            } else {
                                Text("0")
                            }
                            
                            Spacer()
                            Button(action: {previousSong()}) {
                                Image(systemName: "backward").resizable().frame(width: 25.0, height: 20.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                            }
                            Spacer()
                            Button(action: {if isPlaying {
                                pauseSong()
                            } else {
                                playSong()
                            }}) {
                                if isPlaying {
                                    Image(systemName: "pause").resizable().frame(width: 20.0, height: 25.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                                } else {
                                    Image(systemName: "play")
                                        .resizable().frame(width: 20.0, height: 25.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                                }
                            }
                            Spacer()
                            Button(action: {skipSong()}) {
                                Image(systemName: "forward").resizable().frame(width: 25.0, height: 20.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                                
                            }
                            Spacer()
                            Button(action: {favoriteSong()}) {
                                Image(systemName: "heart")
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                            }
                        }
                        .padding(.all)
                    }
                    .padding(.top)
                }
            }
        }
    }
}

struct Host_QueuePageView_PreviewContainer: View {
    @ObservedObject var songQueue: MusicQueue = MusicQueue()
    
    var body: some View {
        Host_QueuePageView(songQueue: songQueue)
    }
}

struct Host_QueuePageView_Previews: PreviewProvider {
  static var previews: some View {
    Host_QueuePageView_PreviewContainer()
  }
}

/*struct NowPlayingViewHost_Previews: PreviewProvider {
  static var previews: some View {
    NowPlayingViewHost()
  }
}*/
