import Foundation

public func printFaroError(_ error: Error) {
	var faroError = error
	if !(error is FaroError) {
		faroError = FaroError.nonFaroError(error)
	}
	switch faroError as! FaroError {
	case .general:
		print("📡🔥 General service error")
	case .invalidUrl(let url):
		print("📡🔥invalid url: \(url)")
	case .invalidResponseData(_):
		print("📡🔥 Invalid response data")
	case .invalidAuthentication:
		print("📡🔥 Invalid authentication")
	case .shouldOverride:
		print("📡🔥 You should override this method")
	case .nonFaroError(let nonFaroError):
		print("📡🔥 Error from service: \(nonFaroError)")
	case .rootNodeNotFound(json: let json):
		print("📡🔥 Could not find root node in json: \(json)")
	case .networkError(let networkError, let data, let request):
		if let data = data {
			var string: String!
			if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
				let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
				string = String(data: prettyPrintedData, encoding: .utf8)
			} else {
				string = String(data: data, encoding: .utf8)
			}

			print("📡🔥 HTTP error: \(networkError) in \(request) message: \(string)")
		} else {
			print("📡🔥 HTTP error: \(networkError) in \(request)")
		}
	case .emptyCollection:
		print("📡🔥 empty collection")
	case .emptyKey:
		print("📡🔥 missing key")
	case .emptyValue(let key):
		print("📡❓no value for key " + key)
	case .malformed(let info):
		print("📡🔥 \(info)")
	case .serializationError:
		print("📡🔥 serialization error")
	case .updateNotPossible(json: let json, model: let model):
		print("📡❓ update not possilbe with \(json) on model \(model)")
	case .invalidSession(message: let message, request: let request):
		print("📡🔥 you tried to perform a \(request) on a session that is invalid")
		print("📡🔥 message: \(message)")
	case .couldNotCreateTask:
		print("📡🔥 a valid urlSessionTask could not be created")
	case .noModelFor(call: let call, inJson: let jsonNode):
		print("📡🔥 \(call) could not instantiate model(s) form \(jsonNode).")
	case .invalidDeprecatedResult(call: let call, resultString: let result):
		print("📡🔥 \(call) invalid \(result)")
	}

}
