//
//  Cellular.swift
//  Bottle Petrol Lamp
//
//  Created by Rainer on 30.07.23.
//

import Foundation
import UIKit
import Extensions

public struct Cellular : Describable {
   
   public static let CELLULAR_TOTAL_MB_STRING = "MB total"
   static let CELLULAR_CONSUMPTION_SINCE_STARTUP_STRING = "Mobile internet usage since session startup is "
   private static let NEW_GENERATION_SYNC_PRE = 0.2 // 0.1 is tested to be too small
   private static let OLD_GENERATION_SYNC_PRE = 0.4 // 0.2 is tested to be too small

   private static func syncPre() -> Double {
      if Device.IS_NEW_GENERATION {
         return NEW_GENERATION_SYNC_PRE
      } else {
         return OLD_GENERATION_SYNC_PRE
      }
   }
   
   /**
    This constant is used for the synchronization of mobile internet consumption check and displaying it together with the next second of the clock and with data as up to date as possible.
    
    The consumption is fetched in an own task. It must be signaled early enough to be integrated into the next clock display
    of the next second.
    */
   public static let MOBILE_INTERNET_CHECK_NEXT_FULL_SECOND_SYNC_PRE = syncPre()
   
   // do not change this format because it is parsed below
   public static let MOBILE_LIMIT_NONE = "none"
   static let MOBILE_LIMIT_1MB = "1 " + Units.MB
   static let MOBILE_LIMIT_3MB = "3 " + Units.MB
   static let MOBILE_LIMIT_10MB = "10 " + Units.MB
   static let MOBILE_LIMIT_30MB = "30 " + Units.MB
   static let MOBILE_LIMIT_100MB = "100 " + Units.MB
   static let MOBILE_LIMIT_300MB = "300 " + Units.MB
   static let MOBILE_LIMIT_1GB = "1 " + Units.GB
   static let MOBILE_LIMIT_3GB = "3 " + Units.GB
   // static let MOBILE_LIMIT_10GB = "10 " + Units.GB
   // static let MOBILE_LIMIT_30GB = "30 " + Units.GB
   // static let MOBILE_LIMIT_100GB = "100 " + Units.GB
   static let MOBILE_LIMIT_UNLIMITED = "unlimited flat"
   
   public static let MOBILE_LIMITS = [
      MOBILE_LIMIT_NONE,
      MOBILE_LIMIT_1MB,
      MOBILE_LIMIT_3MB,
      MOBILE_LIMIT_10MB,
      MOBILE_LIMIT_30MB,
      MOBILE_LIMIT_100MB,
      MOBILE_LIMIT_300MB,
      MOBILE_LIMIT_1GB,
      MOBILE_LIMIT_3GB,
      /* not realistic:
      MOBILE_LIMIT_10GB,
      MOBILE_LIMIT_30GB,
      MOBILE_LIMIT_100GB, */
      MOBILE_LIMIT_UNLIMITED]
   
