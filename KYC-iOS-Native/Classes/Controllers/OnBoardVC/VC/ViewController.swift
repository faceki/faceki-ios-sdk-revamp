//
//  ViewController.swift
//  ScanDocument
//
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: -Instance Method
    class func viewController() -> ViewController {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "ViewController") as! ViewController
    }
    
    //MARK: -Outlets
    @IBOutlet weak var lottieAnimationView : UIView!
    
    //MARK: -Properties
    var allowSingle : Bool?
    var viewModel = HomeViewModel()
    
    //MARK: -lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadAnimation()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool){
    }
    
    //MARK: -Actions
    @IBAction private func didTapNext(_ sender : UIButton) {
        self.startActivityIndicator()
        self.getDocumentRulesApiCall()
    }
    
    //MARK: -Methods
    private func loadAnimation(){
        let animationView = LottieAnimationView(name: "lottieGuidance.json", bundle: frameworkImageBundle)
//        let animationView = LottieAnimationView(name: "lottieGuidance.json")
        animationView.frame = lottieAnimationView.bounds
        lottieAnimationView.addSubview(animationView)
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.7
        animationView.play()
    }
    
    private func getDocumentRulesApiCall(){
        Task {
            do{
                var result = try await viewModel.documentCopyRulesApiCall()
//                result.data?.allowSingle = true
//                result.data?.allowedKycDocuments = [DocumentType.idCard.rawValue,DocumentType.passport.rawValue,DocumentType.drivingLicense.rawValue]
                self.stopActivityIndicator()
                if let allowSingle = result.data?.allowSingle {
                    if allowSingle {
                        let vc = DocumentSelectionVC.documentSelectionVc()
                        vc.model = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = DocumentDetailVC.documentDetailVc()
                        vc.model = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            } catch (let error) {
                print(error)
                self.stopActivityIndicator()
                Utility.showAlertWithOk(title: "Error", message: "An error Occurred, try again later.")
            }
        }
    }
    
    
}

