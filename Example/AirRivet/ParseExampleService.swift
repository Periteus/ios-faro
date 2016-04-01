
import AirRivet

/**
This is an example implementation of the protocol Service parameters. You can use this class in conjunction with a requestController like:

```
class ViewController: UIViewController {
let requestController = RequestController<GameScore>(serviceParameters: ParseExampleService <GameScore>())

override func viewDidLoad() {
	super.viewDidLoad()

	do {
		try requestController.retrieve({ (response) in
			print(response)
		})
	}catch {
		print("-------Error with request------")
	}

	}
}
```
*/
class ParseExampleService <BodyType: BaseModel>: ServiceParameters {
	var serverUrl = "https://api.parse.com/1/classes/"
	var request: NSMutableURLRequest {
		let URL = NSURL(string: "\(serverUrl)\(BodyType.contextPath())")
		let request = NSMutableURLRequest(URL: URL!)

		// Headers

		request.addValue("oze24xbiOCeIdsM11C6MXK2RMLunOmoAWQ5VB6XZ", forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("Bd99hIeNb8sa0ZBIVLYWy9wpCz4Hb5Kvri3NiqBu", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		return request
	}
}