   /**
    Waits until next second - WAIT_TIME_BEFORE_NEXT_FULL_SECOND
    Checks mobile internet usage if startCheckingActor signals.
    
    The calling process has WAIT_TIME_BEFORE_NEXT_FULL_SECOND seconds or less to wait - useful to print the check results soon with the switch to next second.
    
    Test warning: a test of this feature with connected XCode host is only possible via cable!
    If you test via Wifi, the connection will get lost when you switch off Wifi.
    This can result in unexpected termination of application.
    */
   public static func checkMobileInternetUsage(
      mobileLimitActor: TextActor,
      mobileConsumptionTextActor: TextActor,
      stopConsumerActor: BoolActor,
      log: Log
   ) async {
      
      do {
         var sessionStartDate : Date? = nil
         let SESSION_START_TOTAL_CONSUMPTION : UInt64 = SystemDataUsage.wwanComplete
         var lastCellularBytes : UInt64?
         var cellularUsageText : String = ""
         var lastCheckDate : Date = Time.now()
         
         repeat {
            
            if sessionStartDate == nil {
               // initial
               sessionStartDate = Time.now()
               if try Time.fullSecondDate(sessionStartDate!).distance(to: sessionStartDate!) > 1.0 - MOBILE_INTERNET_CHECK_NEXT_FULL_SECOND_SYNC_PRE {
                  await Time.waitUntilNextFullSecond(
                     additional: 1.0 - MOBILE_INTERNET_CHECK_NEXT_FULL_SECOND_SYNC_PRE,
                     caller: "Cellular loop initial ",
                     log: log)
               } else {
                  await Time.waitUntilNextFullSecond(
                     additional: 0.0 - MOBILE_INTERNET_CHECK_NEXT_FULL_SECOND_SYNC_PRE,
                     caller: "Cellular loop initial ",
                     log: log)
               }
            } else {
               await Time.waitUntilNextFullSecond(
                  additional: 0.0 - MOBILE_INTERNET_CHECK_NEXT_FULL_SECOND_SYNC_PRE,
                  expectedMinimumNanos: UInt64(lround(Time.NANOS_PER_SECOND * (1.0 - 2 * MOBILE_INTERNET_CHECK_NEXT_FULL_SECOND_SYNC_PRE))),
                  caller: "Cellular loop ",
                  log: log)
            }
            
            // as long as important infos are not understood radio playing is not possible and the
            // warning message should not be overwritten by the cellular check
            await checkCellularConsumption(
               startCellularUsageUInt: SESSION_START_TOTAL_CONSUMPTION,
               lastCellularBytes: &lastCellularBytes,
               CHECK_START_DATE: sessionStartDate!,
               lastCheckDate: lastCheckDate,
               mobileLimitActor: mobileLimitActor,
               cellularUsageText: &cellularUsageText,
               stopConsumerActor: stopConsumerActor,
               log: log
            )
            lastCheckDate = Time.now()
            
            await mobileConsumptionTextActor.update(cellularUsageText)
            
            // complete the second
            await Time.waitUntilNextFullSecond(
               expectedMaximumNanos: UInt64(lround(Time.NANOS_PER_SECOND * MOBILE_INTERNET_CHECK_NEXT_FULL_SECOND_SYNC_PRE)),
               caller: "Cellular loop end ",
               log: log)
            
            // The sleep seems to fail sometimes in phone connected mode without error resulting in
            // * more log
            // * fast updates of KB/s metrics.
            // Without connections fast updates of KB/s metrics were not experienced.
            
         } while true
      } catch let ERROR {
         log.timed("cellularUsageText=" + ERROR.localizedDescription, typeName)
         await mobileConsumptionTextActor.update(ERROR.localizedDescription)
      }
   }
   
   fileprivate static func mobileLimitNotHandled(
      _ MOBILE_LIMIT: String,
      _ log: Log,
      _ cellularUsageText: inout String,
      _ stopConsumerActor: BoolActor,
      additionalInfo: String
   ) async {
      let ERROR_MESSAGE = "MOBILE_LIMIT " + MOBILE_LIMIT + " is not handled in checkCellularConsumption, " + additionalInfo
      log.timedError(ERROR_MESSAGE, Self.typeName)
      cellularUsageText = ERROR_MESSAGE
      await stopConsumerActor.update(true)
   }
   
