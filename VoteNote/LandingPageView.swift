//
//  LandingPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI


struct LandingPageView: View {
  @Binding var spotify: Spotify
  @State var currentView = 0
  var body: some View {
    return NavigationView {
      VStack {
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
              .frame(alignment: .trailing)
          }
          .frame(width: UIScreen.main.bounds.size.width/4)
          
        }
        .frame(width: UIScreen.main.bounds.size.width, alignment: .top)
        
        if (currentView == 0) {
          JoinRoomView()
            .animation(.default)
            .transition(.move(edge: .leading))
        } else {
          CreateRoomView()
            .animation(.default)
            .transition(.move(edge: .trailing))
        }
      }
      .navigationTitle("Lobby")
      .navigationBarHidden(true)
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    
  }
}
