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
  @State var voteUpdateSeconds = 10
  @State var isTiming: Bool = true
  @State var userName: String = ""
      
    
  var body: some View {
    return
        ZStack {
            VStack {
                
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
                                if song.addedBy == selectedUserUID.stringValue {
                                    QueueEntry(curSong: song, isDetailView: true, isUserQueue: true, isHistoryView: false, localVotes: ObservableInteger(intValue: song.numVotes!))
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("History")) {
                        List {
                            ForEach(songHistory.musicList) { song in
                                if song.addedBy == selectedUserUID.stringValue {
                                    QueueEntry(curSong: song, isDetailView: true, isUserQueue: true, isHistoryView: true, localVotes: ObservableInteger(intValue: song.numVotes!))
                                }
                            }
                        }
                    }
                }
            }
    }.onAppear(perform: {
        songHistory.updateHistory()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
        getUser(uid: selectedUserUID.stringValue, completion: {use, err in
            if (use != nil) {
                userName = use!.name
            }
        })
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
    }).navigationViewStyle(StackNavigationViewStyle())
  }
}
