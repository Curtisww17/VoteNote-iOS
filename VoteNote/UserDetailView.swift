//
//  UserDetailView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/15/21.
//

import Foundation
import SwiftUI

struct UserDetailView: View {
  let user: user
  var body: some View {
    Text(user.name)
  }
}
