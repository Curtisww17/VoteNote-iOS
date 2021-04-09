//
//  HostQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI
import PartialSheet

//var nowPlayingIsMinimized: Bool = true
var isPlaying: Bool = false //should be false by default
//TO-DO: enqueue next song when only so much time is left
var songQueue: MusicQueue = MusicQueue()
var songHistory: MusicQueue = MusicQueue()
var timeTracker = true
var currSongID = ""
/**
    The UI for the host's version of the Queue View
 */
struct Host_QueuePageView: View {
    @State var currentView = 0
    @ObservedObject var spotify = sharedSpotify
    @State var queueRefreshSeconds = 10
    @ObservedObject var isViewingUser: ObservableBoolean = ObservableBoolean(boolValue: false)
    @ObservedObject var votingEnabled: ObservableBoolean
    @ObservedObject var isHost: ObservableBoolean = ObservableBoolean(boolValue: true)
    @State var isTiming: Bool = false
    @State var showMaxNowPlaying: Bool = false
    @EnvironmentObject var sheetManager : PartialSheetManager
    
  var body: some View {
    GeometryReader { geo in
          VStack {
            Form {
                List {
                    ForEach(songQueue.musicList) { song in
                        QueueEntry(curSong: song, isDetailView: false, isUserQueue: false, isHistoryView: false, votingEnabled: votingEnabled, localVotes: ObservableInteger(intValue: song.numVotes!))
                    }
                }
            }
            
            NowPlayingViewHostMinimized(isPlaying: isPlaying, songQueue: songQueue, historyQueue: songHistory, isHost: isHost, isMaximized: $showMaxNowPlaying, sheetManager: sheetManager)

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
                  
          }).partialSheet(isPresented: $showMaxNowPlaying, content: {
            ZStack {
                NowPlayingViewHostMaximized(isPlaying: isPlaying, isHost: isHost, isMaximized: $showMaxNowPlaying)
            }
          }).addPartialSheet()
    }
  }
}
/**
    A class that stores a copy of a rooms music queue from the DB that can be accessed from the local device
 */
class MusicQueue: Identifiable, ObservableObject {
    var musicList: [song] = [song]()
  @Published var currentlyPlaying: song?
  
  public func skipSong() {
      if musicList.count > 0 {
        sharedSpotify.enqueue(songID: self.musicList[0].id) {
          sharedSpotify.skip()
          
          dequeue(id: self.musicList[0].id)
        }
        updateQueue()
        isPlaying = false
      }
      else if(sharedSpotify.PlaylistBase != nil){
        var pos = Int.random(in: 0..<(sharedSpotify.PlaylistBase?.tracks?.items?.count ?? 0))
        currSongID = sharedSpotify.PlaylistBase?.tracks?.items?[pos].track.id ?? ""
        sharedSpotify.enqueue(songID: currSongID) {
          sharedSpotify.skip()
          dequeue(id: currSongID)
        }
      } else {
        //sharedSpotify.skip()
        print("no Song to play :(")
      }
  }
  
  func updateQueue() {
    var numUsersInRoom = 1
    getUsers(completion: { (users, err) in
      if err == nil {
        numUsersInRoom = users!.count
      } else {
        print(err as Any)
      }
    })
      getQueue(){(songs, err) in
          if songs != nil {
              if songs!.count > 0 {
                self.musicList.removeAll()
                  var count: Int = 0
                  while count < songs!.count {
                    self.musicList.append(songs![count])
                      count = count + 1
                  }
                if self.musicList.count > 1 {
                  if self.musicList[0].numVotes != nil && self.musicList[1].numVotes != nil {
                    self.musicList.sort { $0.numVotes! > $1.numVotes! }
                          }
                      }
                  
              }
            
            //automatically veto any song with over half of the room downvoting it
            if (self.musicList.count > 0) {
              for i in Range(0...self.musicList.count-1) {
                if self.musicList[i].numVotes ?? 0 < -(numUsersInRoom / 2) {
                  vetoSong(id: self.musicList[i].id)
                }
              }
            }
          }
      }
    if(self.musicList.count > 0){
        if((sharedSpotify.currentlyPlayingPercent ?? 0) > 0.50 && currSongID != sharedSpotify.currentlyPlaying?.id ?? "notPlaying"){
            currSongID = sharedSpotify.currentlyPlaying?.id ?? ""
            sharedSpotify.enqueue(songID: self.musicList[0].id) {
              dequeue(id: self.musicList[0].id)
            }
        }
    } else if(sharedSpotify.PlaylistBase != nil) {
        if((sharedSpotify.currentlyPlayingPercent ?? 0) > 0.50 && currSongID != sharedSpotify.currentlyPlaying?.id ?? "notPlaying"){
            var pos = Int.random(in: 0..<(sharedSpotify.PlaylistBase?.tracks?.items?.count ?? 1))
            currSongID = sharedSpotify.PlaylistBase?.tracks?.items?[pos].track.id ?? ""
            sharedSpotify.enqueue(songID: sharedSpotify.PlaylistBase?.tracks?.items?[pos].track.id ?? "") {
              dequeue(id: sharedSpotify.PlaylistBase?.tracks?.items?[pos].track.id ?? "")
            }
        }
    } else if(sharedSpotify.currentlyPlayingPercent ?? 0 > 0.50 ){
        print("no music to add")
        //self.currentlyPlaying = nil
    }
  }
  
