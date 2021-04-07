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
    return VStack {
      Spacer()
      Image("Logo")
      Spacer()
      Button(action: {
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
      Spacer()
    }
  }
}

class ObservableBoolean: ObservableObject {
    var boolValue: Bool
    
    init(boolValue: Bool) {
        self.boolValue = boolValue
    }
}

class ObservableInteger: ObservableObject {
    var intValue: Int
    
    init(intValue: Int) {
        self.intValue = intValue
    }
}

class ObservableString: ObservableObject {
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
}
