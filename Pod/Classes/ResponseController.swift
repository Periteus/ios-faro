import Foundation

/**
Deal with the errors of the response and interpret the respons.

#Tasks

## Handle errors in response
Errors cause an throw
## Pass response to the TransformController 
Responses are interpretted in the TransFormController
*/
public class ResponseController {

	/**
	- parameter transformController: a default implementation is given that transforms from JSON to your model object of `ResponseType`
	- returns: Properly instantiated ResponseController
	*/
	public init() {
	}
	
	func handleResponse<ResponseType: protocol<Parsable, ErrorControlable, UniqueAble> >(environment: Transformable, response:  (data: NSData?, urlResponse: NSURLResponse?), body: ResponseType? = nil, completion: (ResponseType)->()) throws {

        guard let data = try ResponseControllerUtils.checkStatusCodeAndData(response, errorController: ResponseType.requestErrorController()) else {
			return
		}

		try environment.transFormcontroller().transform(data, body: body, completion: completion)
	}

	func handleResponse<ResponseType: protocol<Parsable, ErrorControlable, UniqueAble> >(environment: Transformable, response:  (data: NSData?, urlResponse: NSURLResponse?), body: ResponseType? = nil, completion: ([ResponseType])->()) throws{

		guard let data = try ResponseControllerUtils.checkStatusCodeAndData(response, errorController: ResponseType.requestErrorController()) else {
			return
		}

		try environment.transFormcontroller().transform(data, body: body, completion: completion)
    }
}

internal class ResponseControllerUtils {
    class func checkStatusCodeAndData(response: (data: NSData?, urlResponse: NSURLResponse?), errorController: ErrorController) throws -> NSData? {
        if let httpResponse = response.urlResponse as? NSHTTPURLResponse {
            
            let statusCode = httpResponse.statusCode
            
            guard statusCode != 404 else {
                try errorController.requestAuthenticationError()
                return nil
            }
            
            guard 200...201 ~= statusCode else {
                try errorController.requestGeneralError()
                return nil
            }
            
            guard let data = response.data else {
                try errorController.responseDataEmptyError()
                return nil
            }
            
            return data
        }
        else {
            try errorController.responseInvalidError()
            return nil
        }
    }
}