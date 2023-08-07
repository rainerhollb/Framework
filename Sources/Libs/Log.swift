//
//  File.swift
//  
//
//  Created by Rainer on 05.08.23.
//

import Foundation

/**
 Get the struct name by additional protocol.
 Idea from https://stackoverflow.com/questions/35088970/Log.timed-struct-name-in-swift
 */
public protocol Describable {
   static var typeName: String { get }
}
extension Describable {
   static public var typeName: String {
      return String(describing: Self.self)
   }
}

struct Log {
   
   /**
    To use origin, add Desribable protocol to the using struct and use Self.typeName as 2nd argument in this call.
    In static code, Self can be omitted.
    */
   static func timed(_ text: String, _ origin: String? = ""){
      var blank = ""
      if origin! != "" {
         blank += " "
      }
      print(Time.timeString(Time.now(),Time.FORMAT_HH_MM_SS_MILLIS) + " " + origin! + blank + ": " + text)
   }
   
}
