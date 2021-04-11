//
//  Firestore.swift
//  VoteNote
//
//  Created by Adam Cramer on 2/3/21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

///Generates a random string containing capitol letters and numbers
///
///credit for this function to [iAhmed](https://stackoverflow.com/a/26845710)
///
///- Parameter length: the length of the string to be generated
///
///
func randomString(length: Int) -> String {
    
    let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}


let db = Firestore.firestore()
let FAuth = Auth.auth()

//MARK: Data objects

class room{
    let name: String
    let desc: String?
    let anonUsr: Bool   //do we anonymize users?
    let capacity: Int   //capacity of the room
    let explicit: Bool  //do we allow explicit songs
    let voting: Bool    //is voting enabled
    let queue: [song]
    let code: String    //the room code, used for joining
    let spu: Int    //songs per user
    let playlist: String //playlist id thing
    let host: String //uid of the host
    let genres: [String] //the allowwed genres
    let closed: Bool //whether or not the room is open/active
    let bannedUsers: [String]? //a list of all the users who are banned from the room
    let currSong: String
    
    //normal constructor
    init(name: String, desc: String? = "", anonUsr: Bool, capacity: Int, explicit: Bool, voting: Bool, spu: Int = -1, playlist: String? = nil, host: String = FAuth.currentUser!.uid, genres: [String]? = [], closed: Bool? = false, bannedUsers: [String]? = [], currSong: String = "") {
        self.name = name
        self.desc = desc
        self.anonUsr = anonUsr
        self.capacity = capacity
        self.explicit = explicit
        self.voting = voting
        queue = []
        code = ""
        self.spu = spu
        self.playlist = playlist ?? ""
        self.host = host
        self.genres = genres ?? []
        self.closed = closed ?? false
        self.bannedUsers = bannedUsers
        self.currSong = currSong
    }
    
    //constructor for firestore
    init(rm: [String: Any]) {
        self.name = rm["name"] as! String
        self.desc = rm["desc"] as? String
        self.anonUsr = rm["anonUsr"] as! Bool
        self.capacity = rm["capacity"] as! Int
        self.explicit = rm["explicit"] as! Bool
        self.voting = rm["voting"] as! Bool
        queue = [] //need to grab this as well once properly implemented
        code = rm["code"] as! String
        spu = rm["spu"] as? Int ?? -1
        playlist = rm["playlist"] as? String ?? ""
        host = rm["host"] as? String ?? ""
        genres = rm["genres"] as? [String] ?? []
        closed = rm["closed"] as? Bool ?? false
        bannedUsers = rm["bannedUsers"] as? [String]
        currSong = rm["currSong"] as? String ?? ""
    }
}

class user: Identifiable, ObservableObject {
    var name: String
    var profilePic: String //link to pfp
    var isAnon: Bool?       //is the user anonymized
    var anon_name: String  //the user's anonymous name
    var uid: String?
    
    //TODO: refactor this out
    init(name: String, profilePic: String){
        self.name = name
        self.profilePic = profilePic
        isAnon = false
        anon_name = ""
        uid = nil
    }
    
    //default
    init(name: String, profilePic: String, isAnon: Bool, anon_name: String){
        self.name = name
        self.profilePic = profilePic
        self.isAnon = isAnon
        self.anon_name = anon_name
        uid = nil
    }
    
    //for firestore
    init(usr: [String: Any]){
        name = usr["name"] as! String
        profilePic = usr["profilePic"] as! String
        isAnon = usr["isAnon"] as? Bool ?? false
        anon_name = usr["anon_name"] as? String ?? ""
        uid = usr["uid"] as? String
    }
}

class song: Identifiable, ObservableObject{
    let addedBy: String //UID of who added it
    let artist: String?  //String of all credited artsts, sperated by spaces
    let genres: [String]
    let id: String  //spotify id of the song
    let length: Int? //length in ms
    let numVotes: Int?  //nuber of votes recived by the song
    let title: String?   //name of the song
    let imageUrl: String
    //let timeStarted: Int
    init(addedBy: String, artist: String, genres: [String], id: String, length: Int, numVotes: Int?, title: String, imageUrl: String) {
        self.addedBy = addedBy
        self.artist = artist
        self.genres = genres
        self.id = id
        self.length = length
        self.numVotes = numVotes
        self.title = title
        self.imageUrl = imageUrl
    }
    
    //firestore
    init(sng: [String: Any], id: String){
        addedBy = sng["addedBy"] as? String ?? ""
        artist = sng["artist"] as? String
        genres = []
        self.id = id
        length = sng["length"] as? Int
        numVotes = sng["numvotes"] as? Int
        title = sng["title"] as? String
        imageUrl = sng["imageurl"] as? String ?? ""
    }
    
}

