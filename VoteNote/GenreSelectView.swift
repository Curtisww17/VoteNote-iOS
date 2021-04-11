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
      Form {
        ForEach(allGenres, id: \.self) { genre in
          GenreListItem(genreName: genre, genres: $genres)
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
  
  var body: some View {
    return VStack {
      HStack {
      Form {
        ForEach(genres, id: \.self) { genre in
          GenreViewListItem(genreName: genre)
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
