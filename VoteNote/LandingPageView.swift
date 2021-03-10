//
//  LandingPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI


struct LandingPageView: View {
  @ObservedObject var spotify = sharedSpotify
  @State var currentView = 0
  @State var isInRoom = false
  var body: some View {
    return NavigationView {
        VStack {
            //if !hostControllerHidden.boolValue {
                Text("Hidden Howdy").hidden()
            //}
            VStack {
              if (!isInRoom) {
                HStack {
                  Spacer()
                    .frame(width: UIScreen.main.bounds.size.width / 4)
                  Picker(selection: self.$currentView, label: Text("I don't know what this label is for")) {
                    Text("Join").tag(0)
                    Text("Host").tag(1)
                  }.pickerStyle(SegmentedPickerStyle())
                  .frame(width: UIScreen.main.bounds.size.width / 2,  alignment: .center)
                  VStack {
                    NavigationLink(
                      destination: ProfileView(),
                      label: {
                        Image(systemName: "person")
                          .resizable()
                          .frame(width: 30, height: 30)
                      })
                  }
                  .frame(width: UIScreen.main.bounds.size.width/4)
                  
                }
                .frame(width: UIScreen.main.bounds.size.width, alignment: .top)
              }
              
              if (currentView == 0) {
                JoinRoomView(isInRoom: $isInRoom)
                  .animation(.default)
                  .transition(.move(edge: .leading))
              } else {
                CreateRoomView(isInRoom: $isInRoom, spotify: spotify)
                  .animation(.default)
                  .transition(.move(edge: .trailing))
              }
            }
            .navigationTitle("Lobby")
            .navigationBarHidden(true)
        }
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading).onAppear(perform: {sharedSpotify.pause()}).navigationViewStyle(StackNavigationViewStyle())
    
  }
}

struct LandingPageView_PreviewContainer: View {

  @State var spotify: Spotify = Spotify()

    var body: some View {
        LandingPageView(spotify: spotify)
    }
}

struct LandingPageView_Previews: PreviewProvider {
  static var previews: some View {
    LandingPageView_PreviewContainer()
  }
}
