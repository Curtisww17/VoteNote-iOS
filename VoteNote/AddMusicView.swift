//
//  AddMusicView.swift
//  VoteNote
//
//  Created by COMP401 on 2/15/21.
//

import Foundation
import SwiftUI

struct AddMusicView: View {
    @State var currentSearch: String = ""
    @State private var isEditing = false
    //@State var musicAvailable: [song]
    
    func addMusic(){
        //TO-DO: Implement Adding Music
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
        }
    }
}

struct SearchEntry: View {
    //TODO- Get current song info
    //TODO- swiping for vetoing songs and viewing the user
    @State var selectedSong: Bool = false
    
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
        }
    }
}

struct AddMusicView_Previews: PreviewProvider {
  static var previews: some View {
    AddMusicView()
  }
}