//gets the string code for the user's current room
/**
 Gets the string code for the current room, returns `""` if they aren't in a room
 
 - Parameter completion: completion handler to return the asynchronous call
 */
func getCurrRoom(completion: @escaping (String, Error?) -> Void){
    var currRoom = ""
    //get the user's document using firebase auth
    db.collection("users").document(FAuth.currentUser!.uid).getDocument { (res, err) in
        //grab the value for current room
        currRoom = res?.data()?["currentRoom"] as? String ?? ""
        completion(currRoom, nil)
    }
    //return currRoom
}

//MARK: API Calls

/**
 signs the user into firebase
 
 - Parameter name: the name of the user
 */
func firebaseLogin(name: String){
    FAuth.signInAnonymously { (result, err) in
        if let err = err {
            //there was an error making the user
            print(err.localizedDescription)
        }
        else{
            //user created successfully
            //make a user document
            //TODO: add pfp
            db.collection("users").document(result!.user.uid).setData( [
                "name":  name,
                "profilePic": "https://i.pinimg.com/474x/be/80/75/be8075c3043965030d69e8bccf2b5c5c.jpg",
                //"isAnon": false//,
                //"anon_name": ""
            ], merge: true)
        }
    }
}


//MARK: Room
/**
 Put the user in the room referenced by code
 
 - Parameter code: the code of the room to join (not case sensitive)
 */
func joinRoom(code: String, completion:@escaping (room?, String?) -> Void){
    //put the user in the correct room
    //TODO: add checking for capacity
    
    let upperCode = code.uppercased()
    currentQR.update(roomCode: upperCode)
    
    //get UID from firebase auth
    let usr = FAuth.currentUser
    
    
    db.collection("room").document(upperCode).getDocument(completion: { (doc, err) in
        if let err = err{
            print("err gerring documents \(err)")
            completion(nil, err.localizedDescription)
        }
        else{
            //put the user in the room
            db.collection("users").document(usr!.uid).updateData(["currentRoom": upperCode])
            //increase count of people in room
            
            //if joining a nonexistent room this will crash rn
            //TODO: fix this crash
            let rm = doc?.data()
            
            //check if banned
            for u in (rm?["bannedUsers"] as? [String] ?? []){
                if u == usr?.uid {
                    //tell them they cannot join the room
                    completion(nil, "You are banned from this room")
                }
            }
            if (rm?["closed"] as? Bool ?? false){
                completion(nil, "This room is closed")
            }
            completion(room(rm: rm!), nil)
        }
        
    })
    
}

/**
 stores a room in the users previous rooms
 
 - Parameter code: the code of the room to store
 */
func storePrevRoom(code: String){
    let uid = FAuth.currentUser?.uid
  
    let upperCode = code.uppercased()
    
    
    let joiningQuery = db.collection("room").whereField("code", isEqualTo: upperCode)
    
    joiningQuery.getDocuments() { (query, err) in
        if let err = err{
            print("err gerring documents \(err)")
        }
        else if query!.isEmpty { //make sure the querey returns a room
            print("err")
        } else {
            
            let rm = query?.documents[0]
            
            
            
            //if we didn't find the document
            if rm?.documentID == nil{
                print("error storing previous room")
            } else {
                let isHost: Bool;
                if rm!.data()["host"] as? String ?? "" == uid! {
                    isHost = true
                } else {isHost = false}
                db.collection("users").document(uid!).collection("prevRooms").document(upperCode).setData(["code": upperCode , "time": FieldValue.serverTimestamp(), "isHost": isHost])
            }
            
        }
        
    }//end joiningquerey
}


/**
 get the rooms that have previously been joined by the current
 
 */
func getPrevJoinedRooms(completion: @escaping ([String]?, Error?) -> Void){
    let uid = FAuth.currentUser?.uid
    
    let  docRef = db.collection("users").document(uid!).collection("prevRooms").order(by: "time")
    
    docRef.getDocuments { (docs, err) in
        if let err = err {
            completion(nil, err)
        } else {
            var rooms: [String] = []
            
            for doc in docs!.documents {
                //if they did not host the room
                if !(doc.data()["isHost"] as? Bool ?? true) {
                  let id = doc.data()["code"] as? String ?? ""
                    rooms.append(id)
                    
                }
            }
            completion(rooms, nil)
            
        }
    }
}

/**
 get the rooms the user has previously hosted
 */
