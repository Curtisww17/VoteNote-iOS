//
//  Firestore.swift
//  VoteNote
//
//  Created by Adam Cramer on 2/3/21.
//

import Foundation
import FirebaseFirestore

class dbConnection: ObservableObject {
    //MARK: API Calls
    init() {
        
    }
}

class room{
    let name: String
    let desc: String?
    let anonUsr: Bool
    let capacity: Int
    let explicit: Bool
    let voting: Bool
    
    init(name: String, desc: String? = "", anonUsr: Bool, capacity: Int, explicit: Bool, voting: Bool) {
        self.name = name
        self.desc = desc
        self.anonUsr = anonUsr
        self.capacity = capacity
        self.explicit = explicit
        self.voting = voting
    }
}

class user{
    let name: String
    let profilePic: String
    
    init(name: String, profilePic: String){
        self.name = name
        self.profilePic = profilePic
    }
}

class song: Identifiable, ObservableObject{
    let addedBy: String
    let artist: String
    let genres: [String]
    let id: String
    let length: Int
    let numVotes: Int?
    let title: String
    //let timeStarted: Int
    
    init(addedBy: String, artist: String, genres: [String], id: String, length: Int, numVotes: Int?, title: String) {
        self.addedBy = addedBy
        self.artist = artist
        self.genres = genres
        self.id = id
        self.length = length
        self.numVotes = numVotes
        self.title = title
    }
}

func joinRoom(code: String) -> room{
    //put the user in the correct roomm
    let testRoom: room = room(name: "Placeholder room", desc: "This room is a placeholder until we connect properly to the database", anonUsr: false, capacity: 0, explicit: true, voting: true)
    //check if allowed in room
    //increase count of people in room
    
    return testRoom
}

func leaveRoom() -> Bool{
    //take the user out of the room
    return true
}

func makeRoom(newRoom: room) -> Bool{
    
    return true
}

func getQueue() -> [song]{
    let song1 = song(addedBy: "kki2j39jd", artist: "Toto", genres: ["Pop", "Rock"], id: "j288dm7", length: 760, numVotes: 10, title: "Africa")
    
    let song2 = song(addedBy: "jid984je", artist: "AC/DC", genres: ["Classic Rock", "Rock"], id: "jj3877dhe73h", length: 940, numVotes: 3, title: "Thunderstruck")
    
    let song3 = song(addedBy: "hfbve74n", artist: "Imagine Dragons", genres: ["Pop", "Electronic"], id: "88vb49m3", length: 340, numVotes: -2, title: "Believer")
    
    return [song1, song2, song3]
    
}

//get all the users for a room
func getUsers() -> [user]{
    let usr1 = user(name: "Wesley Curtis", profilePic: "www.picture.com")
    
    let usr2 = user(name: "Obama", profilePic: "www.usa.gov")
    
    let usr3 = user(name: "Joe Mama", profilePic: "www.gotcha.com")
    
    return [usr1, usr2, usr3]
}

//get individual user
func getUser(uid: String) -> user{
    let usr1 = user(name: "Wesley Curtis", profilePic: "www.picture.com")
    
    return usr1
}

//return 1 for success, 0 for song already in queue, and -1 for fail
func addsong(id: String) -> Int{
    return 1
}

//used to get details like who posted the song
func getSong(id: String) -> song{
    let song1 = song(addedBy: "kki2j39jd", artist: "Toto", genres: ["Pop", "Rock"], id: "j288dm7", length: 760, numVotes: 10, title: "Africa")
    
    return song1
}

//need to make sure user is allowed at some point
func vetoSong(id: String){
    
}

//1 upvote, -1 downvote, 0 clear vote?
//returns new vote number
func voteSong(vote: Int) -> Int{
    return 8
}