  public func addMusic(songs: [song]){
    
    //set the first song if nothing is playing
  if self.currentlyPlaying == nil && songs.count > 0 {
    self.currentlyPlaying = selectedSongs[0]
    sharedSpotify.enqueue(songID: selectedSongs[0].id) {
      sharedSpotify.skip()
    }
    addsong(id: songs[0].id) {
      dequeue(id: songs[0].id)
    }
      //sharedSpotify.skip() //need to clear out queue still before playing, clears out one song for now
      //sharedSpotify.pause()
      //songs.remove(at: 0)
    
    for i in songs.dropFirst() {
        print("Added")
      addsong(id: i.id){}
        print("Done")
    }
  } else {
    
    for i in songs {
        print("Added")
      addsong(id: i.id){}
        print("Done")
    }
  }
  }
    

    func updateHistory() {
        getHistory(){(songs, err) in
            if songs != nil {
                if songs!.count > 0 {
                    self.musicList.removeAll()
                    var count: Int = 0
                    while count < songs!.count {
                        self.musicList.append(songs![count])
                        count = count + 1
                    }
                }
            }
        }
    }
}

/**
    The UI template for a single entry in the song queue
 */
struct QueueEntry: View {
    @State var curSong: song
    @State var showingExtras: Bool = false
    
    let width : CGFloat = 60
    @State var offset = CGSize.zero
    @State var scale : CGFloat = 0.5
    @State var opened = false
    
    @State var isDetailView: Bool
    @State var isUserQueue: Bool
    @State var isHistoryView: Bool
    
    @State var showNav: Bool = false
    @ObservedObject var votingEnabled: ObservableBoolean
    
    @ObservedObject var localVotes: ObservableInteger
    
    /**
        Calls the DB to upvote the current song
     */
    //TO-DO: limit number of upvotes
    func upVoteSong(){
        print("Upvote Song")
        localVotes.intValue = localVotes.intValue + 1
      voteSong(vote: 1, id: curSong.id){
        songQueue.updateQueue()
      }
    }
    
    /**
        Calls the DB to downvote the current song
     */
    //TO-DO: limit number of downvotes
    func downVoteSong(){
        print("Downvote Song")
        localVotes.intValue = localVotes.intValue - 1
      voteSong(vote: -1, id: curSong.id) {
        songQueue.updateQueue()
      }
    }
    
