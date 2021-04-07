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
  @ObservedObject var selectedUserUID: ObservableString
  @ObservedObject var isViewingUser: ObservableBoolean = ObservableBoolean(boolValue: true)
  @ObservedObject var votingEnabled: ObservableBoolean
  @State var voteUpdateSeconds = 10
  @State var isTiming: Bool = true
  @State var userName: String = ""
      
    
  var body: some View {
    return //NavigationView {
        ZStack {
            VStack {
                /*HStack {
                    Button(action: {returnToQueue()}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/).padding(.leading)
                        Text("Queue")
                            .foregroundColor(Color.blue)
                    }
                    Spacer()
                }*/
                
                HStack {
                    Text(userName)
                        .font(.title)
                    Spacer()
                }
                .padding(.leading)
                
                Form {
                    
                    Section(header: Text("In Queue")) {
                        List {
                            ForEach(songQueue.musicList) { song in
                                if song.addedBy == getUID() {
                                    QueueEntry(curSong: song, isDetailView: true, isUserQueue: true, isHistoryView: false, votingEnabled: votingEnabled, localVotes: ObservableInteger(intValue: song.numVotes!))
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("History")) {
                        List {
                            ForEach(songHistory.musicList) { song in
                                if song.addedBy == getUID() {
                                    QueueEntry(curSong: song, isDetailView: true, isUserQueue: true, isHistoryView: true, votingEnabled: ObservableBoolean(boolValue: false), localVotes: ObservableInteger(intValue: song.numVotes!))
                                }
                            }
                        }
                    }
                }
            }
        //}
    }.onAppear(perform: {
        songHistory.updateHistory()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
        getUser(uid: selectedUserUID.stringValue, completion: {use, err in
            if (use != nil) {
                userName = use!.name
            }
        })
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
    })/*.navigate(to: User_QueuePageView(songHistory: songHistory, votingEnabled: ObservableBoolean(boolValue: votingEnabled.boolValue)), when: $shouldReturn).onAppear(perform: {
        shouldReturn = false
    }).navigationBarHidden(true)*/.navigationViewStyle(StackNavigationViewStyle())
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
