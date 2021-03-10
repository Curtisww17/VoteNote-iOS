//
//  Host_UserAdminDetailView.swift
//  VoteNote
//
//  Created by COMP401 on 2/26/21.
//
import Foundation
import SwiftUI

struct HostUserDetailView: View {
    //need to manually add back button
  @State var user: user
  @ObservedObject var songQueue: MusicQueue
    @ObservedObject var selectedSong: song = song(addedBy: "Nil User", artist: "", genres: [""], id: "", length: 0, numVotes: 0, title: "None Selected", imageUrl: "")
    @ObservedObject var hostControllerHidden: ObservableBoolean = ObservableBoolean(boolValue: false)
    @State var shouldReturn: Bool = false
    
    func returnToQueue(){
        shouldReturn = true
    }
    
    func banUser(){
        //TO-DO: Implement banning users
    }
    
  var body: some View {
    return NavigationView {
        ZStack {
            VStack {
                HStack {
                    Button(action: {returnToQueue()}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/).padding(.leading)
                        Text("Queue")
                            .foregroundColor(Color.blue)
                    }
                    Spacer()
                }
                
                Text(user.name)
                    .font(.title)
                
                Section(header: Text("In Queue")) {
                    List {
                        ForEach(songQueue.musicList) { song in
                            if song.addedBy == user.name { //we should probably have a better way to make this comparision
                                QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songQueue, isViewingUser: hostControllerHidden, isDetailView: true, isUserQueue: false)
                            }
                        }
                    }
                }
                
                Button(action: {banUser()}) {
                    Text("Ban User")
                        .foregroundColor(Color.red)
                }
            }
        }
    }.navigate(to: Host_QueuePageView(), when: $shouldReturn).onAppear(perform: {
        shouldReturn = false
    }).navigationViewStyle(StackNavigationViewStyle())
  }
}

/*struct HostUserDetailView_PreviewContainer: View {
    @State var newUser: user = user(name: "John Stamos", profilePic: "")
    var body: some View {
        HostUserDetailView(user: newUser, songQueue: <#MusicQueue#>)
    }
}
struct HostUserDetailView_Previews: PreviewProvider {
  static var previews: some View {
    User_QueuePageView_PreviewContainer()
  }
}*/

