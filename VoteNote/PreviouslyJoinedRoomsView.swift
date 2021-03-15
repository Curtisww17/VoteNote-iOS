//
//  PreviouslyJoinedRoomsView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 3/14/21.
//

import Foundation
import SwiftUI

struct PreviouslyJoinedRoomsView: View {
  @State var rooms: [String]
  var body: some View {
    return VStack {
      Text("Destination")
      List {
        ForEach(rooms, id: \.self) {currRoom in
          Text(currRoom)
        }
      }
    }
  }
}
