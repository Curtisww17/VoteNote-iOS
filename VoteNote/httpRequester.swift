//
//  httpRequester.swift
//  VoteNote
//
//  Created by COMP 401 on 2/13/21.
//

import Foundation
import SwiftHTTP

class HttpRequester: ObservableObject {
    
    init(){
        
    }
    
    func GET(url: String){
        HTTP.GET(url) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            print("opt finished: \(response.description)")
            //print("data is: \(response.data)") access the response of the data with response.data
        }
    }
    
    func paramGet(url: String, params: [(name:String, value:String)]){
        HTTP.GET(url, parameters: params) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            print("opt finished: \(response.description)")
        }
    }
    
    //not done dont use
    func POST(url: String, params: [(name:String, value:String)]){
        
        HTTP.POST(url, parameters: params) { response in
        //do things...
        // no idea what to do here
        }
    }
    
    func PUT(url: String){
        HTTP.PUT(url)
    }
    
    
}


