//
//  Extensions.swift
//  ScanDocument
//
//

import Foundation
import UIKit

class Utility {
    
    class func showAlertWithOk(title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            print("OK button tapped")
        }
        alertController.addAction(okAction)
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
}

public extension UIViewController{
    var activityIndicatorTag: Int { return 999999 }
    func startActivityIndicator(
        style: UIActivityIndicatorView.Style = .medium,
        location: CGPoint? = nil) {
            
            //Set the position - defaults to `center` if no`location`
            
            //argument is provided
            
            let loc = location ?? self.view.center
            
            //Ensure the UI is updated from the main thread
            
            //in case this method is called from a closure
            
            DispatchQueue.main.async {
                
                //Create the activity indicator
                
                let activityIndicator = UIActivityIndicatorView(style: style)
                //Add the tag so we can find the view in order to remove it later
                
                activityIndicator.tag = self.activityIndicatorTag
                //Set the location
                if #available(iOS 13.0, *) {
                    activityIndicator.color = UIColor(hexString: "#C0C0C0")
                } else {
                    activityIndicator.color = UIColor(hexString: "#C0C0C0")
                }
                activityIndicator.center = loc
                activityIndicator.hidesWhenStopped = true
                //Start animating and add the view
                
                activityIndicator.startAnimating()
                self.view.addSubview(activityIndicator)
            }
        }
    func stopActivityIndicator() {
        
        //Again, we need to ensure the UI is updated from the main thread!
        
        DispatchQueue.main.async {
            
            
            //Here we find the `UIActivityIndicatorView` and remove it from the view
            
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
