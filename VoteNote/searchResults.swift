//
//  searchResults.swift
//  VoteNote
//
//  Created by COMP 401 on 2/15/21.
//

import Foundation

var allSongs: [song] = [song]()

struct SearchResultsResults: Codable{
    //let artists: [artistStub]
    let tracks: [trackStub]
}
    
/*struct artistStub: Codable, Identifiable {
    //var id: ObjectIdentifier
    
    let href: String
    let items: [artist]
    let limit: Int
    let next: String
    let offset: Int
    let previous: String
    let total: Int
}*/

struct trackStub: Codable {
    let href: String
    let items: [songStub]
    let limit: Int
    let next: String
    let offset: Int
    let previous: String
    let total: Int
}

struct songStub: Codable, Identifiable{
    //let album: [album]
    let artists: [artistStub]
    let available_markets : [String]
    let disc_number : Int
    let duration_ms : Int
    let explicit: Bool
    //let external_ids: String // object with string maybe can do this
    //let external_urls: String // object with string maybe can do this
    let href: String
    let id: String
    let is_local: Bool
    let name: String
    let popularity: Int
    let preview_url: String
    let track_number: Int
    let type: String
    let uri: String
}

struct artistStub: Codable, Identifiable{
    //let external_ids: String // object with string maybe can do this
    let href: String
    let id: String
    let name: String
    let type: String
    let uri: String
}

class SearchResults: ObservableObject{
    @Published var tracks: [trackStub] = []
    
    static let shared: SearchResults = {
        
        let instance = SearchResults()
        
        guard let url = URL(string: "https://dnd5eapi.co/api/monsters/") else {
            print("Invalid URL")
            return instance
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        // start a data task to download the data from the URL
        session.dataTask(with: url) { data, response, error in
            // make sure data is not nil
            guard let d = data else {
                print("Unable to load data")
                return
            }
            // decode the returned data into Codable structs
            let results: SearchResultsResults?
            do {
                let decoder = JSONDecoder()
                results = try decoder.decode(SearchResultsResults.self, from: d)
            } catch {
                results = nil
            }
            guard let r = results else {
                print("Unable to parse JSON")
                return
            }
            // on the main thread store this data in the shared instance
            //TO-DO: correctly import remaining fields
            OperationQueue.main.addOperation {
                instance.tracks = r.tracks
                //adds all songs from tracks to queue
                for i in r.tracks {
                    for j in i.items {
                        allSongs.append(song(addedBy: "", artist: "Placeholder", genres: ["Placeholder", "Placeholder"], id: j.id, length: 0, numVotes: 0, title: j.name))
                    }
                }
            }
        }.resume() // remember to actually start the task!
        // return the shared instance
        return instance
    }()
    
}
