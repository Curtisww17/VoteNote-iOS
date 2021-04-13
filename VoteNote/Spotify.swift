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
  
  private var httpRequester: HttpRequester
  
  //is empty if the user is not joining through link, otherwise its the room code
  @Published var isJoiningThroughLink: String
  
  //objects where data requested from spotify api goes into so app can reference it locally
  var currentUser: SpotifyUser?
  var recentSearch: SpotifySearchResults?
  var userPlaylists: _spotifyPlaylists?
  var currentPlaylist: uniquePlaylist?
  var usersSavedSongs: playlistTrackTime?
  var recommendedSongs: reccomndations?
  var savePlaylist: uniquePlaylist?
  var PlaylistBase: uniquePlaylist?
  var songGenres: currentArtists?
  
  var genreList: genres?
  var songTimer: Int = 0
  
  var sessionManager: SPTSessionManager?
  var appRemote: SPTAppRemote?
  
  
  //scopes that we request access for, add more as needed
  let SCOPES: SPTScope = [ .userReadRecentlyPlayed, .userTopRead, .streaming, .userReadEmail, .appRemoteControl, .playlistModifyPrivate, .playlistModifyPublic, .playlistReadPrivate, .userModifyPlaybackState, .userReadPlaybackState, .userReadCurrentlyPlaying, .userLibraryRead, .userLibraryModify, .userReadPrivate]
  
  @Published var loggedIn: Bool
  @Published var isAnon: Bool
  @Published var anon_name: String
  @Published var isPaused: Bool?
  @Published var currentlyPlaying: SpotifyTrack?
  @Published var currentlyPlayingPos: Int?
  @Published var currentlyPlayingPercent: Float?
  
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
  
  func updateCurrentlyPlayingPosition() {
//    self.appRemote?.playerAPI?.getPlayerState( { (playStateMaybe, err) in
//      if err != nil {
//        if let playState = playStateMaybe as? SPTAppRemotePlayerState {
//          self.currentlyPlayingPos = playState.playbackPosition
//          self.currentlyPlayingPercent = (Float)(self.currentlyPlayingPos!) / (Float)(self.currentlyPlaying!.duration_ms ?? 100000)
//        }
//
//
//      }
//    })
    self.currentlyPlayingPercent = (Float)(self.currentlyPlayingPos ?? 0) / (Float)(self.currentlyPlaying?.duration_ms ?? 100000)
  }
  
  //pauses spotify player
  func pause() {
    self.appRemote?.playerAPI?.pause({ (_, error) in
      if error != nil {
        print(error as Any)
      }
    })
  }
  
  //resumes spotify player
  func resume(){
    print("playing song")
    self.appRemote?.playerAPI?.resume({ (_, error) in
      if (error != nil) {
        print(error as Any)
      }
    })
  }
  
  
  //enqueues song specified to spotify queue for the current user
  func enqueue(songID: String, completion: @escaping () -> () ){
    self.appRemote?.playerAPI?.enqueueTrackUri("spotify:track:"+songID, callback: { (_, error) in
      if (error != nil) {
        print(error as Any)
      }
      completion()
    }
    )
  }
  
  //skips current song being played and starts playing enqueued song
  func skip(){
    self.appRemote?.playerAPI?.skip(toNext: { (_, error) in
      print(error as Any)
    })
  }
  
  //returns the state that the spotify player is in
  func getPlayerState(){
    self.appRemote?.playerAPI?.getPlayerState({ (_, error) in
      print(error as Any)
    })
  }
  
  //requests spotify for a list of songs given a query (can be song or artist)
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
  
  //requests spotify for list of current user's playlists
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
      //RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
    
    }
  
  //requests songs that are in a specific playlist
  func playlistSongs(completion: @escaping (uniquePlaylist?) -> (), id: String) -> (){
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/playlists/\(id)", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
      (response) in
      do {
        print(response.description)
        let decoder = JSONDecoder()
        try completion( decoder.decode(uniquePlaylist.self, from: response.data))
      } catch {
        fatalError("Couldn't parse \(response.description)")
      }
    }
  }
  
  //requests the saved/liked songs that the user has
  func savedSongs(completion: @escaping (playlistTrackTime?) -> ()) -> (){
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/me/tracks", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
      (response) in
      do {
        let decoder = JSONDecoder()
        try completion( decoder.decode(playlistTrackTime.self, from: response.data))
      } catch {
        fatalError("Couldn't parse \(response.description)")
      }
    }
  }
  
  //requests spotify for songs recommeneded based on artist, genre, and songs
  func recomendations(artistSeed: String, trackSeed: String,completion: @escaping (reccomndations?) -> ()) ->() {
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/recommendations?limit=10&seed_genres=\(artistSeed)&seed_tracks=\(trackSeed)", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
      (response) in
      do {
        let decoder = JSONDecoder()
        try completion( decoder.decode(reccomndations.self, from: response.data))
      } catch {
        fatalError("Couldn't parse \(response.description)")
      }
    }
  }
  
  func getGenreList(completion: @escaping (genres?) -> ()) -> (){
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/recommendations/available-genre-seeds", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
      (response) in
      do {
        //print(" testingssdssds \(response.description)")
        let decoder = JSONDecoder()
        try completion( decoder.decode(genres.self, from: response.data))
      } catch {
        fatalError("Couldn't parse \(response.description)")
      }
    }
  }
  
  func addSongsToPlaylist(Playlist: String, songs: [song]){
    var songData = ""
    for song in songs{
      songData += "spotify:track:"+song.id+","
    }
    
    songData.dropLast()
    let header = ["Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? "")" ]
    let url = "https://api.spotify.com/v1/playlists/\(Playlist)/tracks?uris=\(songData)"
    
    
    var request = URLRequest(urlString: url, headers: header)
    request?.httpMethod = "POST"
    let task = URLSession.shared.dataTask(with: request ?? URLRequest(url: URL(string: url)!)) { data, response, error in
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJSON = responseJSON as? [String: Any] {
            
        }
    }
    task.resume()
  }
  
  func createPlaylist(id: String){
    // prepare json data

    let json: [String: Any] = [
      "name": RoomName+" Playlist",
      "description": "Made by VoteNote",
      "public": false
    ]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)
    let header = ["Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? "")" ]

    // create post request
    let url = "https://api.spotify.com/v1/users/\(id)/playlists"
    //var request = URLRequest(url: url, headers: header)
    var request = URLRequest(urlString: url, headers: header)
    request?.httpMethod = "POST"

    // insert json data to the request
    request?.httpBody = jsonData

    let task = URLSession.shared.dataTask(with: request ?? URLRequest(url: URL(string: url)!)) { data, response, error in
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJSON = responseJSON as? [String: Any] {
            
        }
    }

    task.resume()
  }
  
  //adds specified to users liked/saved songs
  func likeSong(id: String){
    self.httpRequester.headerPUT(url: "https://api.spotify.com/v1/me/tracks?ids=\(id)",header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
      (response) in
      do{
        print("\(response.description)")
      } catch {
        fatalError("bad response \(response.description)")
      }
    }
  }
  func unLikeSong(id: String){
      self.httpRequester.headerDELETE(url: "https://api.spotify.com/v1/me/tracks?ids=\(id)",header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? ""))" ]).onFinish = {
        (response) in
        do{
          print(response.description)
        } catch {
          fatalError("bad response \(response.description)")
        }
      }
    }
  func isSongFavorited(songID: String) -> Bool{
      if(self.usersSavedSongs == nil){
        self.savedSongs(completion: {playlistSongs in self.usersSavedSongs = playlistSongs})
      }
      for song in self.usersSavedSongs?.items ?? [songTimeAdded(track: SpotifyTrack(album: nil, id: "", name: ""))] {
        if(song.track.id == songID){
          return true
        }
      }
      return false
    }
  
  
  
  //reutnrs the current spotify user
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
  
  //gets information on a song based of off a song uri
  func getTrackInfo(track_uri: String, completion: @escaping (SpotifyTrack?) -> ()) {
    var track_id = track_uri
    
    
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/tracks/\(track_id)", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? "")" ]).onFinish = { (response) in
      do {
        let decoder = JSONDecoder()
        try completion( decoder.decode(SpotifyTrack.self, from: response.data))
      } catch {
        print(track_id)
        //fatalError("Couldn't parse \(response.description)")
      }
    }
  }
  
  func getSongGenre(artistID: String, completion: @escaping (currentArtists?) -> ()){
    self.httpRequester.headerGet(url: "https://api.spotify.com/v1/artists?ids=\(artistID)", header: [ "Authorization": "Bearer \(self.appRemote?.connectionParameters.accessToken ?? "")" ]).onFinish = { (response) in
      do {
        let decoder = JSONDecoder()
        try completion( decoder.decode(currentArtists.self, from: response.data))
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
  var genres: [String]?
}

struct _spotifyPlaylists: Codable{
  var items: [Playlist]?
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
  var track: SpotifyTrack
  
}

struct currentArtists: Codable{
  var artists: [currentGenres]
}

struct currentGenres: Codable{
  var genres: [String]?
  var id: String
}

struct reccomndations: Codable{
  var tracks: [SpotifyTrack]
}

struct genres: Codable{
  var genres: [String]
}
