//
//  HostQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

var nowPlaying: song?
var isPlaying: Bool = true //should be false by default
//TO-DO: enqueue next song when only so much time is left

struct Host_QueuePageView: View {
    @State var currentView = 0
    @ObservedObject var spotify = sharedSpotify
  
  var body: some View {
    //return NavigationView {
    return ZStack {
      VStack {
        
        List {
            ForEach(getQueue()) { song in
                QueueEntry(curSong: song)
            }
        }
        
        NowPlayingViewHost(isPlaying: isPlaying)
        
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
        if nowPlaying == nil && getQueue().count > 0 {
            nowPlaying = getQueue()[0]
            sharedSpotify.enqueue(songID: getQueue()[0].id)
            vetoSong(id: getQueue()[0].id)
        }
    })
  }
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
        
        let swipeGesture = DragGesture().onEnded {_ in
            showingExtras = !showingExtras
        }
        ZStack{
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
                    Text("\(curSong.numVotes!)")
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
    @State var isMinimized: Bool = false //should start as true
    @State var isPlaying: Bool
    //TODO- needs the title, artist, votes, and image of the current song, as well as the song itself
    
    func playSong(){
        //TODO- check remaining time in song
        if nowPlaying != nil {
            sharedSpotify.resume()
            isPlaying = true
        }
    }
    
    func pauseSong(){
        if nowPlaying != nil {
            sharedSpotify.pause()
            print("Pause")
            isPlaying = false
        }
    }
    
    //TO-DO: Add based on number of votes
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
                .padding(.vertical).onTapGesture {
                    isMinimized = !isMinimized
                }
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
                .padding(.top)//.onTapGesture {
                    //isMinimized = !isMinimized
                //}
                
            }
        }
    }
}

struct Host_QueuePageView_PreviewContainer: View {

    var body: some View {
        Host_QueuePageView()
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
