//
//  CurrentRoom.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/23/21.
//

import Foundation
import SwiftUI


var currentQR = CurrentRoom()
/**
 This class is for keeping track of the current room's qr code. Swift is weird so I had to
 make this in a separate class
 */
class CurrentRoom: ObservableObject {
  @Published var roomCode: String
  @Published var roomQR: UIImage?
  
  
  init() {
    roomCode = ""
    roomQR = nil
  }
  
  func update(roomCode: String) {
    self.roomCode = roomCode
    self.roomQR = resizeImage(image: generateQRCode(from: roomCode), targetSize: CGSize(width: 200.0, height: 200.0))
  }
}
