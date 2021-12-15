import Foundation
import UIKit

class AlertService {
    func alert() -> AlertViewController {
        let storyboard = UIStoryboard(name: "Alert", bundle: nil)
        let alertViewConroller = storyboard.instantiateViewController(withIdentifier: "Alert") as! AlertViewController
        return alertViewConroller
    }
}

