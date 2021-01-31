//
//  ContentView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import SwiftUI

struct ContentView: View {
  @State var spotify = Spotify()
  var body: some View {
    if (spotify.loggedIn) {
        LoginWithSpotifyView(spotify: $spotify)
      } else {
        LandingPageView(spotify: $spotify)
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
