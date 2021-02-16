//
//  UsersListView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/15/21.
//

import Foundation
import SwiftUI

struct UsersListView: View {
  var body: some View {
    NavigationView {
      List {
        ForEach (getUsers()) { user in
          UserListItem(user: user)
            .frame(height: 60)
        }
      }
      .frame(width: UIScreen.main.bounds.width)
      .navigationTitle("Users")
      
    }
  }
  
}

struct UserListItem: View {
  let user: user
  let width : CGFloat = 60
  @State var offset = CGSize.zero
  @State var scale : CGFloat = 0.5
  @State var opened = false
  var body: some View {
    GeometryReader { geo in
      HStack (spacing : 0){
        HStack {
        Text(user.name)
          .frame(alignment: .leading)
          Spacer()
          Image(systemName: "chevron.forward")
            .frame(alignment: .trailing)
        }
          .padding()
          .frame(width : geo.size.width + 15, alignment: .leading)
        
        ZStack {
          Text("Detail")
            .scaleEffect(scale)
        }
        .frame(width: width, height: geo.size.height)
        .background(Color.purple.opacity(0.15))
        .onTapGesture {
          //do thing
        }
      }
      .background(Color.white)
      .offset(CGSize(width: self.offset.width , height: 0))
      .animation(.spring())
      .onTapGesture {
        if !opened {
          self.scale = 1
          self.offset.width = -60
          opened = true
        } else {
          self.scale = 0.5
          self.offset = .zero
          opened = false
        }
      }
      .gesture(DragGesture()
                .onChanged { gesture in
                  self.offset.width = gesture.translation.width
                }
                .onEnded { _ in
                  if self.offset.width < -50 {
                    self.scale = 1
                    self.offset.width = -60
                    opened = true
                  } else {
                    self.scale = 0.5
                    self.offset = .zero
                    opened = false
                  }
                }
      )
    }
  }
}

struct UsersListView_Previews: PreviewProvider {
  static var previews: some View {
    UsersListView()
  }
}
