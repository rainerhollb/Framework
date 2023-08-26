//
//  Device.swift
//  Wrapper for UIDevice constant data which cannot be stored there as static.
//
//  Created by rainer on 26.08.23.
//

import Foundation
import UIKit

struct Device {
   static let MODEL_IDENTIFIER = UIDevice.modelIdentifier()
   static let MODEL_NAME = UIDevice.modelName()
   static let DEVICE_CODE = UIDevice.deviceCode()

   static let IS_SIMULATOR = UIDevice.isSimulator()
   static let HAS_SMALL_SCREEN = UIDevice.hasSmallScreen()
   static let IS_NEW_GENERATION = UIDevice.isNewGeneration()

}
