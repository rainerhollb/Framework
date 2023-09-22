//
//  Device.swift
//  Wrapper for UIDevice constant data which cannot be stored there as static.
//
//  Created by rainer on 26.08.23.
//

import SwiftUI
import Extensions

public struct Device {
   public static let MODEL_IDENTIFIER = UIDevice.modelIdentifier()
   public static let DEVICE_CODE = UIDevice.deviceCode() // may be the same as MODEL_IDENTIFIER
   
   /**
    individual name until iOS 15:
    since iOS 16 not individual until entitlement is asked for, see https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_device-information_user-assigned-device-name
    */
   public static let DEVICE_NAME = UIDevice.current.name


   public static let MODEL_NAME = UIDevice.modelName()

   public static let IS_SIMULATOR = UIDevice.isSimulator()
   public static let HAS_SMALL_SCREEN = UIScreen.main.bounds.height <= 700.0 // i.e. iPhone 6s, 7 and 8 having 667
   public static let HAS_LARGE_SCREEN_WIDTH = UIScreen.main.bounds.width >= 700

   public static let IS_NEW_GENERATION = UIDevice.isNewGeneration()
   public static let MAY_BE_MAC: Bool = MODEL_NAME == "iPad Pro 12.9 inch 3rd Gen (1TB, WiFi)"
   public static let HAS_CELLULAR: Bool = !MODEL_NAME.contains("WiFi")

   // not strict Device, more GUI elements
   public static let PICKER_DEFAULT_WHEEL_FONT: Font = .title3
   
   public static let OS_RELEASE = UIDevice.current.systemVersion
   public static let OS_RELEASE_MAJOR_NUMBER = osReleaseMajorNumber()

   /**
    Log to file without entering and leaving the log group semaphore.
    PRE: fileUpdater is set => log group was entered
    */
   public static func logDeviceInfosInGroup(_ log: Log, _ loggingClass: String) {
      log.logInGroup("device model identifier " + Device.MODEL_IDENTIFIER, loggingClass)
      
      log.logInGroup("device name " + Device.DEVICE_NAME, loggingClass)
      
      log.logInGroup("device model " + UIDevice.current.model, loggingClass)
      log.logInGroup("device system " + UIDevice.current.systemName, loggingClass)
      log.logInGroup("device system version " + UIDevice.current.systemVersion, loggingClass)
      log.logInGroup(" -> major release number " + String(osReleaseMajorNumber()), loggingClass)
      log.logInGroup("device model name " + Device.MODEL_NAME, loggingClass)
      if Device.HAS_SMALL_SCREEN {
         log.logInGroup("device is categorized as having a small screen like iPhone 8", loggingClass)
      }
      if Device.IS_SIMULATOR {
         log.logInGroup("device is categorized as simulator", loggingClass)
      }
      if Device.DEVICE_CODE != nil
      {
         log.logInGroup("device code " + Device.DEVICE_CODE!, loggingClass)
      } else {
         log.logInGroup("device code not found", loggingClass)
      }
      if Device.IS_NEW_GENERATION {
         log.logInGroup("device classified as new generation")
      } else {
         log.logInGroup("device classified as old generation")
      }
      log.logInGroup("device screen width \(UIScreen.main.bounds.width) * height \(UIScreen.main.bounds.height)")
   }

   private static func osReleaseMajorNumber() -> Int {
      if !OS_RELEASE.contains(".") {
         Log.timed("OS release does not contain a dot: " + OS_RELEASE)
      }
      
      let NUMBER_STRING = OS_RELEASE.split(separator: ".")[0]
      return Int(NUMBER_STRING)!
   }

}
