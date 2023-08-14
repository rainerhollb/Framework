//
//  Time.swift
//  Bottle Petrol Lamp
//
//  Created by Rainer on 04.08.23.
//

import Foundation

struct Time : Describable {
   
   static let FORMAT_HHMMSS = "HH:mm:ss"
   static let FORMAT_HH_MM_SS_MILLIS = "HH:mm:ss.SSSS"
   
   /**
    Type Double is used due to frequent usage for multiplication with Doubles to get parts of a second.
    For other usage convert to required type!
    */
   static let NANOS_PER_SECOND : Double = 1000000000
   
   static func now() -> Date {
      return Date()
   }
   
   
   /**
    * nanoseconds between date1 and date2. 0 if date2 is before date1.
    */
   static func nanosecondsTo(date1: Date, date2: Date,
                             caller: String? = "") -> UInt64 {
      //Log.timed(caller! + "nanosecondsTo (" + timeString(date1,FORMAT_HH_MM_SS_MILLIS) + ", " + timeString(date2,FORMAT_HH_MM_SS_MILLIS) + ") = \(date1.distance(to: date2)) s", Self.typeName)
      return UInt64(
         lround(
            max(0.0, Double(date1.distance(to: date2)) * NANOS_PER_SECOND))
      )
   }
   
   static let CLOCK_FORMATTER = DateFormatter()
   
   /** Not thread safe! If thread safety is required, add a new method using its own clock formatter!
    */
   static func timeString(_ date: Date, _ format: String) -> String {
      CLOCK_FORMATTER.dateFormat = format
      return CLOCK_FORMATTER.string(from: date)
   }
   
   enum TimeError: Error {
      case invalidDateComponents // "invalid Date components"
   }
   
   static let CALENDAR = Calendar.current
   
   static func fullSecondDate(_ date: Date,
                              _ caller: String? = "") throws -> Date {
      let COMPONENTS = CALENDAR.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
      let D : Date? = CALENDAR.date(from: COMPONENTS)
      if D == nil {
         throw TimeError.invalidDateComponents
      }
      // Log.timed(caller! + "fullSecondDate " + timeString(date,FORMAT_HH_MM_SS_MILLIS) + " -> " + timeString(D!,FORMAT_HH_MM_SS_MILLIS), typeName)
      return D!
   }
   
   static let ONE_SECOND : TimeInterval = 1.0
   
   static func waitUntilNextFullSecond(
      additional: TimeInterval? = 0.0,
      expectedMaximumNanos: UInt64? = nil,
      expectedMinimumNanos: UInt64? = nil,
      caller: String? = ""
   ) async throws {
      let NOW = now()
      let NANOS_TO_WAIT = nanosecondsTo(
         date1: NOW,
         date2: try Time.fullSecondDate(NOW, caller)
            .addingTimeInterval(ONE_SECOND)
            .addingTimeInterval(additional!),
         caller: caller)
      Log.timed (caller! + "waitUntilNextFullSecond is waiting \(NANOS_TO_WAIT) ns = \(Double(NANOS_TO_WAIT) / Time.NANOS_PER_SECOND) s", typeName)
      if expectedMaximumNanos != nil && NANOS_TO_WAIT > expectedMaximumNanos! {
         Log.timedError(caller! + "NANOSECONDS_TO_WAIT = \(NANOS_TO_WAIT) > expectedMaximumNanoseconds = \(expectedMaximumNanos!)", typeName)
      }
      if expectedMinimumNanos != nil && NANOS_TO_WAIT < expectedMinimumNanos! {
         Log.timedError(caller! + "NANOSECONDS_TO_WAIT = \(NANOS_TO_WAIT) < expectedMinimumNanos = \(expectedMinimumNanos!)", typeName)
      }
      try await Task.sleep(nanoseconds: NANOS_TO_WAIT)
   }
   
}