   private static func checkCellularConsumption(
      startCellularUsageUInt: UInt64,
      lastCellularBytes: inout UInt64?,
      CHECK_START_DATE: Date,
      lastCheckDate: Date,
      mobileLimitActor : TextActor,
      cellularUsageText: inout String,
      stopConsumerActor: BoolActor,
      log: Log
   ) async {
      var mobileLimit : UInt64?
      let MOBILE_LIMIT: String = await mobileLimitActor.get()
      switch MOBILE_LIMIT {
         case MOBILE_LIMIT_NONE :
            mobileLimit = 0 // 0 seems to be too hard, 1 K packages are used sometimes even if Wifi is used
         case MOBILE_LIMIT_UNLIMITED :
            mobileLimit = nil

         default:
            let LIMIT_PARTS = MOBILE_LIMIT.split(separator: " ")
            for s in LIMIT_PARTS {
               log.timed("LIMIT_PART " + String(s), Self.typeName)
            }
            if LIMIT_PARTS.count != 2 {
               await mobileLimitNotHandled(MOBILE_LIMIT, log, &cellularUsageText, stopConsumerActor,
                                           additionalInfo: "trying to split into value and unit")
               return
            }
            guard var limit = UInt64(LIMIT_PARTS[0]) else {
               await mobileLimitNotHandled(MOBILE_LIMIT, log, &cellularUsageText, stopConsumerActor,
                                           additionalInfo: "value " + LIMIT_PARTS[0])
               return
            }
            switch LIMIT_PARTS[1] {
               case Units.KB : limit *= Units.K
               case Units.MB : limit *= Units.M
               case Units.GB : limit *= Units.G
               default:
                  await mobileLimitNotHandled(MOBILE_LIMIT, log, &cellularUsageText, stopConsumerActor,
                                              additionalInfo: "unit " + LIMIT_PARTS[1])
                  return
            }
            mobileLimit = limit
      }
      if mobileLimit == nil {
         log.timed("Determined no mobile limit", Self.typeName)
      } else {
         log.timed("Determined mobile limit \(mobileLimit!)", Self.typeName)
      }
      
      let CELLULAR_TOTAL_CONSUMPTION : UInt64 = SystemDataUsage.wwanComplete
      let CELLULAR_CONSUMPTION_WHILE_SESSION: UInt64 = CELLULAR_TOTAL_CONSUMPTION - startCellularUsageUInt
      let CELLULAR_TOTAL_CONSUMPTION_MB : Float = Float(CELLULAR_CONSUMPTION_WHILE_SESSION) / Float(Units.M)
      let DISTANCE_TO_SESSIONSTART : TimeInterval = CHECK_START_DATE.distance(to: Time.now())
      
      // Low Traffic Detection:
      // iOS has some low traffic also when using Wifi - this we want to allow and only display
      // ca. 1024 B / min. but sometimes in a 2048 burst (maybe sent/received)
      var isLowCellularTrafic = false
      var lowCellularTraficText = "" // or for tests to get info even if no low traffic is detected: \nno low traffic detected"
      if mobileLimit != nil && DISTANCE_TO_SESSIONSTART > 0.0 {
         let CELLULAR_CONSUMPTION_WHILE_SESSION_PER_MINUTE: Double = Double(CELLULAR_CONSUMPTION_WHILE_SESSION) / DISTANCE_TO_SESSIONSTART * 60
         isLowCellularTrafic =
         CELLULAR_CONSUMPTION_WHILE_SESSION <= 2048// sometimes 2 K packages are used
         || CELLULAR_CONSUMPTION_WHILE_SESSION_PER_MINUTE <= 1024.0 * 1.1 // allow 1 K per minute
         if CELLULAR_CONSUMPTION_WHILE_SESSION > mobileLimit! && isLowCellularTrafic {
            lowCellularTraficText = "\nlow mobile traffic \(CELLULAR_CONSUMPTION_WHILE_SESSION) B, \(lround(CELLULAR_CONSUMPTION_WHILE_SESSION_PER_MINUTE)) B/min"
         }
      }
      
      if mobileLimit != nil
            && CELLULAR_CONSUMPTION_WHILE_SESSION > mobileLimit!
            && !isLowCellularTrafic
      {
         // stop player(s) as long as the limit is reached
         await stopConsumerActor.update(true)
         
         cellularUsageText = CELLULAR_CONSUMPTION_SINCE_STARTUP_STRING
         + " \(round(CELLULAR_TOTAL_CONSUMPTION_MB*10)/10) MB. It has reached allowed limit "
         + MOBILE_LIMIT + ".\nStopped player."

      } else {
         // update view:
         let MB_TOTAL : Float = Float(CELLULAR_TOTAL_CONSUMPTION) / Float(Units.M)
         var KBperSec : Double // round fails to round to integer and show .0 instead while Double allows lround
         if lastCellularBytes == nil {
            KBperSec = 0.0 // initially no usage
         } else {
            let TIME_TO_LAST = lastCheckDate.distance(to: Time.now())
            if TIME_TO_LAST < 0.000000001 {
               // seems to be a more theoretic situation but should handled
               KBperSec = 999999999.0
            } else {
               KBperSec = Double(CELLULAR_TOTAL_CONSUMPTION - lastCellularBytes!) / Double(Units.K) / (TIME_TO_LAST)
               // TODO: perSecKB has no decimal part - why?
            }
         }
         lastCellularBytes = CELLULAR_TOTAL_CONSUMPTION
         
         cellularUsageText = "mobile \(round(MB_TOTAL*10.0)/10.0) \(CELLULAR_TOTAL_MB_STRING)\n"
         + "\(round(CELLULAR_TOTAL_CONSUMPTION_MB*10)/10) MB while session, \(lround(KBperSec)) KB/s"
         + lowCellularTraficText
         
         log.timed("details: \(MB_TOTAL) MB, \(KBperSec) KB/s", typeName)
      }
      log.timed("cellularUsageText=" + cellularUsageText + ", CELLULAR_SESSION_CONSUMPTION=\(CELLULAR_CONSUMPTION_WHILE_SESSION)", typeName)
   }
   
   
}

