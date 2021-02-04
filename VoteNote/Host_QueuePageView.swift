//
//  HostQueuePageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct Host_QueuePageView: View {
  @Binding var isInRoom: Bool
  
  var body: some View {
    OperationQueue.main.addOperation {
      isInRoom = true
    }
    return NavigationView {
      VStack {
        Text("Host Queue Page!")
      }
      .navigationBarHidden(true)
    }
  }
}
