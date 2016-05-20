//
//  MitigatorNoPrinting.swift
//  Pods
//
//  Created by Stijn Willems on 20/05/16.
//
//

import Foundation

/**
Use this for instance in tests to disable printing. This is a subclass from `DefaultMitigator`. 
It has the same throwing behaviour but does not print.
*/

public class MitigatorNoPrinting: DefaultMitigator {

	// MARK: RequestMitigatable

	public override func invalidBodyError() throws -> () {
		throw RequestError.InvalidBody
	}

	public override func generalError() throws {
		throw RequestError.General
	}


	// MARK: ResponseMitigatable

	public override func invalidAuthenticationError() throws {
		throw ResponseError.InvalidAuthentication
	}

	public override func invalidResponseData(data: NSData?) throws {
		throw ResponseError.InvalidResponseData(data: data)
	}


	public override func invalidDictionary(dictionary: AnyObject) throws -> AnyObject? {
		throw ResponseError.InvalidDictionary(dictionary: dictionary)
	}

	public override func responseError(error: NSError?) throws {
		throw ResponseError.ResponseError(error: error)
	}

	public override func generalError(statusCode: Int) throws -> (){
		throw RequestError.General
	}

	public override func generalError(statusCode: Int , responseJSON: AnyObject) throws -> () {
		throw RequestError.General
	}
}