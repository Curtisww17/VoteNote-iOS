//
//  HostQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct Host_QueuePageView: View {
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
            Text("Where Queue will go")
        }
        
        //Text("Host Queue Page!")
        
        Button(action: {
          //these are the scopes that our app requests
          spotify.appDel.appRemoteDidEstablishConnection(spotify.appDel.appRemote)
          spotify.TestPlay()
        }) {
          Text("play that one about falling down the stairs")
        }
      }
      .navigationBarHidden(true)
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
