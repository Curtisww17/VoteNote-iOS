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
    @ObservedObject var isViewingUser: ObservableBoolean = ObservableBoolean(boolValue: false)
    @State var isTiming: Bool = false
    @State var canMaximize: Bool = false
  @Binding var genres: [String]
    
  var body: some View {
    GeometryReader { geo in
          VStack {
            Form {
                List {
                    ForEach(songQueue.musicList) { song in
                        QueueEntry(curSong: song, isDetailView: false, isUserQueue: true, isHistoryView: false, localVotes: ObservableInteger(intValue: song.numVotes!))
                    }
                }
            }
            
            NowPlayingViewUserMinimized(isPlaying: isPlaying)
                .padding(.bottom)

          }
          .frame(width: geo.size.width, height: geo.size.height)
          .navigationBarHidden(true)
          .onAppear(perform: {
            
            var curRoom: room = room(name: "", anonUsr: false, capacity: 0, explicit: false, voting: true)
            getRoom(code: currentQR.roomCode, completion: {room, err in
                if (room != nil) {
                
                  curRoom = room!
                    
                  RoomName = curRoom.name
                  RoomDescription = curRoom.desc!
                  VotingEnabled = curRoom.voting
                  AnonUsr = curRoom.anonUsr
                  SongsPerUser = curRoom.spu
                  RoomCapacity = curRoom.capacity
                  ExplicitSongsAllowed = curRoom.explicit
                  genres = curRoom.genres
                }
            })
            
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

/**
    The UI for the now playing bar on the Queue page
 */
struct NowPlayingViewUserMinimized: View {
    @State var isPlaying: Bool
    @State var saved: Bool = false
    @ObservedObject var currentSongTitle: ObservableString = ObservableString(stringValue: "None Playing")
    @ObservedObject var currentSongArtists: ObservableString = ObservableString(stringValue: "")
    @ObservedObject var currentSongImageURL: ObservableString = ObservableString(stringValue: "")
    
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
        ZStack {
            HStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
              if (currentSongImageURL.stringValue != nil && currentSongImageURL.stringValue != "") {
                RemoteImage(url: currentSongImageURL.stringValue)
                  .frame(width: 40, height: 40)
              } else {
                Image(systemName: "person.crop.square.fill").resizable().frame(width: 40.0, height: 40.0)
              }
                VStack {
                    HStack {
                        Text(currentSongTitle.stringValue).padding(.leading)
                        Spacer()
                    }
                    HStack {
                        Text(currentSongArtists.stringValue).font(.caption)
                                .foregroundColor(Color.gray).padding(.leading)
                        Spacer()
                    }
                }
                Spacer()
                Spacer()
            }
            .padding(.vertical)
        }
      }.onAppear(perform: {
        getRoom(code: currentQR.roomCode, completion: {room, err in
            if (room != nil) {
                //currentSong = room?.currSong
                
                sharedSpotify.getTrackInfo(track_uri: room!.currSong) { (track) in
                    var title = ""
                    var artist = ""
                    var imageUrl = ""
                    
                    if track != nil{
                        
                        for art in track!.artists! {
                            artist += art.name + " "
                        }
                        title = track!.name
                        imageUrl = track?.album?.images?[0].url ?? ""
                    }
                    
                    currentSongTitle.stringValue = title
                    currentSongArtists.stringValue = artist
                    currentSongImageURL.stringValue = imageUrl
                }
            }
        })
        
      })
      
      
    }
}

