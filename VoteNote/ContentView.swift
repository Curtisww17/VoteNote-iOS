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
      if (!(spotify.loggedIn)) {
        LoginWithSpotifyView(spotify: spotify)
          .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
      } else {
        LandingPageView(spotify: spotify)
      }
    }.onAppear(perform: {
      UIApplication.shared.addTapGestureRecognizer()
    })
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }
}
