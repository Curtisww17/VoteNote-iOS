//
//  UsersListView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/15/21.
//

import Foundation
import SwiftUI

struct UsersListView: View {
  @State var users: [user]?
  @State var isHost: Bool
  @State var votingEnabled: Bool
  @State var gotoHostView = false
  @State var gotoUserView = false
  @State var userID: String = ""
  
  var body: some View {
    
    return NavigationView {
      List {
        ForEach (users ?? []) { user in
          UserListItem(user: user, isHost: isHost, gotoHostView: $gotoHostView, gotoUserView: $gotoUserView, votingEnabled: $votingEnabled, userID: $userID)
            .frame(height: 60)
        }
      }
      .frame(width: UIScreen.main.bounds.width)
      .navigationTitle("Users")
      
    }
      .navigate(to: HostUserDetailView(selectedUserUID: ObservableString(stringValue: userID), votingEnabled: ObservableBoolean(boolValue: votingEnabled)), when: $gotoHostView)
      .navigate(to: UserUserDetailView(selectedUserUID: ObservableString(stringValue: userID), votingEnabled: ObservableBoolean(boolValue: votingEnabled)), when: $gotoUserView)
      .onAppear(perform: {
        getUsers(completion: {usersOut, err in
          self.users = usersOut
        })
      })
    
  }
}

struct UserListItem: View {
  let user: user
  let width : CGFloat = 60
  @State var offset = CGSize.zero
  @State var scale : CGFloat = 0.5
  @State var opened = false
  let isHost: Bool
  @Binding var gotoHostView: Bool
  @Binding var gotoUserView: Bool
  @Binding var votingEnabled: Bool
  @Binding var userID: String
  var body: some View {
    GeometryReader { geo in
      HStack (spacing : 0){
        HStack {
          Text(user.name)
            .frame(alignment: .leading)
          HStack {
            Spacer()
            Image(systemName: "chevron.forward")
              .frame(alignment: .trailing)
          }
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
        }
        .padding()
        .frame(width : geo.size.width + 15, alignment: .leading)
        
        ZStack {
          Text("View")
            .scaleEffect(scale)
        }
        .frame(width: width, height: geo.size.height)
        .background(Color.purple.opacity(0.15))
        .onTapGesture {
          userID = user.uid!
          if (isHost) {
            gotoHostView = true
          } else {
            gotoUserView = true
          }
        }
      }
      .background(Color.white)
      .offset(CGSize(width: self.offset.width , height: 0))
      .animation(.spring())
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
    }.navigationViewStyle(StackNavigationViewStyle())
  }
}
