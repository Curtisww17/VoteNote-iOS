//
//  ContentView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var spotify = sharedSpotify
    var body: some View {
        VStack {
          /*if (!(spotify.loggedIn)) {
                LoginWithSpotifyView(spotify: spotify)
                  .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)*/
            //} else {
                LandingPageView(spotify: spotify)
            //}
            
            //
            //TEST BUTTON FOR EASY TESTING RANDOM BACKEND STUFF
            //
            
            /*Button(action: {
              //these are the scopes that our app requests
                //spotify.enqueue(songID: "")
                spotify.userPlaylists(limit: "2")
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
