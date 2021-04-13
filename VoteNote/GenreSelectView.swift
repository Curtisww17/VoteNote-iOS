//
//  GenreSelectView.swift
//  VoteNote
//
//  Created by Wesley Curtis on 4/8/21.
//

import Foundation
import SwiftUI

struct GenreSelectView: View {
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @Binding var genres: Set<String>
  let allGenres = sharedSpotify.genreList?.genres ?? []
  @State var selectAll = true
  @State var deselectAll = false
  @State private var isEditing = false
  @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
  @State var searchStr: String = ""
  
  var body: some View {
    return VStack {
      HStack {
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }, label: {
          HStack {
            Image(systemName: "chevron.left")
              .resizable()
              .frame(width: 15, height: 20)
              .padding(.leading)
            Text("Back")
          }
        })
        .frame(alignment: .leading)
        Spacer()
        Button(action: {
          if (genres.count == allGenres.count) {
              genres.removeAll()
          } else {
            allGenres.forEach { currentGenre in
              genres.insert(currentGenre)
            }
          }
        }, label: {
          HStack {
            if (genres.count == allGenres.count) {
              Text("Deselect All")
                .foregroundColor(.accentColor)
            } else {
              Text("Select All")
                .foregroundColor(.accentColor)
            }
          }
        })
        .padding([.top, .bottom, .trailing])
      }
      .frame(alignment: .leading)
        
        HStack {
            
            TextField("Search Genres", text: $searchStr).onChange(of: self.searchStr, perform: { value in
                currentSearch.stringValue = searchStr
            })
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
                    self.searchStr = ""
                    
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
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
            
            Spacer()
        }
        
      Form {
        ForEach(allGenres, id: \.self) { genre in
            if (genre.lowercased().contains("\(currentSearch.stringValue.lowercased())") || currentSearch.stringValue == "") {
                GenreListItem(genreName: genre, genres: $genres)
            }
        }
      }
    }
  }
}

struct GenreListItem: View {
  let genreName: String
  @Binding var genres: Set<String>
  
  var body: some View {
    GeometryReader { geo in
      Button(action: {
        if (genres.contains(genreName)) {
          genres.remove(genreName)
        } else {
          genres.insert(genreName)
        }
      }, label: {
        HStack {
          Text(genreName.capitalized)
            .frame(alignment: .leading)
            .foregroundColor(.primary)
          Spacer()
          if !genres.contains(genreName) {
            Image(systemName: "plus.circle")
              .padding(.trailing)
          } else {
            Image(systemName: "checkmark")
              .padding(.trailing)
              .foregroundColor(.blue)
          }
        }
        .frame(width: geo.size.width, alignment: .center)
      })
    }
  }
}


struct GenreView: View {
  @Binding var genres: [String]
  @State private var isEditing = false
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var currentSearch: ObservableString = ObservableString(stringValue: "")
  @State var searchStr: String = ""
  
  var body: some View {
    return VStack {
    
        HStack {
            
            TextField("Search Genres", text: $searchStr).onChange(of: self.searchStr, perform: { value in
                currentSearch.stringValue = searchStr
            })
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
                    self.searchStr = ""
                    
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
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
            
            Spacer()
        }
        
    HStack {
      Form {
        ForEach(genres, id: \.self) { genre in
            if (genre.lowercased().contains("\(currentSearch.stringValue.lowercased())") || currentSearch.stringValue == "") {
                GenreViewListItem(genreName: genre)
            }
        }
      }
    }
  }
  }
  
}

struct GenreViewListItem: View {
  let genreName: String
  
  var body: some View {
    GeometryReader { geo in
      HStack {
        VStack {
          Text(genreName)
            .frame(alignment: .center)
        }
        .frame(width: geo.size.width, height: 50, alignment: .leading)
      }
      .frame(width: geo.size.width, height: 50, alignment: .leading)
    }
  }
}
