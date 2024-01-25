//
//  ResultVC.swift
//  ScanDocument
//
//

import UIKit

class ResultVC: UIViewController {
    
    //MARK: -Instance Method
    class func resultVc() -> ResultVC {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "ResultVC") as! ResultVC
    }
    
    //MARK: -Outlets
    @IBOutlet weak var lottieAnimationView : UIView!
    
    var imagesData : [(imageName: String, imageData: Data)]?
    var model : DocumentCopyRulesModel?
    
    //MARK: -lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        if model?.data?.allowSingle ?? false {
            self.kycVerificationApiCall(imagesData: self.imagesData!, urlString: "https://sdk.faceki.com/kycverify/api/kycverify/kyc-verification")
        } else {
            self.kycVerificationApiCall(imagesData: self.imagesData!, urlString: "https://sdk.faceki.com/kycverify/api/kycverify/multi-kyc-verification")
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadAnimation()
        }
    }
    
    //MARK: -Methods
    private func loadAnimation(){
        let animationView = LottieAnimationView(name: "lottieLoading.json", bundle: frameworkImageBundle)
        animationView.frame = lottieAnimationView.bounds
        lottieAnimationView.addSubview(animationView)
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.9
        animationView.play()
    }
    
    private func presentFinalVC(resposeCode : Int){
        let vc = SuccessFailureVC.successFailureVc()
        vc.responsCode = resposeCode
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func kycVerificationApiCall(imagesData : [(imageName: String, imageData: Data)], urlString : String) {
        
        Task {
            do {
                let data = try await Request.shared.uploadMultipleImages(MultiVerificationModel.self, method: .post, imageDatas: self.imagesData!, url: urlString, authToken: Defaults.shared.getToken())
             
                
                self.presentFinalVC(resposeCode: data.responseCode ?? 1)
            } catch {
                self.presentFinalVC(resposeCode: 1)
            }
        }
        
    }
}
