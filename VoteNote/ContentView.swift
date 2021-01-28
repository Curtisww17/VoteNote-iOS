//
//  ContentView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import SwiftUI

struct ContentView: View {
  @State var isLoggedIn = false
    var body: some View {
      if (!isLoggedIn) {
        LoginWithSpotifyView(isLoggedIn: $isLoggedIn)
      } else {
        LandingPageView()
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
