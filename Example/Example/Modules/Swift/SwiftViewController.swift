import UIKit
import Faro
import Stella

class Posts: Mappable {

    required init(json: AnyObject) {

    }

}

class SwiftViewController: UIViewController {
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let bar = ExampleBar()
        let call = Call(path: "posts")

        bar.perform(call) { (result: Result <Posts>) in
            dispatch_on_main {
                switch result {
                case .Model(let model):
                    self.label.text = "fetched posts"
                    print("🎉 \(model)")
                default:
                    print("💣 fail")
                }
            }
        }
    }

}
