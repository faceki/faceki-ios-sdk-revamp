//
//  SuccessFailureVC.swift
//  ScanDocument
//
//

import UIKit

class SuccessFailureVC: UIViewController {
    
    //MARK: -Instance Method
    class func successFailureVc() -> SuccessFailureVC {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "SuccessFailureVC") as! SuccessFailureVC
    }
    
    //MARK: -Outlets
    @IBOutlet weak var lottieAnimationView : UIView!
    @IBOutlet weak var statusTitleLabel : UILabel!
    @IBOutlet weak var statusSubtitleLabel : UILabel!
    
    //MARK: -Properties
    var responsCode : Int?
    
    //MARK: -LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        if let responsCode {
            self.loadAnimation()
            if responsCode == 0 {
                statusTitleLabel.text = "Successful"
                statusSubtitleLabel.text = "Your identity verification successful"
            } else {
                statusTitleLabel.text = "Failed"
                statusSubtitleLabel.text = "Your identity verification failed"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                FacekiredirectBack!()
            }
        }
    }
    
    //MARK: -Methods
    private func loadAnimation(){
        let animationView = LottieAnimationView(name: self.responsCode == 0 ? "lottieSuccess.json" : "lottieFail.json", bundle: frameworkImageBundle)
        animationView.frame = lottieAnimationView.bounds
        lottieAnimationView.addSubview(animationView)
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.9
        animationView.play()
    }
    
}
