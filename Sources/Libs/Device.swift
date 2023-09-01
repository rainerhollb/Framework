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

   // not strict Device, more GUI elements
   public static let PICKER_DEFAULT_WHEEL_FONT: Font = .title3

}
