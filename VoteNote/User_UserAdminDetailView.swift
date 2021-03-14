//
//  User_UserAdminDetailView.swift
//  VoteNote
//
//  Created by COMP401 on 3/13/21.
//

import Foundation
import SwiftUI

/**
    The UI for viewing the details of a user as a user
 */
struct UserUserDetailView: View {
  @State var user: user
  @ObservedObject var songQueue: MusicQueue
  @ObservedObject var selectedSong: song = song(addedBy: "Nil User", artist: "", genres: [""], id: "", length: 0, numVotes: 0, title: "None Selected", imageUrl: "")
  @ObservedObject var hostControllerHidden: ObservableBoolean = ObservableBoolean(boolValue: false)
  @State var shouldReturn: Bool = false
  @ObservedObject var votingEnabled: ObservableBoolean
  @ObservedObject var songHistory: MusicQueue = MusicQueue()
  @State var voteUpdateSeconds = 10
      
    let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
      
    /**
        Updates the music queue after a specified time interval
     */
      func updateHistory() {
          getHistory(){(songs, err) in
              if songs != nil {
                  if songs!.count > 0 {
                      songHistory.musicList.removeAll()
                      var count: Int = 0
                      while count < songs!.count {
                          songHistory.musicList.append(songs![count])
                          count = count + 1
                      }
                  }
              }
          }
      }
    
    /**
        Causes the user to return to the Host Queue page
     */
  func returnToQueue(){
    shouldReturn = true
  }
    
  var body: some View {
    return //NavigationView {
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
                
                Form {
                    Text(user.name)
                        .font(.title)
                    
                    Section(header: Text("In Queue")) {
                        List {
                            ForEach(songQueue.musicList) { song in
                                if song.addedBy == getUID() { //we should probably have a better way to make this comparision
                                    QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songQueue, isViewingUser: hostControllerHidden, isDetailView: true, isUserQueue: true, votingEnabled: votingEnabled, selectedUser: user)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("History")) {
                        List {
                            ForEach(songHistory.musicList) { song in
                                if song.addedBy == getUID() { //we should probably have a better way to make this comparision
                                    QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songHistory, isViewingUser: hostControllerHidden, isDetailView: true, isUserQueue: true, votingEnabled: ObservableBoolean(boolValue: false), selectedUser: user)
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Text("\(voteUpdateSeconds)").font(.largeTitle).multilineTextAlignment(.trailing).onReceive(refreshTimer) {
                        _ in
                        if self.voteUpdateSeconds > 0 {
                            self.voteUpdateSeconds -= 1
                        } else {
                            self.voteUpdateSeconds = 10
                            print("Updating Queue")
                            
                            updateHistory()
                        }
                    }
                }.hidden().frame(width: 0, height: 0)
            }
        //}
    }.onAppear(perform: {
        updateHistory()
    }).navigate(to: User_QueuePageView(votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue)), when: $shouldReturn).onAppear(perform: {
        shouldReturn = false
    }).navigationBarHidden(true).navigationViewStyle(StackNavigationViewStyle())
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