//
//  Host_UserAdminDetailView.swift
//  VoteNote
//
//  Created by COMP401 on 2/26/21.
//
import Foundation
import SwiftUI

/**
    The UI for viewing the details of a user as a host
 */
struct HostUserDetailView: View {
  @ObservedObject var user: user
  @ObservedObject var songQueue: MusicQueue
  @ObservedObject var selectedSong: song = song(addedBy: "Nil User", artist: "", genres: [""], id: "", length: 0, numVotes: 0, title: "None Selected", imageUrl: "")
  @ObservedObject var hostControllerHidden: ObservableBoolean = ObservableBoolean(boolValue: false)
  @State var shouldReturn: Bool = false
  @ObservedObject var votingEnabled: ObservableBoolean
  @ObservedObject var songHistory: MusicQueue
  @State var voteUpdateSeconds = 10

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
        Causes the user to return to the Hoest Queue page
     */
  func returnToQueue(){
    shouldReturn = true
  }
    
    /**
        Bans the selected user
     */
  func banSelectedUser(){
    banUser(uid: user.uid!)
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
                                if song.addedBy == getUID() {
                                    QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songQueue, isViewingUser: hostControllerHidden, isDetailView: true, isUserQueue: false, isHistoryView: false, votingEnabled: votingEnabled, selectedUser: user)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("History")) {
                        List {
                            ForEach(songHistory.musicList) { song in
                                if song.addedBy == getUID() {
                                    QueueEntry(curSong: song, selectedSong: selectedSong, songQueue: songHistory, isViewingUser: hostControllerHidden, isDetailView: true, isUserQueue: false, isHistoryView: true, votingEnabled: ObservableBoolean(boolValue: false), selectedUser: user)
                                }
                            }
                        }
                    }
                    
                    Button(action: {banSelectedUser()}) {
                        Text("Ban User")
                            .foregroundColor(Color.red)
                    }
                }
            }
        //}
        }.onAppear(perform: {
            updateHistory()
        }).navigate(to: Host_QueuePageView(votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue)), when: $shouldReturn).onAppear(perform: {
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

