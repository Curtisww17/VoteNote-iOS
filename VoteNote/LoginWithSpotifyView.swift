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
  var body: some View {
    return HStack {
      Button(action: {
        //these are the scopes that our app requests
        spotify.login()
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
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
  }
}

