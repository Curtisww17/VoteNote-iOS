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

/**
    The UI for the host's version of the Queue View
 */
struct Host_QueuePageView: View {
    @State var currentView = 0
    @ObservedObject var spotify = sharedSpotify
    @State var queueRefreshSeconds = 60
    @State var voteUpdateSeconds = 10
    @ObservedObject var songQueue: MusicQueue = MusicQueue()
    @ObservedObject var isViewingUser: ObservableBoolean = ObservableBoolean(boolValue: false)
    @ObservedObject var selectedSong: song = song(addedBy: "Nil User", artist: "", genres: [""], id: "", length: 0, numVotes: 0, title: "None Selected", imageUrl: "")
    @ObservedObject var selectedUser: user = user(name: "", profilePic: "")
    @ObservedObject var votingEnabled: ObservableBoolean
    @ObservedObject var isHost: ObservableBoolean = ObservableBoolean(boolValue: true)
    
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
                            self.songQueue.musicList.sort { $0.numVotes! > $1.numVotes! }
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
                
        }).navigate(to: HostUserDetailView(user: selectedUser, songQueue: songQueue, votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue)), when: $isViewingUser.boolValue).navigationViewStyle(StackNavigationViewStyle())
    }
  }
}
/**
    A class that stores a copy of a rooms music queue from the DB that can be accessed from the local device
 */
class MusicQueue: Identifiable, ObservableObject {
    var musicList: [song] = [song]()
}

/**
    The UI template for a single entry in the song queue
 */
struct QueueEntry: View {
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
    @ObservedObject var votingEnabled: ObservableBoolean
    
    @State var selectedUser: user
    
    /**
        Calls the DB to upvote the current song
     */
    //TO-DO: limit number of upvotes
    func upVoteSong(){
        print("Upvote Song")
        voteSong(vote: 1, id: curSong.id)
        print("Number of Votes for selected song: \(curSong.numVotes)")
    }
    
    /**
        Calls the DB to downvote the current song
     */
    //TO-DO: limit number of downvotes
    func downVoteSong(){
        print("Downvote Song")
        voteSong(vote: -1, id: curSong.id)
    }
    
    /**
        Calls the DB to veto the current song
     */
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
    
    /**
        Allows the user to view who posted the selected song
     */
    func viewUser(){
        getUser(uid: curSong.addedBy){(user, err) in
            selectedUser = user!
        }
        selectedSong = self.curSong
        isViewingUser.boolValue = true
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                HStack {
                  RemoteImage(url: curSong.imageUrl)
                    .frame(width: 35, height: 35)
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
                        if curSong.numVotes == nil || curSong.numVotes == 0 {
                            Text("\(0)")
                        } else {
                            Text("\(curSong.numVotes!)")
                        }
                        //Text("\(curSong.numVotes ?? 0)")
                        Button(action: {upVoteSong()}) {
                            Image(systemName: "hand.thumbsup").resizable().frame(width: 30.0, height: 30.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                        }.onTapGesture {
                            upVoteSong()
                        }
                        Button(action: {downVoteSong()}) {
                            Image(systemName: "hand.thumbsdown").resizable().frame(width: 30.0, height: 30.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                        }.onTapGesture {
                            downVoteSong()
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    
                    Image(systemName: "chevron.right").resizable().frame(width: 10.0, height: 20.0).foregroundColor(Color.gray)
                    
                    
                    if opened && !isUserQueue {
                        HStack {
                            Button(action: {vetoMusic()}) {
                                Text("Veto").foregroundColor(Color.black).scaleEffect(scale)
                            }.padding(.all).background(Color.red).border(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/).onTapGesture {
                                vetoMusic()
                            }.frame(width: 80, height: 80)
                            
                            if !isDetailView {
                                Button(action: {viewUser()}) {
                                    Text("User").foregroundColor(Color.black).scaleEffect(scale)
                                }.padding(.all).border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/).onTapGesture {
                                    viewUser()
                                }.frame(width: 80, height: 80)
                                
                                /*NavigationLink(destination: HostUserDetailView(user: selectedUser, songQueue: songQueue, votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue), displayHostController: displayHostController)) {
                                    Text("User").scaleEffect(scale)
                                }.frame(width: 80, height: 80)*/
                            }
                        }
                        .padding(.leading)
                    }
                }
            }
        }.background(Color.white)
        .offset(CGSize(width: self.offset.width , height: 0))
        .animation(.spring())
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

/**
    The UI for the now playing bar on the Queue page
 */
struct NowPlayingViewHost: View {
    @State var isMinimized: Bool = true //should start as true
    @State var isPlaying: Bool
    @ObservedObject var songQueue: MusicQueue
    @ObservedObject var isHost: ObservableBoolean
    
    /**
        Resumes the current song in the Spotify Queue
     */
    func playSong(){
        print("Play Song")
        sharedSpotify.resume()
        isPlaying = true
    }
    
    /**
        Pauses the current song in the Spotify Queue
     */
    func pauseSong(){
        //if nowPlaying != nil {
        sharedSpotify.pause()
        print("Pause")
        isPlaying = false
    }
    
    /**
        Skips the current song in the Spotify Queue
     */
    func skipSong(){
        if /*nowPlaying != nil &&*/
            songQueue.musicList.count > 0 {
            
            print(songQueue.musicList.count)
            print("Current Number of Songs in Queue \(songQueue.musicList.count)")
            
            sharedSpotify.enqueue(songID: songQueue.musicList[0].id) //borked
            //OperationQueue.main.waitUntilAllOperationsAreFinished()
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            
            sharedSpotify.skip()
            dequeue(id: nowPlaying!.id)
            nowPlaying = songQueue.musicList[0]
            songQueue.musicList.remove(at: 0)
            sharedSpotify.pause()
            isPlaying = false
        }
    }
    
    /**
        Goes back to the previous song in the Spotify Queue
     */
    func previousSong(){
        //TODO- implement going to previous song
    }
    
    /**
        Favorites the current song in the Spotify Queue
     */
    func favoriteSong(){
        //TODO- implement song favoriting
    }

    var body: some View {
        ZStack {
            Button(action: {
                if isHost.boolValue {
                    isMinimized = !isMinimized
                }
                
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
                            Text("\(nowPlaying?.numVotes ?? 0)")
                            
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
