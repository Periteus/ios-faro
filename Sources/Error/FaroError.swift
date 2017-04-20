public enum FaroError: Error, Equatable {
	public init(_ error: FaroError) {
		self = error
	}

	case general

	case invalidUrl(String)
	case invalidResponseData(Data?)
	case invalidAuthentication

	case shouldOverride
	case nonFaroError(Error)

	case emptyKey
	case emptyValue(key: String)
	case emptyCollection(key: String, json: [String: Any])

	case malformed(info: String)

	case serializationError
	case rootNodeNotFound(json: Any)

	case updateNotPossible(json: Any, model: Any)

	case invalidSession(message: String, request: URLRequest)
	case networkError(Int, data: Data?, request: URLRequest)

	case couldNotCreateTask

	case noModelFor(call: Call, inJson: JsonNode)
	case invalidDeprecatedResult(call: Call, resultString: String)
}

public func == (lhs: FaroError, rhs: FaroError) -> Bool {
	switch (lhs, rhs) {
	case (.general, .general):
		return true
	case (.invalidAuthentication, .invalidAuthentication):
		return true
	case (.invalidUrl(let url_lhs), .invalidUrl(let url_rhs)): // tailor:disable
		return url_lhs == url_rhs
	case (.invalidResponseData (_), .invalidResponseData (_)):
		return true
	case (.networkError(let lStatusCode, _, _ ), .networkError(let rStatusCode, _, _)):
		return lStatusCode == rStatusCode
	default:
		return false
	}
}
