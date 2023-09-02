//
//  File.swift
//  
//
//  Created by Rainer on 14.08.23.
//

import Foundation

public extension String {
   
   /**
    subString using offset 0 for from. from = n => from n+1 th character,
    using offset 1 for to. to = n => n th character is included.
    Using the Java substring approach from
    https://stackoverflow.com/questions/45562662/how-can-i-use-string-substring-in-swift-4-substringto-is-deprecated-pleas
    expanded by to as optional.
    Motivation for this function:
    String.Index type seems to be incompatible with Int, UInt, ...
    This makes it difficuilt to use the slicing parameters with integer parameters.
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
   
   func subString(from: Int, toSeparator: Character?) -> String {
      let FROM_INDEX = self.index(self.startIndex, offsetBy: from)
      return subString(fromIndex:FROM_INDEX, toBefore:toSeparator)
   }
   
   /**
    previousStartString: substring which starts self and is before the required subString - the length is important, not its contents
    */
   func subString(previousStartString: String, toSeparator: Character? = nil) -> String {
      let FROM_INDEX = self.index(self.startIndex, offsetBy: previousStartString.count)
      return subString(fromIndex:FROM_INDEX, toBefore:toSeparator)
   }
   
   
   func subString(_ from: Int, _ to: Int? = nil) -> String {
      return subString(from: from, to: to)
   }
   
   func wrapHardly(charsPerLine: Int) -> String {
      if self.count <= charsPerLine {
         return self
      }
      
      return
         self.subString(from: 0,to: charsPerLine)
         + "\n"
         + self.subString(from: charsPerLine)
            .wrapHardly(charsPerLine: charsPerLine)
   }
   
   
   fileprivate func subString(fromIndex: String.Index, toBefore: Character?) -> String {
      let WITHOUT_STARTSTRING = self[fromIndex...]
      
      var endIndex : String.Index?
      if toBefore == nil {
         endIndex = nil
      } else {
         endIndex = WITHOUT_STARTSTRING.firstIndex(of: toBefore!)
      }
      
      if endIndex == nil {
         return String(WITHOUT_STARTSTRING)
      }
      
      return String(WITHOUT_STARTSTRING[..<endIndex!])
   }
   
   /**
    returns self + "s" if number is != 1, else self
    */
   func sIfPlural(_ number: Int) -> String {
      if number == 1 {
         return self
      } else {
         return self + "s"
      }
   }
   

}
