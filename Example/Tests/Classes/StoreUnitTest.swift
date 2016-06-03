//
//  File.swift
//  AirRivet
//
//  Created by Stijn Willems on 03/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import AirRivet

class StoreUnitTests: CoreDataUnitTest {
	static let sharedInstance = StoreUnitTests()

	init(){
		super.init(modelName:"Model")
	}
}