    /**
        Calls the DB to veto the current song
     */
    func vetoMusic(){
        print("Vetoing Song")
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
    
    var body: some View {
    
        
        ZStack {
            VStack {
                HStack {
                  RemoteImage(url: curSong.imageUrl)
                    .frame(width: 35, height: 35)
                    if !opened {
                        VStack {
                            HStack {
                              Text(curSong.title!)
                                Spacer()
                            }
                            HStack {
                              Text(curSong.artist!).font(.caption)
                                    .foregroundColor(Color.gray)
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if votingEnabled.boolValue {
                        Text("\(localVotes.intValue)")
                        /*if curSong.numVotes == nil || curSong.numVotes == 0 {
                            Text("\(0)")
                        } else {
                            Text("\(curSong.numVotes!)")
                        }*/
                        /*Button(action: {upVoteSong()}) {
                            */Image(systemName: "hand.thumbsup").resizable().frame(width: 30.0, height: 30.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)/*
                        }*/.onTapGesture {
                            upVoteSong()
                        }
                        /*Button(action: {downVoteSong()}) {
                            */Image(systemName: "hand.thumbsdown").resizable().frame(width: 30.0, height: 30.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)/*
                        }*/.onTapGesture {
                            downVoteSong()
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    
                    if !isHistoryView {
                        Image(systemName: "chevron.right").resizable().frame(width: 10.0, height: 20.0).foregroundColor(Color.gray)
                    }
                    
                    
                    if opened && !isHistoryView {
                        HStack {
                            if !isUserQueue {
                                Button(action: {/*vetoMusic()*/}) {
                                    Text("Veto").foregroundColor(Color.black).scaleEffect(scale)
                                }.padding(.all).background(Color.red).border(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/).onTapGesture {
                                    vetoMusic()
                                }.frame(width: 80, height: 80)
                            }
                            
                            if !isDetailView {
                                if isUserQueue {
                                    ZStack {
                                        Text("User").scaleEffect(scale)
                                      NavigationLink(destination: UserUserDetailView(selectedUserUID: ObservableString(stringValue: curSong.addedBy), votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue))) {
                                            EmptyView()
                                        }.hidden()
                                    }.padding(.all).border(Color.black, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/).frame(width: 80, height: 80)
                                } else {
                                    ZStack {
                                        Text("User").scaleEffect(scale)
                                      NavigationLink(destination: HostUserDetailView(selectedUserUID: ObservableString(stringValue: curSong.addedBy), votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue))) {
                                            EmptyView()
                                        }.hidden()
                                    }.padding(.all).border(Color.black, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/).frame(width: 80, height: 80)
                                }
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
                    if !isHistoryView {
                        self.offset.width = gesture.translation.width
                    }
                  }
                    .onEnded { _ in
                      if !isHistoryView {
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
                    }
        )
    }
}

/**
    The UI for the now playing bar on the Queue page
 */
struct NowPlayingViewHostMaximized: View {
    @State var isPlaying: Bool
    @ObservedObject var isHost: ObservableBoolean
    @State var saved: Bool = false
    @Binding var isMaximized: Bool //should start as true
    
    /**
        Resumes the current song in the Spotify Queue
     */
    func playSong(){
        print("Play Song")
        sharedSpotify.resume()
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
        if !(sharedSpotify.isPaused ?? true) {
            isPlaying = false
        } else {
            isPlaying = true
        }
    }
    
    /**
        Pauses the current song in the Spotify Queue
     */
    func pauseSong(){
        //if nowPlaying != nil {
        sharedSpotify.pause()
        print("Pause")
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
        if !(sharedSpotify.isPaused ?? true) {
            isPlaying = false
        } else {
            isPlaying = true
        }
    }
    
    /**
        Skips the current song in the Spotify Queue
     */
    func skipSong(){
      songQueue.skipSong()
    }
    
    /**
        Goes back to the previous song in the Spotify Queue
     */
    //TO-DO: method to delete from history
    //TO-DO: update history
    func previousSong(){
        if songHistory.musicList.count > 0 {
            
            //print("Current Number of Songs in Queue \(songQueue.musicList.count)")
            
            sharedSpotify.enqueue(songID: songHistory.musicList[songHistory.musicList.count - 1].id) {
            sharedSpotify.skip()
            
            //dequeue(id: self.historyQueue.musicList[0].id)
          }
            //updateQueue()
            isPlaying = false
        }
        else {
          sharedSpotify.skip()
        }
    }
    
    /**
        Favorites the current song in the Spotify Queue
     */
    func favoriteSong(){
      if(sharedSpotify.currentlyPlaying != nil){
        sharedSpotify.likeSong(id: sharedSpotify.currentlyPlaying!.id)
            saved = !saved
        }
    }

    var body: some View {
      VStack {
        if (isHost.boolValue) {
          HStack {
            Color.green
              .frame(width: UIScreen.main.bounds.width * CGFloat(sharedSpotify.currentlyPlayingPercent ?? 0), alignment: .leading)
          }
          .frame(width: UIScreen.main.bounds.width, height: 4, alignment: .leading)
        }
        ZStack {
            Button(action: {
                if isHost.boolValue {
                    isMaximized = !isMaximized
                }
                
            }, label: {
                VStack {
                  if (sharedSpotify.currentlyPlaying != nil) {
                    RemoteImage(url: sharedSpotify.currentlyPlaying!.album!.images![0].url)
                      .frame(width: 160, height: 160)
                  } else {
                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 160.0, height: 160.0)
                  }
                    HStack {
                        Spacer()
                      if sharedSpotify.currentlyPlaying == nil {
                            Text("None Selected")
                                .padding(.leading)
                        } else {
                          Text(sharedSpotify.currentlyPlaying!.name)
                                .padding(.leading)
                        }
                        Spacer()
                    }
                    
                  if sharedSpotify.currentlyPlaying != nil {
                    Text(sharedSpotify.currentlyPlaying!.artists!.first!.name)
                            .font(.caption)
                    }
                    
                    HStack {
                      //Text("\(.numVotes ?? 0)")
                        
                        Spacer()
                        Button(action: {previousSong()}) {
                            Image(systemName: "backward").resizable().frame(width: 25.0, height: 20.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                        }
                        Spacer()
                      Button(action: {if !(sharedSpotify.isPaused ?? true) {
                            pauseSong()
                        } else {
                            playSong()
                        }}) {
                            if !(isPlaying) {
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
                            if(!saved){
                            Image(systemName: "heart")
                                .foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                            } else {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                            }
                            
                        }
                    }
                    .padding(.all)
                }
                .padding(.top)
            })
            
        }
      }.onAppear(perform: {
        sharedSpotify.updateCurrentlyPlayingPosition()
        
        if !(sharedSpotify.isPaused ?? true) {
            isPlaying = false
        } else {
            isPlaying = true
        }
      })
      
      
    }
}

/**
    The UI for the now playing bar on the Queue page
 */
struct NowPlayingViewHostMinimized: View {
    @State var isPlaying: Bool
    @ObservedObject var songQueue: MusicQueue
    @ObservedObject var historyQueue: MusicQueue
    @ObservedObject var isHost: ObservableBoolean
    @State var saved: Bool = false
    @Binding var isMaximized: Bool //should start as true
    let sheetManager: PartialSheetManager
    
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
      songQueue.skipSong()
        print("skiped")
      timeTracker = true
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
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
      if(sharedSpotify.currentlyPlaying != nil){
        sharedSpotify.likeSong(id: sharedSpotify.currentlyPlaying!.id)
            saved = !saved
        }
    }

    var body: some View {
      VStack {
        if (isHost.boolValue) {
          HStack {
            Color.green
              .frame(width: UIScreen.main.bounds.width * CGFloat(sharedSpotify.currentlyPlayingPercent ?? 0), alignment: .leading)
          }
          .frame(width: UIScreen.main.bounds.width, height: 4, alignment: .leading)
        }
        ZStack {
            Button(action: {
                if isHost.boolValue {
                    //isMaximized = !isMaximized
                    self.sheetManager.showPartialSheet({
                         print("normal sheet dismissed")
                    }) {
                        NowPlayingViewHostMaximized(isPlaying: isPlaying, isHost: isHost, isMaximized: $isMaximized)
                    }
                }
                
            }, label: {
                HStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                  if (sharedSpotify.currentlyPlaying != nil) {
                    RemoteImage(url: (sharedSpotify.currentlyPlaying!.album?.images![0].url)!)
                      .frame(width: 40, height: 40)
                  } else {
                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 40.0, height: 40.0)
                  }
                    VStack {
                        HStack {
                          if sharedSpotify.currentlyPlaying == nil {
                                Text("None Selected").padding(.leading)
                            } else {
                              Text(sharedSpotify.currentlyPlaying!.name).padding(.leading)
                            }
                            Spacer()
                        }
                        HStack {
                          if sharedSpotify.currentlyPlaying != nil {
                            Text(sharedSpotify.currentlyPlaying!.artists!.first!.name).font(.caption)
                                    .foregroundColor(Color.gray).padding(.leading)
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                    Spacer()
                }
                .padding(.vertical)
            })
            
        }
      }.onAppear(perform: {
        sharedSpotify.updateCurrentlyPlayingPosition()
      })
      
      
    }
}


/*struct NowPlayingViewHost_Previews: PreviewProvider {
  static var previews: some View {
    NowPlayingViewHost()
  }
}*/
