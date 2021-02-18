//
//  Spotify.swift
//  VoteNote
//
//  Created by Wesley Curtis on 1/31/21.
//

import Foundation
import SwiftHTTP
import SwiftUI

let sharedSpotify = Spotify()

class Spotify: ObservableObject {
  
  let SpotifyClientID = "badf7b737e204baf818600b2c352a985"
  let SpotifyRedirectURL = URL(string: "VoteNote://SpotifyAuthentication")!
  let SpotifyRedirectURLString = "VoteNote://SpotifyAuthentication"
  
  @Published var canLogin: Bool
  private var httpRequester: HttpRequester
  
  var currentUser: SpotifyUser?
  var recentSearch: SearchResults?
  var userPlaylists: playlistStub?
  
  var sessionManager: SPTSessionManager? {
    didSet {
      self.canLogin = true
    }
  }
  var appRemote: SPTAppRemote? {
    didSet {
      //print("app remote set")
    }
  }
  
  var accessToken: String? {
    get {
      UserDefaults.standard.string(forKey: "access-token-key")
    }
  }
  
  
  //scopes that we request access for, add more as needed
  let SCOPES: SPTScope = [ .userReadRecentlyPlayed, .userTopRead, .streaming, .userReadEmail, .appRemoteControl, .playlistModifyPrivate, .playlistModifyPublic, .playlistReadPrivate, .userModifyPlaybackState, .userReadPlaybackState, .userReadCurrentlyPlaying]
  
  @Published var loggedIn: Bool
  
  
  
  
  
  init() {
    //constructor stuff goes here
    self.loggedIn = false
    self.canLogin = false
    httpRequester = HttpRequester()
  }
  
  func login() -> Bool {
    self.sessionManager?.initiateSession(with: SCOPES, options: .default)
    return true
  }
  
  func logout() -> Bool {
    self.appRemote?.playerAPI?.pause(nil)
    self.appRemote?.disconnect()
    self.loggedIn = false
    UserDefaults.standard.removeObject(forKey: "access-token-key")
    return true
  }
  
  func pause() {
    self.appRemote?.playerAPI?.pause({ (_, error) in
      print(error)
    })
  }
  
  func resume(){
    self.appRemote?.playerAPI?.resume({ (_, error) in
      print(error)
    })
  }
  
  func enqueue(songID: String){
    self.appRemote?.playerAPI?.enqueueTrackUri("spotify:track:"+songID, callback: { (_, error) in
      print(error)
    })
  }
  
  func skip(){
    self.appRemote?.playerAPI?.skip(toNext: { (_, error) in
      print(error)
    })
  }
  
  //need to add call back(?)
  func getPlayerState(){
    self.appRemote?.playerAPI?.getPlayerState({ (_, error) in
      print(error)
    })
  }
  
  func searchSong(completion: @escaping (SearchResults?) -> (), Query: String, limit: String, offset:String){
    self.httpRequester.headerParamGet(url: "https://api.spotify.com/v1/search", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ], param: ["q" : Query, "type": "track,artist", "limit": limit]).onFinish = {
      (response) in
        do {
          let decoder = JSONDecoder()
          try completion( decoder.decode(SearchResults.self, from: response.data))
        } catch {
          fatalError("Couldn't parse \(response.description)")
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
    
    //print("!!!!"+(self.recentSearch?.tracks?.items?[0].name ?? ""))

  }
  
    func userPlaylists(completion: @escaping (playlistStub?) -> (), limit: String){
      self.httpRequester.headerGet(url: "https://api.spotify.com/v1/me/playlists", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
        (response) in
          do {
            let decoder = JSONDecoder()
            try completion( decoder.decode(playlistStub.self, from: response.data))
          } catch {
            fatalError("Couldn't parse \(response.description)")
          }

      }
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
      
      //print("!!!!"+(self.userPlaylists?.items?[0].name ?? ""))
    }
  
  func isLoggedIn() -> Bool {
    if let rem: SPTAppRemote = self.appRemote {
      return rem.isConnected
    }
    return false
    // return loggedIn
  }
  
  func getCurrentUser(completion: @escaping (SpotifyUser?) -> ()) {
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/me", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? "")" ]).onFinish = { (response) in
      do {
        let decoder = JSONDecoder()
        try completion( decoder.decode(SpotifyUser.self, from: response.data))
      } catch {
        fatalError("Couldn't parse \(response.description)")
      }
    }
  }
  
  func getTrackInfo(track_uri: String, completion: @escaping (SpotifyTrack?) -> ()) {
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/tracks/\(track_uri)", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? "")" ]).onFinish = { (response) in
      do {
        let decoder = JSONDecoder()
        try completion( decoder.decode(SpotifyTrack.self, from: response.data))
      } catch {
        fatalError("Couldn't parse \(response.description)")
      }
    }
  }
}

struct SpotifyUser: Codable {
  var country: String?
  var display_name: String?
  var email: String?
  var product: String?
  var uri: String?
  var images: [SpotifyImage]?
}

struct SpotifyTrack: Codable, Identifiable {
  let artists: [SpotifyArtist]?
  let disc_number: Int?
  let duration_ms: Int?
  let explicit: Bool?
  let id: String
  let name: String
  let popularity: Int?
  let track_number: Int?
  let type: String?
  let uri: String
}

struct SpotifyArtist: Codable, Identifiable {
  let id: String
  let name: String
  let uri: String
  let type: String?
}

struct SpotifyImage: Codable {
  var height: Int?
  var width: Int?
  var url: URL?
}

struct SearchResults: Codable{
    //let artists: [artistStub]?
  var tracks: trackStub?
}

struct trackStub: Codable {
  var href: String?
  var items: [songStub]?
  var limit: Int?
  var next: String?
  var offset: Int?
  var previous: String?
  var total: Int?
}

struct songStub: Codable, Identifiable{
    //let album: [album]
  var artists: [artistStub]?
  var available_markets : [String]?
  var disc_number : Int?
  var duration_ms : Int?
  var explicit: Bool?
  var href: String?
  var id: String
  var is_local: Bool?
  var name: String
  var popularity: Int?
  var preview_url: String?
  var track_number: Int?
  var type: String?
  var uri: String?
}

struct artistStub: Codable{
    //let external_ids: String // object with string maybe can do this
  var href: String?
  var id: String
  var name: String
  var type: String?
  var uri: String?
}

struct playlistStub: Codable{
  var items: [Playlist]?
  var total: Int?
}

struct Playlist: Codable{
  var collaborative: Bool?
  var description: String?
  var id: String?
  var images: [SpotifyImage]?
  var name: String?
  //var tracks: trackStub?
  var type: String?
  var uri: String?
}

/*struct trackStub {
  var href: String?
  var total: Int?
}*/
