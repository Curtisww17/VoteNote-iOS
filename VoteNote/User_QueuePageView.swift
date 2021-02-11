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
    @Binding var isInRoom: Bool
  @ObservedObject var spotify: Spotify
  
  var body: some View {
    OperationQueue.main.addOperation {
      isInRoom = true
    }
    return NavigationView {
      VStack {
        
        HStack{
            Spacer()
              .frame(width: UIScreen.main.bounds.size.width / 4)
            Picker(selection: self.$currentView, label: Text("I don't know what this label is for")) {
              Text("Queue").tag(0)
              Text("Room").tag(1)
            }.pickerStyle(SegmentedPickerStyle())
            .frame(width: UIScreen.main.bounds.size.width / 2,  alignment: .center)
            
            VStack {
              NavigationLink(
                destination: ProfileView(spotify: spotify),
                label: {
                  Text("Add")
                })
                .frame(alignment: .trailing)
            }
            .frame(width: UIScreen.main.bounds.size.width/4)
        }
        
        List {
            QueueEntry()
        }
        
        NowPlayingViewUser()
      }
      .navigationBarHidden(true)
    }
  }
}

struct NowPlayingViewUser: View {
    //TODO- needs the title, artist, votes, and image of the current song

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Image(systemName: "person.crop.square.fill").resizable().frame(width: 40.0, height: 40.0)
                Text("Song Title")
                        .padding(.leading)
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct User_QueuePageView_PreviewContainer: View {
    @State var isInRoom: Bool = true
    @State var spotify: Spotify = Spotify()

    var body: some View {
        User_QueuePageView(isInRoom: $isInRoom, spotify: spotify)
    }
}

struct User_QueuePageView_Previews: PreviewProvider {
  static var previews: some View {
    User_QueuePageView_PreviewContainer()
  }
}
