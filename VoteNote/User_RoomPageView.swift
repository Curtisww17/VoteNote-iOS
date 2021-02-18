//
//  User_RoomPageView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/25/21.
//

import Foundation
import SwiftUI

struct User_RoomPageView: View {
  @State var currentView = 1
  var roomName: String = "Primanti Bros."
  var roomDescription: String = "Description goes here"
  var roomCapacity: Int = 5
  var songsPerUser: Int = 5
  
  @Binding var showNav: Bool
  
  var body: some View {
    //return NavigationView {
    ZStack {
      VStack {
        
        Form {
          Section(header: Text(roomName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .padding(.top)) {
            //Other Buttons will be added here
            
          }
          
          Section() {
            NavigationLink(destination: UsersListView()
                            .onAppear(perform: {
                              showNav = false
                            })
                            .onDisappear(perform: {
                              showNav = true
                            }), label: {
                              HStack {
                                Image(systemName: "person.3")
                                  .foregroundColor(Color.accentColor)
                                  .padding()
                                Text("Users")
                              }
                            })
          }
          
          Section(header: Text("Room Settings")) {
            Text(roomDescription)
            HStack{
              Text("Room Capacity")
              Spacer()
              Text("\(roomCapacity)")
            }
            
            HStack{
              Text("Songs Per User")
              Spacer()
              Text("\(songsPerUser)")
            }
          }
          Button(action: {
            actionSheet()
          }, label: {
            HStack {
              Spacer()
              Text("Share Room Code")
                .foregroundColor(Color.accentColor)
              Spacer()
            }
          })
        }
      }
      .navigationTitle("Room")
      .navigationBarHidden(true)
    }
  }
  
  func actionSheet() {
    getCurrRoom(completion: { code, err in
      let data = code ?? " No Code Found"
      let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
      UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    })
  }
}