func getPrevHostedRooms(completion: @escaping ([String]?, Error?) -> Void){
    let uid = FAuth.currentUser?.uid
    
    let  docRef = db.collection("users").document(uid!).collection("prevRooms").order(by: "time")
    
    docRef.getDocuments { (docs, err) in
        if let err = err {
            completion(nil, err)
        } else {
            var rooms: [String] = []
            
            for doc in docs!.documents {
                //if they hosted this room
                if (doc.data()["isHost"] as? Bool ?? false) {
                    let id = doc.data()["code"] as? String ?? ""
                    rooms.append(id)
                    
                }
            }
            completion(rooms, nil)
            
        }
    }
}


/**
 Get the room referenced by code
 
 to get the current room use the code from getCurrRoom
 
 - Parameter code: the code of the room you want to get
 */
func getRoom(code: String, completion: @escaping (room?, Error?) -> Void){
    
    if code == "" {
        print("getRoom was called with no code given")
        completion(nil, nil)
    } else {
    
    db.collection("room").document(code).getDocument { (doc, err) in
        if let err = err{
            print("err gerring documents \(err)")
            completion(nil, err)
        }
        else if !(doc?.exists ?? false) { //make sure the querey returns a room
            enum newError: Error {
                case documentError(String)
            }
            completion(nil, newError.documentError("no room with that code could be found"))
        } else {
            
            let rm = doc?.data()
            
            
            //return the room
            completion(room(rm: rm!), nil)
        }
    }
    }
    
    
    
}

///makes the user leave the room
func leaveRoom() -> Bool{
    //take the user out of the room
    let usr = FAuth.currentUser
    db.collection("users").document(usr!.uid).updateData(["currentRoom": ""])
    
    return true
}

///set the current room to closed
func closeRoom(){
  db.collection("room").document(currentQR.roomCode).updateData(["closed": true])
}

///set the current room to open
func openRoom(){
    getCurrRoom { (code, err) in
        db.collection("room").document(code).updateData(["closed": false])
    }
}

/**
 Set the currently playing song
 
 - Parameter id: the spotify id of the song
 */
func setCurrSong(id: String){
    getCurrRoom { (code, err) in
        db.collection("room").document(code).updateData(["currSong": id])
    }
}

/**
 makes a new room in the db from a room obj
 
 - Parameter newRoom: a room object which will be used to make a new room
 */
func makeRoom(newRoom: room) -> String{
    let code: String
    let usr = FAuth.currentUser
    
    //randomy generate a code if the room doesn't have one
    //TODO: make sure no other room with code exists
    if newRoom.code == "" {
        code = randomString(length: 5)
    } else{
        code = newRoom.code
    }
  
  
  currentQR.update(roomCode: code.uppercased())
    
    //make the room in the db
    db.collection("room").document(code).setData([
                                        "name": newRoom.name,
                                        "desc": newRoom.desc ?? "",
                                        "anonUsr": newRoom.anonUsr,
                                        "capacity": newRoom.capacity,
                                        "explicit": newRoom.explicit,
                                        "voting": newRoom.voting,
                                        "code": code,
                                        "spu": newRoom.spu,
                                        "playlist": newRoom.playlist,
                                        "host": newRoom.host,
                                        "genres": newRoom.genres,
                                        "closed": newRoom.closed,
                                        "bannedUsers": newRoom.bannedUsers])
    
    //put the user who made the room into the room
    db.collection("users").document(usr!.uid).updateData(["currentRoom": code])
    //this will need to be modified to allow for adding a room with a queue
    return code
}



//MARK: Users
/**
 sets the anon name of the current user
 
 - Parameter name: the anonymous name to be set
 */
func setAnonName(name: String){
    let uid = FAuth.currentUser!.uid
    
    db.collection("users").document(uid).updateData(["anon_name": name])
    
}

/**
 sets the user to anon or not
 
 - parameter isAnon: whether or not the user is anonymous
 */
func setAnon(isAnon: Bool){
    let uid = FAuth.currentUser!.uid
    
    db.collection("users").document(uid).updateData(["isAnon": isAnon])
    
}

///get all the users for the current room
func getUsers(completion: @escaping ([user]?, Error?) -> Void){
    
    var users: [user] = []
    
    getCurrRoom { (code, err) in
        
        getRoom(code: code) { (currRoom, err) in
            if currRoom == nil {
                print("no Room found for getUsers")
            } else {
                //find all users that have their currentRoom set = to the current room
                let usrQuery = db.collection("users").whereField("currentRoom", isEqualTo: code)
                
                usrQuery.getDocuments() { (query, err) in
                    
                    if let err = err{
                        print("err gerring documents \(err)")
                        completion(nil, err)
                    }
                    else{
                        //iterate through user documents and get their data
                        for usr in query!.documents{
                            var usrdata = usr.data()
                            usrdata["uid"] = usr.documentID
                            let newusr = user(usr: usr.data())
                            if (newusr.isAnon != nil) {
                                if newusr.isAnon! {
                                    newusr.name = newusr.anon_name
                                }
                            }
                            if (currRoom!.anonUsr) {
                                newusr.name = newusr.anon_name
                            }
                          newusr.uid = usr.documentID
                            users.append(newusr)
                        }
                        completion(users, nil)
                    }
                }
                
            }
            
        }
    }//end getCurrRoom
}

