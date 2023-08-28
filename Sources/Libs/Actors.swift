//
//  Actors.swift
//  
//
//  Created by rainer on 16.08.23.
//

import Foundation


public actor TextActor {
  var text : String
  
   public init(_ text: String){
    self.text = text
  }
  
   public func update(_ text: String) {
    self.text = text
  }
  
   public func get() -> String {
    return text
  }
}

public actor BoolActor {
  var bool : Bool
  
   public init(_ bool : Bool){
    self.bool = bool
  }
  
   public func update(_ bool : Bool) {
    self.bool = bool
  }
  
   public func get() -> Bool {
    return bool
  }
}
