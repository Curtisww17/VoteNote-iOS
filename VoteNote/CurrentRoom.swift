//
//  CurrentRoom.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/23/21.
//

import Foundation
import SwiftUI



class CurrentRoom: ObservableObject {
  @Published var roomCode: String
  @Published var roomQR: UIImage?
  
//  init(roomCode: String) {
//    self.roomCode = roomCode
//    self.roomQR = generateQRCode(from: roomCode)
//  }
  
  init() {
    roomCode = ""
    roomQR = nil
  }
  
  func update(roomCode: String) {
        self.roomCode = roomCode
        //self.roomQR = generateQRCode(from: roomCode)
     self.roomQR = resizeImage(image: generateQRCode(from: roomCode), targetSize: CGSize(width: 200.0, height: 200.0))
    
  }
}
