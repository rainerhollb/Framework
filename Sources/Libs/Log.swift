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

class Log : Describable {
   
   //let DEFAULT_LOG = Logger()
   
   static let MAX_LOG_FILES : Int = 10
   static let MAX_LOG_LINES : Int = 1000
   static let APP_SANDBOX = Files.appSandbox()

   var logToConsole : Bool
   var fileIndex : Int = 0
   var lineIndex : Int = 0
   
   /**
    path without file index and without extension
    */
   var filename : String? = nil
   
   /**
    filename without path and without extension
    complete path: <path to app documents> + filename + fileindex + ".log"
    */
   init(_ logToConsole: Bool = true, _ filename: String? = nil) {
      self.logToConsole = logToConsole
      self.filename = filename
   }
   
   
   func timed(_ text: String, _ origin: String = "") {
      let FORMATTED_TEXT = Log.logFormatted(text: text, origin: origin)
      
      log(FORMATTED_TEXT)
   }
   
   
   func timedError(_ errortext: String, _ origin: String = ""){
      log("************************** ERROR ************************************")
      timed(errortext, origin)
      log("*********************************************************************")
   }
   
   
   fileprivate func filePath() -> String? {
      if filename == nil {
         return nil
      }
      if Log.APP_SANDBOX == nil {
         return nil
      }

      return Log.APP_SANDBOX!.path + "/" + filename! + String(fileIndex) + ".log"
   }

   fileprivate func fileURL() -> URL? {
      if filename == nil {
         return nil
      }
      if Log.APP_SANDBOX == nil {
         return nil
      }
      
      return Log.APP_SANDBOX!.appendingPathComponent(filename! + String(fileIndex) + ".log", conformingTo: .fileURL)
   }

   let LOG_GROUP = DispatchGroup()
   
   fileprivate func log(_ FORMATTED_TEXT: String) {
      if logToConsole {
         print(FORMATTED_TEXT)
      }
      
      LOG_GROUP.enter()
      
      if filePath() != nil {
         if lineIndex == 0 {
            /* new file, delete old seems not to be necessary due to String.write deleting previous content
            if FileManager.default.fileExists(atPath: filePath()!) {
               do {
                  try FileManager.default.removeItem(atPath: filePath()!)
               } catch let ERROR {
                  logFileErrorAndStopWriting(ERROR.localizedDescription)
               }
            }
             */

            do {
               try (String(fileIndex) + " " + String(lineIndex) + " " + FORMATTED_TEXT).write(toFile: filePath()!, atomically: true, encoding: .utf8)
            } catch let ERROR {
               logFileErrorAndStopWriting(ERROR.localizedDescription)
            }
         } else {
            if fileURL() != nil {
               if let fileUpdater = try? FileHandle(forUpdating: fileURL()!) {
                  
                  // Function which when called will cause all updates to start from end of the file
                  fileUpdater.seekToEndOfFile()
                  
                  // Which lets the caller move editing to any position within the file by supplying an offset
                  fileUpdater.write(("\n" + String(fileIndex) + " " + String(lineIndex) + " " + FORMATTED_TEXT).data(using: .utf8)!)
                  
                  // Once we convert our new content to data and write it, we close the file and that’s it!
                  fileUpdater.closeFile()
               } else {
                  logFileErrorAndStopWriting("File handle not found")
               }
            } else {
               logFileErrorAndStopWriting("File URL not set")
            }
         }
            
         lineIndex += 1
         if lineIndex >= Log.MAX_LOG_LINES {
            fileIndex += 1
            lineIndex = 0
            if fileIndex >= Log.MAX_LOG_FILES {
               fileIndex = 0
            }
         }
      }
      
      LOG_GROUP.leave()
   }
   
   fileprivate func logFileErrorAndStopWriting(_ error: String) {
      Log.timedError(error + "\nDeactivating file logging.")
      filename = nil
   }
   
   /**
    To use origin, add Desribable protocol to the using struct or class and use Self.typeName as 2nd argument in this call.
    In static code, Self can be omitted.
    */
   
   static func timed(_ text: String, _ origin: String = ""){
      print(logFormatted(text: text, origin: origin))
      //DEFAULT_LOG.info(origin! + blank + ": " + text)
   }
    
   
   static func logFormatted(text: String, origin: String) -> String {
      var blank = ""
      if origin != "" {
         blank += " "
      }
      return Time.timeString(Time.now(),Time.FORMAT_HH_MM_SS_MILLIS) + " " + origin + blank + ": " + text
   }
   
   static func timedError(_ errortext: String, _ origin: String = ""){
      print("************************** ERROR ************************************")
      Log.timed(errortext, origin)
      print("*********************************************************************")
   }
}
