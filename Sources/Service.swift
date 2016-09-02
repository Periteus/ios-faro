
public class Service {
    let configuration : Configuration

    public init (configuration : Configuration) {
        self.configuration = configuration
    }
    
    /// You should override this and could use it like in `JSONService`
    public func serve <M : Mappable> (order: Order, result: (Result <M>)->()) {
        result(.Failure(Error.ShouldOverride))
    }

    public func checkStatusCodeAndData(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) throws -> NSData? {
        guard error == nil else {
           throw Error.Error(error)
           return nil
        }

        if let httpResponse = urlResponse as? NSHTTPURLResponse {

            let statusCode = httpResponse.statusCode

            guard statusCode != 404 else {
                throw Error.InvalidAuthentication
                return nil
            }

            guard 200...201 ~= statusCode else {
                return data
            }

            guard let data = data else {
                return nil
            }

            return data
        }
        else {
            return data
        }
    }
}

