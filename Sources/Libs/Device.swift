//
//  Device.swift
//  Wrapper for UIDevice constant data which cannot be stored there as static.
//
//  Created by rainer on 26.08.23.
//

import SwiftUI
import Framework

struct Device {
   static let MODEL_IDENTIFIER = UIDevice.modelIdentifier()
   static let MODEL_NAME = UIDevice.modelName()
   static let DEVICE_CODE = UIDevice.deviceCode()

   static let IS_SIMULATOR = UIDevice.isSimulator()
   static let HAS_SMALL_SCREEN = UIScreen.main.bounds.height <= 700.0 // i.e. iPhone 7 and 8 have 667
   static let HAS_LARGE_SCREEN_WIDTH = UIScreen.main.bounds.width >= 700

   static let IS_NEW_GENERATION = UIDevice.isNewGeneration()

   // not strict Device, more GUI elements
   static let PICKER_DEFAULT_WHEEL_FONT: Font = .title3

}
