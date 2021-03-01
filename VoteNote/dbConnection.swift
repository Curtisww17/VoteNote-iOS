//
//  Firestore.swift
//  VoteNote
//
//  Created by Adam Cramer on 2/3/21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/* class stub cause patrick said we can't access funtions inside a class
class dbConnection: ObservableObject {
    
    init() {
        
    }
}*/

//credit for this function to https://stackoverflow.com/a/26845710
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


//we should probably bring this all back under one class
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
    //need to add songs per user and allowed genres
    
    //normal constructor
    init(name: String, desc: String? = "", anonUsr: Bool, capacity: Int, explicit: Bool, voting: Bool) {
        self.name = name
        self.desc = desc
        self.anonUsr = anonUsr
        self.capacity = capacity
        self.explicit = explicit
        self.voting = voting
        queue = []
        code = ""
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
    }
}

class user: Identifiable {
    let name: String
    let profilePic: String //link to pfp
    
    //normal
    init(name: String, profilePic: String){
        self.name = name
        self.profilePic = profilePic
    }
    
    //for firestore
    init(usr: [String: Any]){
        name = usr["name"] as! String
        profilePic = usr["profilePic"] as! String
    }
}

class song: Identifiable, ObservableObject{
    let addedBy: String //UID of who added it
    let artist: String  //String of all credited artsts, sperated by spaces
    let genres: [String]
    let id: String  //spotify id of the song
    let length: Int //length in ms
    let numVotes: Int?  //nuber of votes recived by the song
    let title: String   //name of the song
    //let timeStarted: Int
    
    //default
    init(addedBy: String, artist: String, genres: [String], id: String, length: Int, numVotes: Int?, title: String) {
        self.addedBy = addedBy
        self.artist = artist
        self.genres = genres
        self.id = id
        self.length = length
        self.numVotes = numVotes
        self.title = title
    }
    
    //firestore
    init(sng: [String: Any], id: String){
        addedBy = sng["addedBy"] as! String
        artist = sng["artist"] as! String
        genres = []
        self.id = id
        length = sng["length"] as! Int
        numVotes = sng["numVotes"] as? Int
        title = sng["title"] as! String
    }
}

//get's the string code for the user's current room
func getCurrRoom(completion: @escaping (String, Error?) -> Void){
    var currRoom = ""
    //get the user's document using firebase auth
    db.collection("users").document(FAuth.currentUser!.uid).getDocument { (res, err) in
        currRoom = res?.data()!["currentRoom"] as! String //grab the value for current room
        completion(currRoom, nil)
    }
    //return currRoom
}

//MARK: API Calls

//signs the user in to firebase
func firebaseLogin(name: String){
    FAuth.signInAnonymously { (result, err) in
        if let err = err {
            //there was an error making the user
            print(err.localizedDescription)
        }
        else{
            //user created successfully
            //make a user document
            db.collection("users").document(result!.user.uid).updateData( [
                "name":  name,
                "profilePic": "https://i.pinimg.com/474x/be/80/75/be8075c3043965030d69e8bccf2b5c5c.jpg",
            ])
        }
    }
}

//puts the user in the room with code = code
func joinRoom(code: String) -> room?{
    //put the user in the correct room
   
    let upperCode = code.uppercased()
    
    //get UID from firebase auth
    let usr = FAuth.currentUser
    
    
    var joinedRoom: room? = nil
    
    //this may be unneccesary
    let joiningQuery = db.collection("room").whereField("code", isEqualTo: upperCode)
    
    joiningQuery.getDocuments() { (query, err) in
        if let err = err{
            print("err gerring documents \(err)")
        }
        else{
            //put the user in the room
            db.collection("users").document(usr!.uid).updateData(["currentRoom": upperCode])
            //check if allowed in room
            //increase count of people in room
            
            let rm = query?.documents[0].data()
            //joinedRoom = room(name: rm!["name"] as! String, desc: rm!["desc"] as! String, anonUsr: rm!["anonUsr"] as! Bool, capacity: rm!["capacity"] as! Int, explicit: rm!["explicit"] as! Bool, voting: rm!["voting"] as! Bool)
            joinedRoom = room(rm: rm!)
        }
        
    }
    
    //this will always return nil, we need to change the return type, probably to void
    return joinedRoom
}

//makes the user leave the room
func leaveRoom() -> Bool{
    //take the user out of the room
    let usr = FAuth.currentUser
    db.collection("users").document(usr!.uid).updateData(["currentRoom": ""])
    
    return true
}

//makes a new room in the db from a room obj
func makeRoom(newRoom: room) -> Bool{
    let code: String
    let usr = FAuth.currentUser
    
    //randomy generate a code if the room doesn't have one
    if newRoom.code == "" {
        code = randomString(length: 5)
    } else{
        code = newRoom.code
    }
    
    //make the room in the db
    db.collection("room").addDocument(data: [
        "name": newRoom.name,
        "desc": newRoom.desc,
        "anonUsr": newRoom.anonUsr,
        "capacity": newRoom.capacity,
        "explicit": newRoom.explicit,
        "voting": newRoom.voting,
        "code": code])
    
    //put the user who made the room into the room
    db.collection("users").document(usr!.uid).updateData(["currentRoom": code])
    //this will need to be modified to allow for adding a room with a queue
    return true
}