/**
 get individual user by id
 
 - Parameter uid: the uid of the user that we want to get
 */
func getUser(uid: String, completion: @escaping (user?, Error?) -> Void){
    
    getCurrRoom { (code, err) in
        getRoom(code: code) { (currentRoom, error_thing) in
            db.collection("users").document(uid).getDocument { (res, err) in
                if let err = err {
                    print("err gerring documents \(err)")
                    completion(nil, err)
                } else if res!.data() != nil {
                    let newusr = user(usr: res!.data()!)
                    if (newusr.isAnon != nil) {
                        if newusr.isAnon! {
                            newusr.name = newusr.anon_name
                        }
                    }
                    if (currentRoom?.anonUsr ?? false) {
                        newusr.name = newusr.anon_name
                    }
                    completion(newusr, nil)
                    
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
}

///gets the current users UID
func getUID() -> String{
    return FAuth.currentUser!.uid
}

/**
 bans a user from the room permanently
 
 - Parameter uid: the id of the user to be banned
 */
func banUser(uid: String){
    getCurrRoom { (currRoom, err) in
        
        //append the uid to the banned user array
        //TODO: figure out how to tell the user they have been kicked
        db.collection("room").document(currRoom).updateData(["bannedUsers" : FieldValue.arrayUnion([uid])])
        
    }
}

/**
 Gets all the votes a user has made
 
 - Returns a dictionary mapping song id's to their vote value
 */
func getVotes(completion: @escaping ([String : Int]?, Error?) -> Void){
    let currUser = FAuth.currentUser?.uid ?? ""
    
    db.collection("users").document(currUser).collection("votes").getDocuments { (docs, err) in
        if let err = err {
            print("err getting votes \(err)")
            completion(nil, err)
        } else if docs?.isEmpty ?? true {
            completion(nil, nil)
        } else {
            var list: [String: Int] = [:]
            for doc in docs!.documents {
                list[doc.documentID] = doc.data()["vote"] as? Int ?? 0
            }
            completion(list, nil)
        }
    }
}

//MARK: Song
/**
 add a song to the current room by the song id
 
 - Parameter id: the spotify id of the song to be added
 */
func addsong(id: String, completion: @escaping () -> () ){

    
    //TODO: get album art stuff
    //TODO: check for songs per user limit
    //TODO: get explicit
    getCurrRoom { (currRoom, err) in
        
        
        
        //get the track deets
        sharedSpotify.getTrackInfo(track_uri: id) { (track) in
            let addedBy = FAuth.currentUser!.uid
            var length = 0
            var title = ""
            var artist = ""
            var imageUrl = ""
            
            if track != nil{
                
                for art in track!.artists! {
                    artist += art.name + " "
                }
                length = (track?.duration_ms)!
                title = track!.name
                imageUrl = track?.album?.images?[0].url ?? ""
            }
            
            
            //add the song to the queue
            db.collection("room").document(currRoom).getDocument { (doc, err) in
                if let err = err, !(doc?.exists ?? false) {
                    print("Error getting room \(err)")
                }else {
                    //make a map to put into the db
                    let sng = ["title": title,
                               "artist": artist,
                               "length": length,
                               "addedBy": addedBy,
                               "imageurl": imageUrl,
                               "numvotes": 0,
                               "time": FieldValue.serverTimestamp()] as [String : Any]
                    
                    //put the map into the queue
                    db.collection("room").document(currRoom).collection("queue").document(id).setData(sng)
                }
              completion()
            }
        }//end sharedSpotify
    }//end currRoom
    
    
}



/**
 removes a song from the queue and puts it into the history
 
 - parameter id: the id of the song to be dequeued
 */
func dequeue(id: String){
    
    //first we get the song in doc form
    getCurrRoom { (currRoom, err) in
        
        
        //grab the room
        let rm = db.collection("room").document(currRoom)
        
        //grab the song from the queue
        rm.collection("queue").document(id).getDocument { (doc, err) in
            //confirm we got a document
            if let err = err, !(doc?.exists ?? false){
                print("error finding queue in dequeue \(err)")
            } else {
                //store the song
                var sng = doc!.data()!
                sng["time"] = FieldValue.serverTimestamp()
                
                //delete the song from the queue
                rm.collection("queue").document(id).delete()
                
                //put the song into history
                rm.collection("history").document(id).setData(sng)
            }
        }//end queue
    }//end getCurrRoom
}


/**
 removes a song from the current rooms queue without moving it to history
 
 - Parameter id: the id of the song that is to be removed
 */
func vetoSong(id: String){
    
    getCurrRoom { (currRoom, err) in
        
            
        let rm = db.collection("room").document(currRoom)
            
        rm.collection("queue").document(id).delete()
        
        
        
        
    }//end getCurrRoom
}


/**
 allows a user to vote on a song
 
 1 for upvote -1 for downvote
 
 - Parameters:
 - vote: the vote of the song 1 for up, -1 for down
 - id: the id of the song to be voted on
 */
func voteSong(vote: Int, id: String, completion: @escaping  () -> ()){
    getCurrRoom { (currRoom, err) in
        let currUser = FAuth.currentUser!.uid
        
        db.collection("users").document(currUser).collection("votes").document(id).getDocument { (doc, err) in
            let queue = db.collection("room").document(currRoom).collection("queue")
            if let err = err {
                print("error getting user document \(err)")
                completion()
            } else if !(doc?.exists ?? false) {
                //we havent voted on this song yet
                db.collection("users").document(currUser).collection("votes").document(id).setData(["vote": vote])
                queue.document(id).updateData(["numvotes": FieldValue.increment(Int64(vote))])
                completion()
            } else {
                let v = doc?.data()?["vote"] as? Int ?? 9 //9 is magic number to tell us its invalid
                
                if v == 9 {
                    print("error gettign previous vote value")
                    completion()
                }else if v == vote {
                    //cancel out the vote
                    if v == 1 {
                        queue.document(id).updateData(["numvotes": FieldValue.increment(Int64(-1))])
                        db.collection("users").document(currUser).collection("votes").document(id).setData(["vote": 0])
                        completion()
                    } else {
                        queue.document(id).updateData(["numvotes": FieldValue.increment(Int64(1))])
                        db.collection("users").document(currUser).collection("votes").document(id).setData(["vote": 0])
                        completion()
                    }
                    
                }else if v == 0 {
                    queue.document(id).updateData(["numvotes": FieldValue.increment(Int64(vote))])
                    db.collection("users").document(currUser).collection("votes").document(id).setData(["vote": vote])
                    completion()
                } else if v == 1 {
                    queue.document(id).updateData(["numvotes": FieldValue.increment(Int64(-2))])
                    db.collection("users").document(currUser).collection("votes").document(id).setData(["vote": -1])
                    completion()
                } else {
                    queue.document(id).updateData(["numvotes": FieldValue.increment(Int64(2))])
                    db.collection("users").document(currUser).collection("votes").document(id).setData(["vote": 1])
                    completion()
                }
            }
        }
        
        let queue = db.collection("room").document(currRoom).collection("queue")
        
        queue.document(id).updateData(["numvotes": FieldValue.increment(Int64(vote))])
        completion()
        
    }//end getCurrRoom
}

/**
 get the queue from the current room
 */
func getQueue(completion: @escaping ([song]?, Error?) -> Void){
    
    getCurrRoom { (currRoom, err) in
        
        db.collection("room").document(currRoom).collection("queue").order(by: "time").getDocuments { (queue, err) in
            if let err = err, queue?.isEmpty ?? true{
                print("error getting queue \(err)")
                completion(nil, err)
            } else {
                var songs: [song] = []
                
                for doc in queue!.documents {
                    songs.append(song(sng: doc.data() , id: doc.documentID))
                }
                completion(songs, nil)
            }
        }
    }//end getCurrRoom
    
    
}

/**
 get the history from the current room
 */
func getHistory(completion: @escaping ([song]?, Error?) -> Void){
    
    getCurrRoom { (currRoom, err) in
        
        
        db.collection("room").document(currRoom).collection("history").order(by: "time").getDocuments { (hist, err) in
            if let err = err{
                print("error getting history \(err)")
                completion(nil, err)
            } else if hist?.isEmpty ?? true{
                print("history is empty")
                completion(nil, nil)
            }else {
                var songs: [song] = []
                
                for doc in hist!.documents {
                    songs.append(song(sng: doc.data() , id: doc.documentID))
                }
                completion(songs, nil)
            }
        }
        
    }//end getCurrRoom
    
    
}
