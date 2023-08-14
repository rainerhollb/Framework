//
//  File.swift
//  
//
//  Created by Rainer on 05.08.23.
//

// logging: https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code
// read: https://developer.apple.com/documentation/oslog

/*
 https://nshipster.com/swift-log/
 =>
 To be able to import Logging, add to Package.swift:
 products: [
 .executable(name: "audit", targets: ["audit"])
 ],
 dependencies: [
 .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
 ],
 targets: [
 .target(name: "audit", dependencies: ["Logging"])
 ]

 or if not present add the whole file in the root folder of your project:
 import PackageDescription
 
 let package = Package(
 name: "Auditor2000",
 products: [
 .executable(name: "audit", targets: ["audit"])
 ],
 dependencies: [
 .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
 ],
 targets: [
 .target(name: "audit", dependencies: ["Logging"])
 ]
 )
 
 .. not working
 */

import Foundation
//import Logging

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
   
   //let DEFAULT_LOG = Logger()
   
   
   
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
      //DEFAULT_LOG.info(origin! + blank + ": " + text)
   }
   
   static func timedError(_ errortext: String, _ origin: String? = ""){
      print("************************** ERROR ************************************")
      Log.timed(errortext, origin)
      print("*********************************************************************")
   }
}
