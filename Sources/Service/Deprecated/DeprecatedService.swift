// MARK: Class implementation

/// Default implementation of a service.
/// Serves your `Call` to a server and parses the respons.
/// Response is delivered to you as a `Result` that you can use in a switch. You get the most detailed results with the functions below.
/// If you want you can use the convenience functions in the extension. They call these functions and print the errors by default. 
/// If you need more control over the errors you can use these functions directly.
/// _Remark_: If you need to cancel, know when everything is done, service request to continue in the background use `DeprecatedServiceQueue`.
/// _Warning_: The session holds a strong reference to it's delegates. You should invalidate or we do in at `deinit`
open class DeprecatedService {
    open let configuration: Configuration

    let faroSession: FaroSessionable

    public init(configuration: Configuration, faroSession: FaroSessionable = FaroSession()) {
        self.configuration = configuration
        self.faroSession = faroSession
    }

    // MARK: - Results transformed to Model(s)

    // MARK: - Update

    /// The other `perform` methods create the model. This function updates the model.
    /// - parameter call: gives the details to find the entity on the server
    /// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
    /// - parameter updateModel: JSON will be given to this model to update
    /// - parameter modelResult: `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
    /// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
    @discardableResult
    open func perform<M: JSONDeserializable & JSONUpdatable>(_ call: Call, on updateModel: M?, autoStart: Bool = true, modelResult: @escaping (DeprecatedResult<M>) -> ()) -> URLSessionDataTask? {

        return performJsonResult(call, autoStart: autoStart) { (jsonResult: DeprecatedResult<M>) in
            switch jsonResult {
            case .json(let json):
                modelResult(self.handle(json: json, on: updateModel, call: call))
            default:
                modelResult(jsonResult)
                break
            }
        }
    }

    // MARK: - Create

    /// On success create a model and updates it with the received JSON data.
    /// - parameter call: gives the details to find the entity on the server
    /// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
    /// - parameter modelResult : `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
    /// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
    @discardableResult
    open func perform<M: JSONDeserializable>(_ call: Call, autoStart: Bool = true, modelResult: @escaping (DeprecatedResult<M>) -> ()) -> URLSessionDataTask? {

        return performJsonResult(call, autoStart: autoStart) { (jsonResult: DeprecatedResult<M>) in
            switch jsonResult {
            case .json(let json):
                modelResult(self.handle(json: json, call: call))
            default:
                modelResult(jsonResult)
                break
            }
        }
    }

    // MARK: - With Paging information

    /// On success create a model and updates it with the received JSON data. The JSON is also passed to `page` closure and can be inspected for paging information.
    /// - parameter call: gives the details to find the entity on the server
    /// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
    /// - parameter modelResult : `Result<M: Deserializable>` closure should be called with `case Model(M)` other cases are a failure.
    /// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
    @discardableResult
    open func perform<M: JSONDeserializable, P: JSONDeserializable>(_ call: Call, page: @escaping(P?)->(), autoStart: Bool = true, modelResult: @escaping (DeprecatedResult<M>) -> ()) -> URLSessionDataTask? {

        return performJsonResult(call, autoStart: autoStart) { (jsonResult: DeprecatedResult<M>) in
            switch jsonResult {
            case .json(let json):
                modelResult(self.handle(json: json, call: call))
				if let json = json as? [String: Any] {
					page(try? P(json))
				}
            default:
                modelResult(jsonResult)
                break
            }
        }
    }

    // MARK: - JSON results

    /// Handles incomming data and tries to parse the data as JSON.
    /// - parameter call: gives the details to find the entity on the server
    /// - parameter autostart: by default this is true. This means that `resume()` is called immeditatly on the `URLSessionDataTask` created by this function.
    /// - parameter jsonResult: closure is called when valid or invalid json data is received.
    /// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
    @discardableResult
    open func performJsonResult<M: JSONDeserializable>(_ call: Call, autoStart: Bool = true, jsonResult: @escaping (DeprecatedResult<M>) -> ()) -> URLSessionDataTask? {

        guard let request = call.request(with: configuration) else {
            jsonResult(.failure(FaroError.invalidUrl("\(configuration.baseURL)/\(call.path)", call: call)))
            return nil
        }

        let task = faroSession.dataTask(with: request, completionHandler: { (data, response, error) in
			let dataResult = self.handle(data: data, urlResponse: response, error: error, for: request) as DeprecatedResult<M>
            switch dataResult {
            case .data(let data):
                self.configuration.adaptor.serialize(from: data) { (serializedResult: DeprecatedResult<M>) in
                    switch serializedResult {
                    case .json(json: let json):
                        jsonResult(.json(json))
                    default:
                        jsonResult(serializedResult)
                    }
                }
            default:
                jsonResult(dataResult)
            }

        })

        guard autoStart else {
            return task
        }

        faroSession.resume(task)
        return task
    }

