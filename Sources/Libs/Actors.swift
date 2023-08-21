//
//  Actors.swift
//  
//
//  Created by rainer on 16.08.23.
//

import Foundation


actor TextActor {
  var text : String
  
  init(_ text: String){
    self.text = text
  }
  
  func update(_ text: String) {
    self.text = text
  }
  
  func get() -> String {
    return text
  }
}

actor BoolActor {
  var bool : Bool
  
  init(_ bool : Bool){
    self.bool = bool
  }
  
  func update(_ bool : Bool) {
    self.bool = bool
  }
  
  func get() -> Bool {
    return bool
  }
}
