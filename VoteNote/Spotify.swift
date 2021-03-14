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
  
  private var httpRequester: HttpRequester
  
  //is empty if the user is not joining through link, otherwise its the room code
  @Published var isJoiningThroughLink: String
  
  var currentUser: SpotifyUser?
  var recentSearch: SpotifySearchResults?
  var userPlaylists: _spotifyPlaylists?
  
  var sessionManager: SPTSessionManager?
  var appRemote: SPTAppRemote?
  
  
  //scopes that we request access for, add more as needed
  let SCOPES: SPTScope = [ .userReadRecentlyPlayed, .userTopRead, .streaming, .userReadEmail, .appRemoteControl, .playlistModifyPrivate, .playlistModifyPublic, .playlistReadPrivate, .userModifyPlaybackState, .userReadPlaybackState, .userReadCurrentlyPlaying]
  
  @Published var loggedIn: Bool
  @Published var isAnon: Bool
  @Published var anon_name: String
  
  
  init() {
    self.loggedIn = false
    httpRequester = HttpRequester()
    self.isJoiningThroughLink = ""
    self.isAnon = false;
    self.anon_name = ""
  }
  //login through the spotify ios api
  func login(){
    self.sessionManager?.initiateSession(with: SCOPES, options: .default)
    self.loggedIn = true
  }
  
  //logout of spotify
  func logout(){
    self.appRemote?.playerAPI?.pause(nil)
    self.appRemote?.disconnect()
    self.loggedIn = false
    UserDefaults.standard.removeObject(forKey: "access-token-key")
  }
  
  //sets isAnon and anon_name to reflect the values stored in the db
  func initializeAnon() {
    getUser(uid: getUID()) { (user, err) in
      if (err != nil) {
        print(err!)
      } else if user != nil {
        if user!.isAnon != nil {
          self.isAnon = user!.isAnon!
        } else {
          setAnon(isAnon: false)
          self.isAnon = false
        }
        if user!.anon_name == "" {
          let newName = generateAnonName()
          setAnonName(name: newName)
          self.anon_name = newName
        } else {
          self.anon_name = user!.anon_name
        }
        
      }
      
    }
  }
  
  func pause() {
    self.appRemote?.playerAPI?.pause({ (_, error) in
      print(error as Any)
    })
  }
  
  func resume(){
    self.appRemote?.playerAPI?.resume({ (_, error) in
      print(error as Any)
    })
  }
  
  func enqueue(songID: String){
    self.appRemote?.playerAPI?.enqueueTrackUri("spotify:track:"+songID, callback: { (_, error) in
      print(error as Any)
    })
  }
  
  func skip(){
    self.appRemote?.playerAPI?.skip(toNext: { (_, error) in
      print(error as Any)
    })
  }
  
  //includes 
  func getPlayerState(){
    self.appRemote?.playerAPI?.getPlayerState({ (_, error) in
      print(error as Any)
    })
  }
  
  func searchSong(completion: @escaping (SpotifySearchResults?) -> (), Query: String, limit: String, offset:String){
    self.httpRequester.headerParamGet(url: "https://api.spotify.com/v1/search", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ], param: ["q" : Query, "type": "track,artist", "limit": limit]).onFinish = {
      (response) in
        do {
          let decoder = JSONDecoder()
          try completion( decoder.decode(SpotifySearchResults.self, from: response.data))
        } catch {
          fatalError("Couldn't parse \(response.description)")
        }
    }
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
  }
  
    func userPlaylists(completion: @escaping (_spotifyPlaylists?) -> (), limit: String){
      self.httpRequester.headerGet(url: "https://api.spotify.com/v1/me/playlists", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
        (response) in
          do {
            let decoder = JSONDecoder()
            try completion( decoder.decode(_spotifyPlaylists.self, from: response.data))
          } catch {
            fatalError("Couldn't parse \(response.description)")
          }
      }
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
      
      //print("!!!!"+(self.userPlaylists?.items?[0].name ?? ""))
    }
  
  func playlistSongs(completion: @escaping (uniquePlaylist?) -> (), id: String) -> (){
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/playlists/\(id)", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
      (response) in
      do {
        let decoder = JSONDecoder()
        try completion( decoder.decode(uniquePlaylist.self, from: response.data))
      } catch {
        fatalError("Couldn't parse \(response.description)")
      }
    }
  }
  
  func savedSongs(completion: @escaping (uniquePlaylist?) -> ()) -> (){
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/me/tracks", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
      (response) in
      do {
        let decoder = JSONDecoder()
        try completion( decoder.decode(uniquePlaylist.self, from: response.data))
      } catch {
        fatalError("Couldn't parse \(response.description)")
      }
    }
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

/*
    A collection of codable objects for parsing out JSON results from the spotifyAPI
 */

struct SpotifyUser: Codable {
  var country: String?
  var display_name: String?
  var email: String?
  var product: String?
  var uri: String?
  var id: String
  var images: [SpotifyImage]?
}

struct SpotifyTrack: Codable, Identifiable {
  let album: SpotifyAlbum?
  var artists: [SpotifyArtist]?
  var available_markets : [String]?
  var disc_number : Int?
  var duration_ms : Int?
  var explicit: Bool?
  var images: [SpotifyImage]?
  var href: String?
  var id: String
  var name: String
  var popularity: Int?
  var preview_url: String?
  var track_number: Int?
  var type: String?
  var uri: String?
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
  var url: String
}

struct SpotifySearchResults: Codable{
  var tracks: _spotifyTrack?
}

struct _spotifyTrack: Codable {
  var href: String?
  var items: [SpotifyTrack]?
  var limit: Int?
  var next: String?
  var offset: Int?
  var previous: String?
  var total: Int?
}


struct SpotifyAlbum: Codable, Identifiable {
  var id: String
  var images: [SpotifyImage]?
}

struct _spotifyPlaylists: Codable{
  var items: [SpotifyPlaylist]?
  var total: Int?
}

struct Playlist: Codable, Identifiable{
  var description: String?
  var id: String
  var images: [SpotifyImage]?
  var name: String?
  var type: String?
  var uri: String?
}

struct uniquePlaylist: Codable, Identifiable{
  var collaborative: Bool?
  var description: String?
  var href: String?
  var id: String
  var name: String?
  var images: [SpotifyImage]?
  var owner: SpotifyUser?
  var tracks: playlistTrackTime?
}

struct playlistTrackTime: Codable{
  var href: String?
  var items: [songTimeAdded]?
}

struct songTimeAdded: Codable{
  //var id = UUID()
  //var added_at: String
  var track: songStub
  
}