    // MARK: - WRITE calls (like .POST, .PUT, ...)
    /// Use this to write to the server when you do not need a data result, just ok.
    /// If you expect a data result use `perform(call:result:)`
    /// - parameter call: should be of a type that does not expect data in the result.
    /// - parameter writeResult: `WriteResult` closure should be called with `.ok` other cases are a failure.
    /// - returns: URLSessionDataTask if the task could not be created that probably means the `URLSession` is invalid.
    @discardableResult
    open func performWrite(_ writeCall: Call, autoStart: Bool = true, writeResult: @escaping (WriteResult) -> ()) -> URLSessionDataTask? {

        guard let request = writeCall.request(with: configuration) else {
            writeResult(.failure(FaroError.invalidUrl("\(configuration.baseURL)/\(writeCall.path)", call: writeCall)))
            return nil
        }

        let task = faroSession.dataTask(with: request, completionHandler: { (data, response, error) in
            writeResult(self.handleWrite(data: data, urlResponse: response, error: error, for: request))
        })

        guard autoStart else {
            return task
        }

        faroSession.resume(task)
        return task
    }

    // MARK: - Handles

    open func handleWrite(data: Data?, urlResponse: URLResponse?, error: Error?, for request: URLRequest) -> WriteResult {
        if let faroError = raisesFaroError(data: data, urlResponse: urlResponse, error: error, for: request) {
            return .failure(faroError)
        }

        return .ok
    }

    open func handle<M: JSONDeserializable>(data: Data?, urlResponse: URLResponse?, error: Error?, for request: URLRequest) -> DeprecatedResult<M> {

		if let faroError = raisesFaroError(data: data, urlResponse: urlResponse, error: error, for: request) {
            return .failure(faroError)
        }

        if let data = data {
            return .data(data)
        } else {
            return .ok
        }
    }

    open func handle<M: JSONDeserializable>(json: Any, on updateModel: M? = nil, call: Call) -> DeprecatedResult<M> {

        let rootNode = call.rootNode(from: json)
        switch rootNode {
        case .nodeObject(let node):
            return handleNode(node, on: updateModel, call: call)
        case .nodeArray(let nodes):
            return handleNodeArray(nodes, on: updateModel, call: call)
		default:
            return DeprecatedResult.failure(.noModelOf(type: "\(M.self)", inJson: rootNode, call: call))
        }
    }

    // MARK: - Invalidate session
    /// All functions are forwarded to `FaroSession`

    open func finishTasksAndInvalidate() {
        faroSession.finishTasksAndInvalidate()
    }

    open func flush(completionHandler: @escaping () -> Void) {
        faroSession.flush(completionHandler: completionHandler)
    }

    open func getTasksWithCompletionHandler(_ completionHandler: @escaping ([URLSessionDataTask], [URLSessionUploadTask], [URLSessionDownloadTask]) -> Void) {
        faroSession.getTasksWithCompletionHandler(completionHandler)
    }

    open func invalidateAndCancel() {
        faroSession.invalidateAndCancel()
    }

    open func reset(completionHandler: @escaping () -> Void) {
        faroSession.reset(completionHandler: completionHandler)
    }

    deinit {
        faroSession.finishTasksAndInvalidate()
    }

}

// MARK: - Privates

extension DeprecatedService {

    fileprivate func raisesFaroError(data: Data?, urlResponse: URLResponse?, error: Error?, for request: URLRequest) -> FaroError? {
        guard error == nil else {
            let returnError = FaroError.nonFaroError(error!)
            return returnError
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            let returnError = FaroError.networkError(0, data: data, request: request)
            return returnError
        }

        let statusCode = httpResponse.statusCode
        guard statusCode < 400 else {
            let returnError = FaroError.networkError(statusCode, data: data, request: request)
            return returnError
        }

        guard 200...204 ~= statusCode else {
            let returnError = FaroError.networkError(statusCode, data: data, request: request)
            return returnError
        }

        return nil
    }

    fileprivate func handleNodeArray<M: JSONDeserializable>(_ nodes: [Any], on updateModel: M? = nil, call: Call) -> DeprecatedResult<M> {
        if let _ = updateModel {
            let faroError = FaroError.malformed(info: "Could not parse \(nodes) for type \(M.self) into updateModel \(updateModel). We currently only support updating of single objects. An arry of objects was returned")
            return DeprecatedResult.failure(faroError)
        }
        var models = [M]()
        for node in nodes {
			if let node = node as? [String: Any], let model = try? M(node) {
                models.append(model)
            } else {
                let faroError = FaroError.malformed(info: "Could not parse \(nodes) for type \(M.self)")
                return DeprecatedResult.failure(faroError)
            }
        }
        return DeprecatedResult.models(models)
    }

    fileprivate func handleNode<M: JSONDeserializable>(_ node: [String: Any], on updateModel: M? = nil, call: Call) -> DeprecatedResult<M> {
        if let updateModel = updateModel as? JSONUpdatable {
            do {
                try             updateModel.update(node)
            } catch {
                return DeprecatedResult.failure(.nonFaroError(error))
            }
            return DeprecatedResult.model(updateModel as? M)
        } else {
            return DeprecatedResult.model(try? M(node))
        }
    }

}
