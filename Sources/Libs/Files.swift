//
//  Files.swift
//  
//
//  Created by rainer on 22.08.23.
//

import Foundation

struct Files : Describable {
   

   /**
    Returns the apps sandbox path, without trailing /
    Prints alternatives the the used method.
    */
   static func appSandbox() -> String {
      // alternative, needs to be tested:
      testHomeAlternatives()
      
      do {
         let FILE_URL = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
         return FILE_URL.path
      } catch let ERROR {
         print(ERROR.localizedDescription)
         return ""
      }
   }
   
   static func testHomeAlternatives() {

      // Documentation correction:
      // In iOS, add "/Documents/" to the home directory to get the application’s sandbox directory.
      print()
      print("NSHomeDirectory()/Documents:")
      print(NSHomeDirectory() + "/Documents")
            
      print()
      print("NSSearchPathForDirectoriesInDomains, expandTilde false/true:")
      var expandTilde = false
      for h in NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, expandTilde) {
         print(h)
      }
      expandTilde = true
      for h in NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, expandTilde) {
         print(h)
      }

      do {
         print()
         print("FileManager.default.url:")
         let APP_DOC_DIR = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
         // appropriateFor != nil requires iOS 16:
         //APP_DOC_DIR = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: .documentsDirectory, create: true)
         print("path:")
         print(APP_DOC_DIR.path)
         print("absoluteString:")
         print(APP_DOC_DIR.absoluteString)
         
         print()
         print("FileManager.default.urls:")
         for d in FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) {
            print("path:")
            print(d.path)
            print("absoluteString:")
            print(d.absoluteString)
         }
         print()

      } catch let ERROR {
         Log.timed(ERROR.localizedDescription)
      }
}
}
