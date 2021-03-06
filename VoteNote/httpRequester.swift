//
//  httpRequester.swift
//  VoteNote
//
//  Created by COMP 401 on 2/13/21.
//

import Foundation
import SwiftHTTP
import SwiftUI

//impements SwiftHTTP so that we can make easy http requests to the spotify web api
class HttpRequester: ObservableObject {
  
  init(){
    
  }
  
  //get without header or parameters
  func GET(url: String) -> HTTP{
    HTTP.GET(url) { response in
      if let err = response.error {
        print("url failed")
        print("error: \(err.localizedDescription)")
        return //also notify app of failure as needed
      }
      print("opt finished: \(response.description)")
      //print("data is: \(response.data)") access the response of the data with response.data
    }!
  }
  
  //get with parameters and header
  func headerParamGet(url: String, header: [String: String], param: [String: String]) -> HTTP{
    HTTP.GET(url, parameters: param, headers: header) { response in
      if let err = response.error {
        print("error: \(err.localizedDescription)")
        return //also notify app of failure as needed
      }
    }!
  }
  
  //get with header
  func headerGet(url: String, header: [String: String] ) -> HTTP {
    
    HTTP.GET(url, headers: header) { response in
      if let error = response.error {
        print("got an error: \(error)")
        return
      }
      print("opt finished: \(response.description)")
    }!
  }
  
  //not done dont use
  func POST(url: String, params: [(name:String, value:String)]){
    
    HTTP.POST(url, parameters: params) { response in
      //do things...
      
      // no idea what to do here
    }
  }
  
  
  //put no header or parameters
  func PUT(url: String){
    HTTP.PUT(url)
  }
  
  //put with header and paramters
  func headerParamPUT(url: String, header: [String: String], param: [String: String]) -> HTTP{
    HTTP.PUT(url, parameters: param, headers: header) { response in
      if let err = response.error {
        print("error: \(err.localizedDescription)")
        return //also notify app of failure as needed
      }
    }!
  }
  
  //put with just header
  func headerPUT(url: String, header: [String: String]) -> HTTP{
    HTTP.PUT(url, headers: header) { response in
      if let err = response.error {
        print("error: \(err.localizedDescription)")
        return //also notify app of failure as needed
      }
    }!
  }
  
  func headerDELETE(url: String, header: [String: String]) -> HTTP{
      HTTP.DELETE(url, headers: header) { response in
        if let err = response.error {
          print("error: \(err.localizedDescription)")
          return //also notify app of failure as needed
        }
      }!
    }
  
  
}


