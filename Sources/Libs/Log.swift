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
import UIKit

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
   
   static let MAX_LOG_FILES : Int = 10
   static let MAX_LOG_LINES : Int = 1000
   static let APP_SANDBOX : URL? = Files.appSandbox()

   var logToConsole : Bool
   var fileIndex : Int = 0
   var lineIndex : Int = 0
   
   var errorLog : Log? = nil
   
   /**
    path without file index and without extension
    */
   var filename : String? = nil
   
   /**
    filename without path and without extension. If not set, only logging to console is possible.
    complete path will be: <path to app documents> + filename + fileindex + ".txt"
    */
   init(_ logToConsole: Bool = true, _ filename: String? = nil, isErrorLog : Bool = false) {
      self.logToConsole = logToConsole
      if !UIDevice.isSimulator {
         print("This device is categorized as no simulator. Logs are created.");
         self.filename = filename
         if filename != nil && !isErrorLog {
            errorLog = Log(false, filename! + "Error", isErrorLog: true)
         }
      } else {
         print("This device is categorized as simulator. Logs may cause instability and are not set up.");
         /*
          Experiences:
          
          Audio gets in endless loop, whole simulation running host (iMac) gets affected, also Music app!
          
          2023-08-25 16:49:37.500934+0200 Bottle Petrol Lamp[2327:30874] *** Terminating app due to uncaught exception 'NSFileHandleOperationException', reason: '*** -[NSConcreteFileHandle seekToEndOfFile]: unknown error'
          *** First throw call stack:
          (
          0   CoreFoundation                      0x0000000180437330 __exceptionPreprocess + 172
          1   libobjc.A.dylib                     0x0000000180051274 objc_exception_throw + 56
          2   Foundation                          0x0000000180ae5fe0 -[NSConcreteFileHandle readDataUpToLength:error:] + 0
          3   Foundation                          0x0000000180ae6654 -[NSConcreteFileHandle seekToEndReturningOffset:error:] + 0
          4   Bottle Petrol Lamp                  0x00000001024b5584 $s18Bottle_Petrol_Lamp3LogC3log33_9C8E0856DEFDBF6431C601765D58F32ALLyySSF + 3276
          5   Bottle Petrol Lamp                  0x00000001024b3b98 $s18Bottle_Petrol_Lamp3LogC5timedyySS_SStF + 156
          6   Bottle Petrol Lamp                  0x00000001024aa89c $s18Bottle_Petrol_Lamp9WheelViewV25updateSelectedMobileLimityyYaFTY0_ + 320
          7   Bottle Petrol Lamp                  0x00000001024aa4f5 $s18Bottle_Petrol_Lamp9WheelViewV4bodyQrvg7SwiftUI05TupleE0VyAE6VStackVyAE7SectionVyAE0E0PAEE8textCaseyQrAE4TextV0M0OSgFQOyAP_Qo_AmEE4task8priority_QrScP_yyYaYbctFQOyAmEE11pickerStyleyQrqd__AE06PickerR0Rd__lFQOyAE0S0VyAPSSAE7ForEachVySaySSGSSAPGG_AE0dsR0VQo__Qo_AE05EmptyE0VGG_A11_tGyXEfU0_A10_yXEfU0_A7_yXEfU_yyYaYbcfU0_TQ1_ + 1
          8   Bottle Petrol Lamp                  0x00000001024ae1bd $s18Bottle_Petrol_Lamp9WheelViewV4bodyQrvg7SwiftUI05TupleE0VyAE6VStackVyAE7SectionVyAE0E0PAEE8textCaseyQrAE4TextV0M0OSgFQOyAP_Qo_AmEE4task8priority_QrScP_yyYaYbctFQOyAmEE11pickerStyleyQrqd__AE06PickerR0Rd__lFQOyAE0S0VyAPSSAE7ForEachVySaySSGSSAPGG_AE0dsR0VQo__Qo_AE05EmptyE0VGG_A11_tGyXEfU0_A10_yXEfU0_A7_yXEfU_yyYaYbcfU0_TATQ0_ + 1
          9   SwiftUI                             0x000000010914f75d objectdestroy.330Tm + 2397
          10  SwiftUI                             0x000000010914ef25 objectdestroy.330Tm + 293
          11  SwiftUI                             0x00000001088e51b5 objectdestroy.30Tm + 2197
          12  SwiftUI                             0x00000001088e51f5 objectdestroy.30Tm + 2261
          13  libswift_Concurrency.dylib          0x00000001b1660445 _ZL23completeTaskWithClosurePN5swift12AsyncContextEPNS_10SwiftErrorE + 1
          )
          libc++abi: terminating due to uncaught exception of type NSException
          
          But also with disabled log files it crashes on a slightly different position and maybe after more run time:
          
          2023-08-25 18:27:29.986118+0200 Bottle Petrol Lamp[5581:96662] *** Terminating app due to uncaught exception 'NSFileHandleOperationException', reason: '*** -[NSConcreteFileHandle writeData:]: unknown error'
          *** First throw call stack:
          (
          0   CoreFoundation                      0x0000000180437330 __exceptionPreprocess + 172
          1   libobjc.A.dylib                     0x0000000180051274 objc_exception_throw + 56
          2   Foundation                          0x0000000180ae5fe0 -[NSConcreteFileHandle readDataUpToLength:error:] + 0
          3   Foundation                          0x0000000180ae62d8 -[NSConcreteFileHandle writeData:] + 256
          4   Bottle Petrol Lamp                  0x0000000102b255f0 $s18Bottle_Petrol_Lamp3LogC3log33_9C8E0856DEFDBF6431C601765D58F32ALLyySSF + 4084
          5   Bottle Petrol Lamp                  0x0000000102b238fc $s18Bottle_Petrol_Lamp3LogC5timedyySS_SStF + 156
          6   Bottle Petrol Lamp                  0x0000000102b449f4 $s18Bottle_Petrol_Lamp11ContentViewV25updateRadioStationDisplayyyYaFTY0_ + 176
          7   Bottle Petrol Lamp                  0x0000000102b446b1 $s18Bottle_Petrol_Lamp11ContentViewV4bodyQrvg7SwiftUI05TupleE0VyAE5GroupVyAGyAE0E0PAEE4fontyQrAE4FontVSgFQOyAE6ButtonVyAE4TextVG_Qo__AkEE4task8priority_QrScP_yyYaYbctFQOyAS_Qo_AsE6SliderVyAE05EmptyE0VA0_GtGG_AIyAGyAU_AkEEAvW_QrScP_yyYaYbctFQOyAkEE09multilineN9AlignmentyQrAE0nT0OFQOyAS_Qo__Qo_tGGAkEEAvW_QrScP_yyYaYbctFQOyAkEEA4_yQrA6_FQOyAkEE5frame8minWidth05idealW003maxW00V6Height0xZ00yZ09alignmentQr12CoreGraphics7CGFloatVSg_A22_A22_A22_A22_A22_AE0T0VtFQOyAS_Qo__Qo__Qo_tGyXEfU0_A9_yXEfU0_yyYaYbcfU_TQ1_ + 1
          8   Bottle Petrol Lamp                  0x0000000102b4d15d $s18Bottle_Petrol_Lamp11ContentViewV4bodyQrvg7SwiftUI05TupleE0VyAE5GroupVyAGyAE0E0PAEE4fontyQrAE4FontVSgFQOyAE6ButtonVyAE4TextVG_Qo__AkEE4task8priority_QrScP_yyYaYbctFQOyAS_Qo_AsE6SliderVyAE05EmptyE0VA0_GtGG_AIyAGyAU_AkEEAvW_QrScP_yyYaYbctFQOyAkEE09multilineN9AlignmentyQrAE0nT0OFQOyAS_Qo__Qo_tGGAkEEAvW_QrScP_yyYaYbctFQOyAkEEA4_yQrA6_FQOyAkEE5frame8minWidth05idealW003maxW00V6Height0xZ00yZ09alignmentQr12CoreGraphics7CGFloatVSg_A22_A22_A22_A22_A22_AE0T0VtFQOyAS_Qo__Qo__Qo_tGyXEfU0_A9_yXEfU0_yyYaYbcfU_TATQ0_ + 1
          9   SwiftUI                             0x000000010989375d objectdestroy.330Tm + 2397
          10  SwiftUI                             0x0000000109892f25 objectdestroy.330Tm + 293
          11  SwiftUI                             0x00000001090291b5 objectdestroy.30Tm + 2197
          12  SwiftUI                             0x00000001090291f5 objectdestroy.30Tm + 2261
          13  libswift_Concurrency.dylib          0x00000001b1660445 _ZL23completeTaskWithClosurePN5swift12AsyncContextEPNS_10SwiftErrorE + 1
          )
          libc++abi: terminating due to uncaught exception of type NSException
          */
      }
   }
   
   func logDeviceInfos( _ loggingClass: String) {
      timed("device model identifier " + UIDevice.modelIdentifier, loggingClass)
      timed("device name " + UIDevice.current.name, loggingClass)
      timed("device model " + UIDevice.current.model, loggingClass)
      timed("device system " + UIDevice.current.systemName, loggingClass)
      timed("device system version " + UIDevice.current.systemVersion, loggingClass)
      timed("device model name " + UIDevice.modelName, loggingClass)
      if UIDevice.hasSmallScreen {
         timed("device is categorized as having a small screen like iPhone 8", loggingClass)
      }
      if UIDevice.isSimulator {
         timed("device is categorized as simulator", loggingClass)
      }
      if UIDevice.deviceCode != nil
      {
         timed("device code " + UIDevice.deviceCode!, loggingClass)
      } else {
         timed("device code not found", loggingClass)
      }
   }
   

   func timed(_ text: String, _ origin: String = "") {
      let FORMATTED_TEXT = Log.logFormatted(text: text, origin: origin)
      log(FORMATTED_TEXT)
   }
   
   
   func timedError(_ errortext: String, _ origin: String = ""){
      log("************************** ERROR ************************************")
      let FORMATTED_TEXT = Log.logFormatted(text: errortext, origin: origin)
      log(FORMATTED_TEXT)
      log("*********************************************************************")
      errorLog?.log(FORMATTED_TEXT)
   }
   
   /*
   fileprivate func filePath() -> String? {
      if filename == nil {
         return nil
      }
      if Log.APP_SANDBOX == nil {
         return nil
      }

      return Log.APP_SANDBOX!.path + "/" + filename! + String(fileIndex) + ".txt"
   }
    */

   fileprivate func fileURL() -> URL? {
      if filename == nil {
         return nil
      }
      if Log.APP_SANDBOX == nil {
         return nil
      }
      
      return Log.APP_SANDBOX!.appendingPathComponent(filename! + String(fileIndex) + ".txt", conformingTo: .fileURL)
   }

   let LOG_GROUP = DispatchGroup()
   var fileUpdater : FileHandle?

   fileprivate func log(_ FORMATTED_TEXT: String) {
      if logToConsole {
         print(FORMATTED_TEXT)
      }

      if fileURL() == nil {
         return
      }

      LOG_GROUP.enter() // avoids confusion in line numbering and file switching
      
         let TEXT: String = String(fileIndex) + " " + String(lineIndex) + " " + FORMATTED_TEXT
         if lineIndex == 0 {
            
            // New file or overwriting existing file
            
            // Deleting old seems not necessary due to String.write deleting previous content.
            // The delete is buggy.
            /*
            if FileManager.default.fileExists(atPath: filePath()!) {
               do {
                  try FileManager.default.removeItem(atPath: filePath()!)
               } catch let ERROR {
                  logFileErrorAndStopWriting(ERROR.localizedDescription)
               }
            }
             */
            
            // write TEXT to file's first line:
            if fileURL() != nil { // may have been set nil in previous logFileErrorAndStopWriting since last check
               do {
                  try TEXT.write(to: fileURL()!, atomically: true, encoding: .utf8)
               } catch let ERROR {
                  logFileErrorAndStopWriting(ERROR.localizedDescription)
               }
               if fileURL() != nil { // may have been set nil in previous logFileErrorAndStopWriting since last check
                  do {
                     fileUpdater = try FileHandle(forUpdating: fileURL()!)
                  } catch let ERROR {
                     logFileErrorAndStopWriting(ERROR.localizedDescription)
                  }
               }
            }
            
         } else {
            
            // Next line in existing file
            
            if fileUpdater != nil {
               fileUpdater!.seekToEndOfFile()
               fileUpdater!.write(("\n" + TEXT).data(using: .utf8)!)
            }
         }
         
            
         lineIndex += 1
         if lineIndex == 1 {
            // write device infos into every log
            if fileURL() != nil { // may have been set nil in previous logFileErrorAndStopWriting since last check
               //logDeviceInfos(Self.typeName)
            }
         }
         if lineIndex >= Log.MAX_LOG_LINES {
            fileUpdater?.closeFile()
            fileIndex += 1
            lineIndex = 0
            if fileIndex >= Log.MAX_LOG_FILES {
               fileIndex = 0
            }
         }
      
      LOG_GROUP.leave()
   }
   
   fileprivate func logFileErrorAndStopWriting(_ error: String) {
      filename = nil
      fileUpdater = nil
      Log.timedError(error + "\nDeactivated file logging.")
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
         blank = " "
      }
      return Time.timeString(Time.now(),Time.FORMAT_HH_MM_SS_MILLIS) + " " + origin + blank + ": " + text
   }
   
   static func timedError(_ errortext: String, _ origin: String = ""){
      print("************************** ERROR ************************************")
      Log.timed(errortext, origin)
      print("*********************************************************************")
   }
}
