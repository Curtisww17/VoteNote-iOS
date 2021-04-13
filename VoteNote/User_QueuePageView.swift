//
//  UserQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI
import PartialSheet

var currentSongTitle: String = "None Playing"
var currentSongArtists: String = ""
var currentSongImageURL: String = ""
var currentSongID: String = ""

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
            
            sharedSpotify.pause()
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

          })
    }
  }
}

/**
    The UI for the now playing bar on the Queue page for users
 */
struct NowPlayingViewUserMinimized: View {
    @State var isPlaying: Bool
    @State var saved: Bool = false
    @State var isLiked = false

    /**
        Favorites the current song in the Spotify Queue
     */
    func favoriteSong(){
        if(!sharedSpotify.isSongFavorited(songID: currentSongID)){
            sharedSpotify.likeSong(id: currentSongID)
            isLiked = true
        }
        else{
            sharedSpotify.unLikeSong(id: currentSongID)
            isLiked = false
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
                
                if (currentSongImageURL != nil && currentSongImageURL != "") {
                    RemoteImage(url: currentSongImageURL)
                        .frame(width: 40, height: 40)
                } else {
                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 40.0, height: 40.0)
                }
                
                VStack {
                    HStack {
                        Text(currentSongTitle).padding(.leading)
                        Spacer()
                    }
                    HStack {
                        Text(currentSongArtists).font(.caption)
                                .foregroundColor(Color.gray).padding(.leading)
                        Spacer()
                    }
                }
                Spacer()
                
                Button(action: {favoriteSong()}) {
                   if(!isLiked){
                   Image(systemName: "heart")
                       .foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                   } else {
                       Image(systemName: "heart.fill")
                           .foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                   }
                   
                }
                .padding(.trailing)
            }
            .padding(.vertical)
        }
      }.onAppear(perform: {
        getRoom(code: currentQR.roomCode, completion: {room, err in
            if (room != nil) {
                sharedSpotify.getTrackInfo(track_uri: room!.currSong) { (track) in
                    var title = ""
                    var artist = ""
                    var imageUrl = ""
                    var id = ""
                    
                    if track != nil{
                        
                        for art in track!.artists! {
                            artist += art.name + " "
                        }
                        title = track!.name
                        imageUrl = track?.album?.images?[0].url ?? ""
                        id = track?.id ?? ""
                    }
                    
                    currentSongTitle = title
                    currentSongArtists = artist
                    currentSongImageURL = imageUrl
                    currentSongID = id
                }
            }
        })
        
        if(sharedSpotify.isSongFavorited(songID: currentSongID)){
            isLiked = true
        } else {
            isLiked = false
        }
      })
    }
}

