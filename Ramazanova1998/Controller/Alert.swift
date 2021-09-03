//
//  alert.swift
//  Ramazanova1998
//
//  Created by Раисат Рамазанова on 03.09.2021.
//

import UIKit

final class Alert {
    
    class func showBasic(vc: UIViewController) {
        let alert = UIAlertController(title: "Error", message: "Try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    class func showUknownLocation() {
        DispatchQueue.main.async {
            guard let navigationController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? UINavigationController else { return }

                let alert = UIAlertController(title: "City not found!", message: "Try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                navigationController.present(alert, animated: true)
        }
    }
}
