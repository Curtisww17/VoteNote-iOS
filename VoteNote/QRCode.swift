//
//  QRCode.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/23/21.
//

import Foundation
import CoreImage.CIFilterBuiltins


//Generates a qr code of the string parameter
func generateQRCode(from string: String) -> UIImage {
  
  let context = CIContext()
  let filter = CIFilter.qrCodeGenerator()
  let data = Data(string.utf8)
  filter.setValue(data, forKey: "inputMessage")
  
  if let outputImage = filter.outputImage {
    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
      return UIImage(cgImage: cgimg)
    }
  }
  
  return UIImage(systemName: "xmark.circle") ?? UIImage()
}

/**
 resizes an image because for some reason the qr code you get out of generateQRCode
 is about 5 pixels by 5 pixels
 */
func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
  let size = image.size
  
  let widthRatio  = targetSize.width  / size.width
  let heightRatio = targetSize.height / size.height
  
  // Figure out what our orientation is, and use that to form the rectangle
  var newSize: CGSize
  if(widthRatio > heightRatio) {
    newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
  } else {
    newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
  }
  
  // This is the rect that we've calculated out and this is what is actually used below
  let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
  
  // Actually do the resizing to the rect using the ImageContext stuff
  UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
  UIGraphicsGetCurrentContext()?.interpolationQuality = .none
  image.draw(in: rect)
  let newImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  return newImage!
}
