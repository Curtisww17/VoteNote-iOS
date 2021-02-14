//
//  ContentView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var spotify = Spotify()
    @ObservedObject var httpRequester = HttpRequester()
    var body: some View {
        VStack {
            if (!spotify.loggedIn) {
                LoginWithSpotifyView(spotify: spotify)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            } else {
                LandingPageView(spotify: spotify)
            }
            
            //
            //TEST BUTTON FOR EASY TESTING RANDOM BACKEND STUFF
            //
            /*
            Button(action: {
              //these are the scopes that our app requests
                httpRequester.GET(url: "https://google.com")
            }) {
              Text("http Test")
            }*/
        }
    }
    
    var db = dbConnection()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
