//
//  Host_RoomPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct Host_RoomPageView: View {
  
  var body: some View {
    return NavigationView {
      ZStack {
        VStack {
            /*Picker(selection: self.$currentView, label: Text("I don't know what this label is for")) {
              Text("Queue").tag(0)
              Text("Room").tag(1)
            }.pickerStyle(SegmentedPickerStyle())
            .frame(width: UIScreen.main.bounds.size.width / 2,  alignment: .center)*/
          //Text("Host Room Page!")
            Form {
                
                Text("Room Description")
                Section(header: Text("Room Settings")) {
                    Text("Room Capacity")
                    Text("Songs Per User")
                }
            }
        }
        .navigationTitle("Room Name")
      }
    }
  }
}

struct Host_RoomPageView_Previews: PreviewProvider {
  static var previews: some View {
    Host_RoomPageView()
  }
}
