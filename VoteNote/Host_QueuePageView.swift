//
//  HostQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct Host_QueuePageView: View {
@ObservedObject var spotify: Spotify
  var body: some View {
    return NavigationView {
      VStack {
        Text("Host Queue Page!")
        
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
