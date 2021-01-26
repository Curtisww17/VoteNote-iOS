//
//  LandingPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI


struct LandingPageView: View {
  @State var currentView = 0
  var body: some View {
    return NavigationView {
      VStack {
        
        if (currentView == 1) {
          JoinRoomView()
        } else {
          CreateRoomView()
        }
      }
      .navigationBarItems(trailing: HStack {
        //TODO: THIS PICKER IS NOT WANTING TO CENTER ALIGN
//        I JUST DID THIS HACK TEMPORARILY
        Picker(selection: self.$currentView, label: Text("I don't know what this label is for")) {
                        Text("Join").tag(0)
                        Text("Host").tag(1)
        }.pickerStyle(SegmentedPickerStyle())
        .frame(width: UIScreen.main.bounds.size.width / 1.5)
        .frame(alignment: .center)
        Spacer()
          .frame(width: UIScreen.main.bounds.size.width / 15)
        NavigationLink(
                              destination: ProfileView(),
                              label: {
                                Image(systemName: "person")
                                  .resizable()
                                  .frame(width: 30, height: 30)
                              })
          .frame(alignment: .topTrailing)
        
      }
      .frame(minWidth: 0, maxWidth: .infinity, alignment: .top))
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    
  }
}

struct LandingPageView_Previews: PreviewProvider {
  static var previews: some View {
    LandingPageView()
  }
}
