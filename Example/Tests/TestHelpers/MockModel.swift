import Faro

class MockModel: JSONDeserializable {
    var uuid: String?

	required init(_ raw: [String: Any]) throws {
		try update(raw)
	}

}

extension MockModel: JSONUpdatable {

	func update(_ raw: [String: Any]) throws {
		self.uuid |< raw["uuid"]
	}

}
