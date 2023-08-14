//
//  File.swift
//  
//
//  Created by Rainer on 14.08.23.
//

import Foundation

extension String {
   
   /**
      String.Index type seems to be incompatible with Int, UInt, ...
    Using the Java substring approach from
    https://stackoverflow.com/questions/45562662/how-can-i-use-string-substring-in-swift-4-substringto-is-deprecated-pleas
     expanded by optional to
    */
   func subString(from: Int, to: Int? = nil) -> String {
      let startIndex = self.index(self.startIndex, offsetBy: from)
      var endIndex : String.Index
      if to == nil {
         endIndex = self.index(self.startIndex, offsetBy: self.count)
      } else {
         endIndex = self.index(self.startIndex, offsetBy: to!)
      }
      return String(self[startIndex..<endIndex])
   }

   func wrapHardly(charsPerLine: Int) -> String {
      if self.count <= charsPerLine {
         return self
      }
      
      return self.subString(from: 0,to: charsPerLine)
      + "\n"
      + self.subString(from: charsPerLine)
         .wrapHardly(charsPerLine: charsPerLine)
   }
}
