//
//  Firestore.swift
//  VoteNote
//
//  Created by Adam Cramer on 2/3/21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class dbConnection: ObservableObject {
    
    init() {
        
    }
}

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

//MARK: data objects
class room{
    let name: String
    let desc: String?
    let anonUsr: Bool
    let capacity: Int
    let explicit: Bool
    let voting: Bool
    let queue: [song]
    let code: String
    //need to add songs per user and allowed genres
    
    
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
    let profilePic: String
    
    init(name: String, profilePic: String){
        self.name = name
        self.profilePic = profilePic
    }
    
    init(usr: [String: Any]){
        name = usr["name"] as! String
        profilePic = usr["profilePic"] as! String
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
    
    init(sng: [String: Any], id: String){
        addedBy = sng["addedBy"] as! String
        artist = sng["artist"] as! String
        genres = []
        self.id = id
        length = sng["length"] as! Int
        numVotes = sng["numVotes"] as? Int
        title = sng["title"] as! String
      imageUrl = sng["imageurl"] as! String
    }
  
}

func getCurrRoom(completion: @escaping (String, Error?) -> Void){
    var currRoom = ""
    db.collection("users").document(FAuth.currentUser!.uid).getDocument { (res, err) in
        currRoom = res?.data()!["currentRoom"] as! String
        completion(currRoom, nil)
    }
    //return currRoom
}

//MARK: API Calls

func login(name: String){
    FAuth.signInAnonymously { (result, err) in
        if let err = err {
            //there was an error making the user
            print(err.localizedDescription)
        }
        else{
            //user created successfully
            
            db.collection("users").document(result!.user.uid).updateData( [
                "name":  name,
                "profilePic": "https://i.pinimg.com/474x/be/80/75/be8075c3043965030d69e8bccf2b5c5c.jpg",
                //"currentRoom": ""
            ])
        }
    }
}

//to leave the room, send this method ""
func joinRoom(code: String) -> room?{
    //put the user in the correct roomm
   
    let upperCode = code.uppercased()
    
    let usr = FAuth.currentUser
    
    
    var joinedRoom: room? = nil
    
    let joiningQuery = db.collection("room").whereField("code", isEqualTo: upperCode)
    
    joiningQuery.getDocuments() { (query, err) in
        if let err = err{
            print("err gerring documents \(err)")
        }
        else{
            db.collection("users").document(usr!.uid).updateData(["currentRoom": upperCode])
            //check if allowed in room
            //increase count of people in room
            
            let rm = query?.documents[0].data()
            //joinedRoom = room(name: rm!["name"] as! String, desc: rm!["desc"] as! String, anonUsr: rm!["anonUsr"] as! Bool, capacity: rm!["capacity"] as! Int, explicit: rm!["explicit"] as! Bool, voting: rm!["voting"] as! Bool)
            joinedRoom = room(rm: rm!)
        }
        
    }
    
    //this will likely always return nil, we need to change the return type
    return joinedRoom
}

func leaveRoom() -> Bool{
    //take the user out of the room
    let usr = FAuth.currentUser
    db.collection("users").document(usr!.uid).updateData(["currentRoom": ""])
    
    return true
}

func makeRoom(newRoom: room) -> Bool{
    let code: String
    let usr = FAuth.currentUser
    
    if newRoom.code == "" {
        code = randomString(length: 5)
    } else{
        code = newRoom.code
    }
    
    db.collection("room").addDocument(data: [
        "name": newRoom.name,
        "desc": newRoom.desc,
        "anonUsr": newRoom.anonUsr,
        "capacity": newRoom.capacity,
        "explicit": newRoom.explicit,
        "voting": newRoom.voting,
        "code": code])
    
    db.collection("users").document(usr!.uid).updateData(["currentRoom": code])
    //this will need to be modified to allow for adding a room with a queue
    return true
}

func getQueue(completion: @escaping ([song]?, Error?) -> Void){
    
    getCurrRoom { (currRoom, err) in

        let joiningQuery = db.collection("room").whereField("code", isEqualTo: currRoom)
        
        joiningQuery.getDocuments { (docs, err) in
            if let err = err {
                print("\n\n\n Error Getting Queue \(err)")
                completion(nil, err)
            } else {
                let queue = docs?.documents[0].data()["queue"] as? [String: Any]
                var songs: [song] = []
                if queue != nil {
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
    /*
    let usr1 = user(name: "Wesley Curtis", profilePic: "www.picture.com")
    
    let usr2 = user(name: "Obama", profilePic: "www.usa.gov")
    
    let usr3 = user(name: "Joe Mama", profilePic: "www.gotcha.com")
    */
 
    var users: [user] = []
    
    //let currRoom = getCurrRoom()
    getCurrRoom { (currRoom, err) in
    
    
    let usrQuery = db.collection("users").whereField("currentRoom", isEqualTo: currRoom)
    
    usrQuery.getDocuments() { (query, err) in
        
        if let err = err{
            print("err gerring documents \(err)")
            completion(nil, err)
        }
        else{
            for usr in query!.documents{
                let newusr = user(usr: usr.data())
                
                users.append(newusr)
            }
            completion(users, nil)
        }
        
    }
    
    }//end getCurrRoom
}

//get individual user
func getUser(uid: String) -> user{
    let usr1 = user(name: "Wesley Curtis", profilePic: "www.picture.com")
    
    return usr1
}

//return 1 for success, 0 for song already in queue, and -1 for fail
func addsong(id: String) -> Int{
    //this will need spotify integration in order to get data
    let addedBy = FAuth.currentUser!.uid
    var length = 0
    var title = ""
    var artist = ""
  var imageUrl = ""
    
    //find current room
    //var currRoom = getCurrRoom()
    
    getCurrRoom { (currRoom, err) in
        
    
    
    //get the track deets
    sharedSpotify.getTrackInfo(track_uri: id) { (track) in
        if track != nil{
            for art in track!.artists! {
                artist += art.name + " "
            }
            length = (track?.duration_ms)!
            title = track!.name
          imageUrl = track?.album?.images?[0].url ?? ""
        }
    
    
    //add the song to the queue
    db.collection("room").whereField("code", isEqualTo: currRoom).getDocuments { (query, err) in
        if let err = err {
            print("Error getting room \(err)")
        }else {
            let docid = query?.documents[0].documentID
            let sng = ["title": title,
                       "artist": artist,
                       "length": length,
                       "addedBy": addedBy,
                       "imageurl": imageUrl,
                       "numvotes": 0] as [String : Any]
            
            
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
    //let song1 = song(addedBy: "kki2j39jd", artist: "Toto", genres: ["Pop", "Rock"], id: "j288dm7", length: 760, numVotes: 10, title: "Africa")
    
    //let currRoom = getCurrRoom()
    
    getCurrRoom { (currRoom, err) in
        
    
    var songout: song? = nil
    
        db.collection("room").document(currRoom).getDocument { (doc, err) in
        if let err = err {
            print("Error getting song \(err)")
            completion(nil, err)
        } else{
            let queue: Dictionary = doc?.data()?["queue"] as! Dictionary<String, Any?>
            if queue != nil {
                let sng: Dictionary = queue[id] as! Dictionary<String, Any?>
                
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
func voteSong(vote: Int) -> Int{
    return 8
}
