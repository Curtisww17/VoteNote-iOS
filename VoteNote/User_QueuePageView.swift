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
  @State var songsList: [song]?
  
  
  
  var body: some View {
    /*getQueue(completion: {songs, err in
      self.songsList = songs
    })
    return NavigationView {*/
      VStack {
        
        List {
            ForEach(songsList ?? []) { song in
                QueueEntry(curSong: song)
            }
        }
        
        NowPlayingViewUser()
      }
      .navigationBarHidden(true)
    }
  //}
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
