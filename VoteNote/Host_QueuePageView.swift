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
        @ObservedObject var isViewingUser: ObservableBoolean = ObservableBoolean(boolValue: false)
    @ObservedObject var selectedSong: song = song(addedBy: "Nil User", artist: "", genres: [""], id: "", length: 0, numVotes: 0, title: "None Selected", imageUrl: "")
        //@ObservedObject var hostControllerHidden: ObservableBoolean
    @ObservedObject var selectedUser: user = user(name: "", profilePic: "")
    @ObservedObject var votingEnabled: ObservableBoolean
    
    let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
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
        }.hidden()
        
        List {
            ForEach(songQueue.musicList) { song in
                QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songQueue, isViewingUser: isViewingUser, isDetailView: false, isUserQueue: false, votingEnabled: votingEnabled, selectedUser: selectedUser)
                        }
        }
        
        NowPlayingViewHost(isPlaying: isPlaying, songQueue: songQueue)
        
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
            //isViewingUser.boolValue = false
            
            //makes the first song in the queue to first to play
            if nowPlaying == nil && songQueue.musicList.count > 0 /*&& (songsList ?? []).count > 0*/ {
                nowPlaying = songQueue.musicList[0]
                sharedSpotify.enqueue(songID: songQueue.musicList[0].id)
                vetoSong(id: songQueue.musicList[0].id)
            }
            print("Updating Queue...")
            updateQueue()
            print("Queue Updated!")
            //hostControllerHidden.boolValue = false
            
    }).navigate(to: HostUserDetailView(user: selectedUser, songQueue: songQueue, votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue)), when: $isViewingUser.boolValue).navigationViewStyle(StackNavigationViewStyle())
  }
}

class MusicQueue: Identifiable, ObservableObject {
    var musicList: [song] = [song]()
}

struct QueueEntry: View {
    //TODO- Get current song info
    //TODO- swiping for vetoing songs and viewing the user
    @State var curSong: song
    @State var selectedSong: song
    @State var showingExtras: Bool = false
    @ObservedObject var songQueue: MusicQueue
    
    let width : CGFloat = 60
    @State var offset = CGSize.zero
    @State var scale : CGFloat = 0.5
    @State var opened = false
    
    @ObservedObject var isViewingUser: ObservableBoolean
    @State var isDetailView: Bool
    @State var isUserQueue: Bool
    
    @State var showNav: Bool = false
    //@ObservedObject var hostControllerHidden: ObservableBoolean
    @ObservedObject var votingEnabled: ObservableBoolean
    
    @State var selectedUser: user
    
    func upVoteSong(){
        //TODO- Implement Upvoting
    }
    
    func downVoteSong(){
        //TODO- Implement Downvoting
    }
    
    func vetoMusic(){
        vetoSong(id: curSong.id)
        
        var count: Int = 0
        while count < songQueue.musicList.count {
            if curSong.id == songQueue.musicList[count].id {
                songQueue.musicList.remove(at: count)
                count = songQueue.musicList.count
            }
            count = count + 1
        }
    }
    
    func viewUser(){
        //print("Viewing User \(isViewingUser.boolValue)")
        /*getUser(uid: curSong.id)(user, err) in
            self.selectedUser = user!
        }*/
        
        getUser(uid: curSong.addedBy){(user, err) in
            selectedUser = user!
        }
        selectedSong = self.curSong
        //hostControllerHidden.boolValue = true
        //isViewingUser.boolValue = true
        //print("\(isViewingUser.boolValue)")
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                HStack {
                  RemoteImage(url: curSong.imageUrl)
                    .frame(width: 35, height: 35)
//                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 35.0, height: 35.0)
                    if !opened {
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
                    }
                    
                    Spacer()
                    
                    if votingEnabled.boolValue {
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
                    
                    Spacer()
                    Spacer()
                    
                    /*Image(systemName: "chevron.right").resizable().frame(width: 10.0, height: 20.0).foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)*/
                    
                    
                    if opened && !isUserQueue {
                        HStack {
                            Button(action: {vetoMusic()}) {
                                Text("Veto").scaleEffect(scale)
                            }.padding(.all).background(Color.red).border(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/).onTapGesture {
                                vetoMusic()
                            }.frame(width: 80, height: 80)
                            
                            if !isDetailView {
                                Button(action: {viewUser()}) {
                                    Text("User").scaleEffect(scale)
                                }.padding(.all).border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/).onTapGesture {
                                    viewUser()
                                }.frame(width: 80, height: 80)
                            }
                        }
                        .padding(.leading)
                    }
                }
            }
        }.background(Color.white)
        .offset(CGSize(width: self.offset.width , height: 0))
        .animation(.spring())
        /*.onTapGesture {
          if !opened {
            self.scale = 1
            self.offset.width = -60
            opened = true
          } else {
            self.scale = 0.5
            self.offset = .zero
            opened = false
          }
        }*/
        .gesture(DragGesture()
                  .onChanged { gesture in
                    if !isUserQueue {
                        self.offset.width = gesture.translation.width
                    }
                  }
                    .onEnded { _ in
                      if self.offset.width < 50 {
                        self.scale = 1
                        self.offset.width = -60
                        opened = true
                      } else {
                        self.scale = 0.5
                        self.offset = .zero
                        opened = false
                      }
                    }
        )
    }
}

struct NowPlayingViewHost: View {
    @State var isMinimized: Bool = true //should start as true
    @State var isPlaying: Bool
  @ObservedObject var songQueue: MusicQueue
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
        if /*nowPlaying != nil &&*/
            songQueue.musicList.count > 0 {
            
            print("Current Number of Songs in Queue \(songQueue.musicList.count)")
            
            sharedSpotify.enqueue(songID: songQueue.musicList[0].id) //borked
            sharedSpotify.skip()
            nowPlaying = songQueue.musicList[0]
            songQueue.musicList.remove(at: 0)
            //vetoSong(id: nowPlaying.id)
            
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
                      if (nowPlaying != nil) {
                        RemoteImage(url: nowPlaying!.imageUrl)
                          .frame(width: 40, height: 40)
                      } else {
                        Image(systemName: "person.crop.square.fill").resizable().frame(width: 40.0, height: 40.0)
                      }
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
                      if (nowPlaying != nil) {
                        RemoteImage(url: nowPlaying!.imageUrl)
                          .frame(width: 160, height: 160)
                      } else {
                        Image(systemName: "person.crop.square.fill").resizable().frame(width: 160.0, height: 160.0)
                      }
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
                                /*Text("\(nowPlaying!.numVotes!)")*/
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

/*struct Host_QueuePageView_PreviewContainer: View {
    @ObservedObject var songQueue: MusicQueue = MusicQueue()
    
    var body: some View {
        Host_QueuePageView(songQueue: songQueue)
    }
}

struct Host_QueuePageView_Previews: PreviewProvider {
  static var previews: some View {
    Host_QueuePageView_PreviewContainer()
  }
}*/

/*struct NowPlayingViewHost_Previews: PreviewProvider {
  static var previews: some View {
    NowPlayingViewHost()
  }
}*/
