//
//  HostQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

var nowPlaying: song?
var isPlaying: Bool = false

struct Host_QueuePageView: View {
    @State var currentView = 0
    @Binding var isInRoom: Bool
    @ObservedObject var spotify = sharedSpotify
    //@State var musicQueue: [song] = getQueue()
  
  var body: some View {
    OperationQueue.main.addOperation {
      isInRoom = true
    }
    return NavigationView {
      VStack {
        
        List {
            QueueEntry()
            ForEach(getQueue()) { song in
                
            }
        }
        
        NowPlayingViewHost()
        
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
    }
  }
}

struct QueueEntry: View {
    //TODO- Get current song info
    //TODO- swiping for vetoing songs and viewing the user
    
    func upVoteSong(){
        //TODO- Implement Upvoting
    }
    
    func downVoteSong(){
        //TODO- Implement Downvoting
    }
    
    var body: some View {
        ZStack{
            HStack {
                Image(systemName: "person.crop.square.fill").resizable().frame(width: 35.0, height: 35.0)
                VStack {
                    Text("Song Title")
                    Text("Artist Name")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                Text("+4")
                Button(action: {upVoteSong()}) {
                    Image(systemName: "hand.thumbsup").resizable().frame(width: 30.0, height: 30.0)
                }
                Button(action: {downVoteSong()}) {
                    Image(systemName: "hand.thumbsdown").resizable().frame(width: 30.0, height: 30.0)
                }
            }
        }
    }
}

struct NowPlayingViewHost: View {
    @State var isMinimized: Bool = true //should start as true
    //TODO- needs the title, artist, votes, and image of the current song, as well as the song itself
    
    func playSong(){
        //TODO- check remaining time in song
        if nowPlaying != nil {
            sharedSpotify.resume()
            isPlaying = true
        }
    }
    
    //TO-DO: Test
    func pauseSong(){
        if nowPlaying != nil {
            sharedSpotify.pause()
            isPlaying = false
        }
    }
    
    //TO-DO: Add based on number of votes
    //TO-DO: Test
    func skipSong(){
        if nowPlaying != nil && getQueue().count > 0 {
            sharedSpotify.enqueue(songID: getQueue()[0].id)
            sharedSpotify.skip()
            nowPlaying = getQueue()[0]
            vetoSong(id: getQueue()[0].id)
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
            if isMinimized {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 40.0, height: 40.0)
                    if nowPlaying == nil {
                        Text("None Selected")
                            .padding(.leading)
                    } else {
                        Text(nowPlaying!.title)
                            .padding(.leading)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding(.vertical).onTapGesture {
                    isMinimized = !isMinimized
                }
            } else {
                VStack {
                    Image(systemName: "person.crop.square.fill").resizable().frame(width: 160.0, height: 160.0)
                    if nowPlaying == nil {
                        Text("None Selected")
                            .padding(.leading)
                    } else {
                        Text(nowPlaying!.title)
                            .padding(.leading)
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
                                Image(systemName: "pause").resizable().frame(width: 20.0, height: 25.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/).onTapGesture {
                                    isPlaying = !isPlaying
                                }
                            } else {
                                Image(systemName: "play")
                                    .resizable().frame(width: 20.0, height: 25.0).foregroundColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/).onTapGesture {
                                        isPlaying = !isPlaying
                                    }
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
                .padding(.top).onTapGesture {
                    isMinimized = !isMinimized
                }
                
            }
        }
    }
}

struct Host_QueuePageView_PreviewContainer: View {
    @State var isInRoom: Bool = true
    @State var spotify: Spotify = Spotify()

    var body: some View {
        Host_QueuePageView(isInRoom: $isInRoom, spotify: spotify)
    }
}

struct Host_QueuePageView_Previews: PreviewProvider {
  static var previews: some View {
    Host_QueuePageView_PreviewContainer()
  }
}