//get the queue from the current room
func getQueue(completion: @escaping ([song]?, Error?) -> Void){
    
    getCurrRoom { (currRoom, err) in

        //find the current room doc
        let joiningQuery = db.collection("room").whereField("code", isEqualTo: currRoom)
        
        joiningQuery.getDocuments { (docs, err) in
            if let err = err {
                print("\n\n\n Error Getting Queue \(err)")
                completion(nil, err)
            } else {
                //grab the queue from the room
                let queue = docs?.documents[0].data()["queue"] as? [String: Any]
                var songs: [song] = []
                if queue != nil {
                    //iterate through the queue and convert it into an array of song
                    for (id, s) in queue!{
                        songs.append(song(sng: s as! [String: Any], id: id))
                    }
                }
                completion(songs, nil)
            }
            completion(nil, nil)
        }
    }//end getCurrRoom
    
    
}

//get all the users for a room
func getUsers(completion: @escaping ([user]?, Error?) -> Void){
 
    var users: [user] = []
    
    getCurrRoom { (currRoom, err) in
    
    //find all users that have their currentRoom set = to the current room
    let usrQuery = db.collection("users").whereField("currentRoom", isEqualTo: currRoom)
    
    usrQuery.getDocuments() { (query, err) in
        
        if let err = err{
            print("err gerring documents \(err)")
            completion(nil, err)
        }
        else{
            //iterate through user documents and get their data
            for usr in query!.documents{
                let newusr = user(usr: usr.data())
                
                users.append(newusr)
            }
            completion(users, nil)
        }
        
    }
    
    }//end getCurrRoom
}

//get individual user by id
func getUser(uid: String, completion: @escaping (user?, Error?) -> Void){
    db.collection("users").document(uid).getDocument { (res, err) in
        if let err = err{
            print("err gerring documents \(err)")
            completion(nil, err)
        }else{
            let newusr = user(usr: res!.data()!)
            completion(newusr, nil)
        }
        completion(nil, nil)
    }
    
}

//return 1 for success, 0 for song already in queue, and -1 for fail
func addsong(id: String) -> Int{
    let addedBy = FAuth.currentUser!.uid
    var length = 0
    var title = ""
    var artist = ""
    
    
    getCurrRoom { (currRoom, err) in
        
    
    
    //get the track deets
    sharedSpotify.getTrackInfo(track_uri: id) { (track) in
        if track != nil{
            for art in track!.artists! {
                artist += art.name + " "
            }
            length = (track?.duration_ms)!
            title = track!.name
        }
    
    
    //add the song to the queue
    db.collection("room").whereField("code", isEqualTo: currRoom).getDocuments { (query, err) in
        if let err = err {
            print("Error getting room \(err)")
        }else {
            let docid = query?.documents[0].documentID
            //make a map to put into the db
            let sng = ["title": title,
                       "artist": artist,
                       "length": length,
                       "addedBy": addedBy,
                       "numvotes": 0] as [String : Any]
            
            //put the map into the queue
            db.collection("room").document(docid!).updateData([
                "queue.\(id)": sng
            ])
        }
    }
    }//end sharedSpotify
    }//end currRoom
    
    return 1
}

//used to get details like who posted the song
func getSong(id: String, completion: @escaping (song?, Error?) -> Void){
    
    getCurrRoom { (currRoom, err) in
        
    
    var songout: song? = nil
    
        //grab our room
        db.collection("room").document(currRoom).getDocument { (doc, err) in
        if let err = err {
            print("Error getting song \(err)")
            completion(nil, err)
        } else{
            //grab the queue
            let queue: Dictionary = doc?.data()?["queue"] as! Dictionary<String, Any?>
            if queue != nil {
                //grab the song from the queue
                let sng: Dictionary = queue[id] as! Dictionary<String, Any?>
                
                //convert from the db map of song to song obj
                songout = song(sng: sng, id: id)
                completion(songout, nil)
            }
            completion(nil, nil)
        }
    }
    }//end getCurrRoom
    
    //return songout
}

//need to make sure user is allowed at some point
func vetoSong(id: String){
    
}

//1 upvote, -1 downvote, 0 clear vote?
//returns new vote number
//id is song id
func voteSong(vote: Int, id: String, completion: @escaping (Int, Error?) -> Void){
    getCurrRoom { (currRoom, err) in
        
    
    var songout: song? = nil
    
        //grab our room
        db.collection("room").document(currRoom).getDocument { (doc, err) in
        if let err = err {
            print("Error getting song \(err)")
            completion(-1, err)
        } else{
            //grab the queue
            let queue: Dictionary = doc?.data()?["queue"] as! Dictionary<String, Any?>
            if queue != nil {
                //grab the song from the queue
                var sng: Dictionary = queue[id] as! Dictionary<String, Any?>
                
                //add the vote to the song
                let numVotes = sng["numvotes"] as! Int
                sng["numvotes"] = numVotes + vote
                
                //replace old song object with new song
                //this could create a race condition if multiple people vote at once
                //will want to investigate grabbing and updataing a single variable
                db.collection("room").document(currRoom).updateData([
                    "queue.\(id)": sng])
                
                completion(numVotes+vote, nil)
            }
            completion(-1, nil)
        }
    }//end get room
    }//end getCurrRoom
}
