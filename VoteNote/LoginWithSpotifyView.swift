//
//  LoginWithSpotifyView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct LoginWithSpotifyView: View {
  @ObservedObject var spotify: Spotify
  @ObservedObject var httpRequester = HttpRequester()
  var body: some View {
    let scopes = spotify.scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let redirect_url = spotify.SpotifyRedirectURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let urlString = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(spotify.SpotifyClientID)&scope=\(scopes)&redirect_uri=\(redirect_url)"
    return HStack {
      //Text(urlString)
      //Link("Sign In to WebAPI", destination: URL(string: urlString)!)
//      Button(action: {
//        httpRequester.GET(url: urlString)
//      }, label: {
//        Text("log in")
//      })
      Button(action: {

        //these are the scopes that our app requests
        sharedSpotify.login()
      }, label: {
        ZStack {
          Text("Login With Spotify")
            .foregroundColor(Color.white)
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
          .background(
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
              .fill(Color(red: 30.0/255, green: 215.0/255, blue: 96.0/255)))
        }

      } )
      .padding(.bottom, 30)
      .frame(alignment: .bottom)
      
    }
    //.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
  }
}

