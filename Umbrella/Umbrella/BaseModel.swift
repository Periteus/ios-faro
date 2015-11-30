//
//  BaseModel.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation


//A requestController should be able to build up a request when your model object complies to this protocol.

public protocol BaseModel: class {
	
	var objectId: String? {get set}
	
	static func serviceParameters() ->  ServiceParameters
	
/**
In your implementation create a general ErrorController.
If needed an error controller that is type specific can be made.
*/
	var errorController: ErrorController {get set}
	
	
//MARK: Initialisation from json
/**
* Set all properties from the received JSON at initialization
*/
	init(json: AnyObject)
/**
* Set all properties from the received JSON
*/
	func importFromJSON(json: AnyObject)
	
//MARK: Request building
/**
* An url is formed from <ServiceParameter.serverURL+BaseModel.contextPath>.
*/
	static func contextPath() -> String
	
/**
* Override if you want to POST this as JSON
*/
	func body()-> NSDictionary?
	

	
}