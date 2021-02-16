//
//  AddMusicView.swift
//  VoteNote
//
//  Created by COMP401 on 2/15/21.
//

import Foundation
import SwiftUI

var selectedSongs: [song] = [song]()

struct AddMusicView: View {
    @State var currentSearch: String = ""
    @State private var isEditing = false
    @ObservedObject var spotify = sharedSpotify
    
    @Environment(\.presentationMode) var presentationMode
    
    //TO-DO: Have songs filtered by search
    
    func addMusic(){
        //TO-DO: Implement Adding Music
        
        //select the first song if nothing is playing
        if nowPlaying == nil && selectedSongs.count > 0 {
            nowPlaying = selectedSongs[0]
            sharedSpotify.enqueue(songID: selectedSongs[0].id)
            selectedSongs.remove(at: 0)
        }
        
        //sharedSpotify.enqueue(songID: "spotify:track:20I6sIOMTCkB6w7ryavxtO")
        
        //TO-DO: add music from selectedSongs array to queue, remove after added
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    
                    HStack {
                        TextField("Search Music", text: $currentSearch)
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 8)
                                    
                                    if isEditing {
                                        Button(action: {
                                            self.currentSearch = ""
                                            
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 8)
                                        }
                                    }
                                }
                            )
                            .padding(.horizontal, 10)
                            .onTapGesture {
                                self.isEditing = true
                            }
                        
                        if isEditing {
                            Button(action: {
                                self.isEditing = false
                                self.currentSearch = ""
                                
                                // Dismiss the keyboard
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                Text("Cancel")
                            }
                            .padding(.trailing, 10)
                            .transition(.move(edge: .trailing))
                            .animation(.default)
                        }
                        
                        Button(action: {addMusic()}) {
                            Text("Add Songs")
                        }
                        .padding(.trailing)
                    }
                    
                    List {
                        SearchEntry()
                    }
                }
                
            }
        }.onAppear(perform: {
            selectedSongs.removeAll()
        })
    }
}

struct SearchEntry: View {
    //TODO- Get current song info
    //TODO- swiping for vetoing songs and viewing the user
    @State var selectedSong: Bool = false
    //@State var curSong: song
    
    var body: some View {
        ZStack{
            HStack {
                Image(systemName: "person.crop.square.fill").resizable().frame(width: 35.0, height: 35.0)
                VStack {
                    Text("Song Title")
                    Text("Artist Name")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                if !selectedSong {
                    Image(systemName: "plus.circle")
                        .padding(.trailing)
                } else {
                    Image(systemName: "checkmark")
                        .padding(.trailing)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
            }
        }.onTapGesture {
            selectedSong = !selectedSong
            if selectedSong {
                //selectedSongs.append(curSong:song)
            } else {
                var songIndex: Int = 0
                while songIndex < selectedSongs.count {
                    //if selectedSongs[songIndex].id == curSong.id {
                    selectedSongs.remove(at: songIndex)
                    //}
                    songIndex = songIndex + 1
                }
            }
        }
    }
}

/*struct AddMusicView_PreviewsContainer: View {
    @State var spotify: Spotify = Spotify()

    var body: some View {
        AddMusicView(spotify: spotify)
    }
}

struct AddMusicView_Previews: PreviewProvider {
  static var previews: some View {
    AddMusicView_PreviewsContainer()
  }
}*/
