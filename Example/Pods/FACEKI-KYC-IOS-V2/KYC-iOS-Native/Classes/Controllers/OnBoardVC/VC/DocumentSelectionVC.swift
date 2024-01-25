//
//  DocumentSelectionVC.swift
//  ScanDocument
//
//

import UIKit
enum DocumentType: String {
    case idCard = "ID Card"
    case passport = "Passport"
    case drivingLicense = "Driving License"
}
class DocumentSelectionVC: UIViewController {
    
    //MARK: -Instance Method
    class func documentSelectionVc() -> DocumentSelectionVC {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "DocumentSelectionVC") as! DocumentSelectionVC
    }
    
    //MARK: -Outlets
    @IBOutlet weak var idCardView : UIView!
    @IBOutlet weak var passportView : UIView!
    @IBOutlet weak var drivingLicenseView : UIView!
    @IBOutlet weak var idCardCircle : UIImageView!
    @IBOutlet weak var passportCircle : UIImageView!
    @IBOutlet weak var drivingLicenseCircle : UIImageView!
    
    var idCardSelected = false
    var ispassportSelected = false
    var isDrivingLicenseSelected = false
    var allowSingle : Bool?
    var allowedKycDocuments = [String]()
    
    var model : DocumentCopyRulesModel?
    
    //MARK: -lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        idCardView.isHidden = true
        passportView.isHidden = true
        drivingLicenseView.isHidden = true
        
        if let allowSingleTrue = model?.data?.allowSingle, allowSingleTrue,
           let allowedKycDocumentsArray = model?.data?.allowedKycDocuments as? [String] {
            
            if allowedKycDocumentsArray.contains("ID Card") {
                idCardView.isHidden = false
                
            }
            if allowedKycDocumentsArray.contains("Passport") {
                passportView.isHidden = false
                
            }
            
            if allowedKycDocumentsArray.contains("Driving License") {
                drivingLicenseView.isHidden = false
                
            }
        } else {
            passportView.isHidden = false
            idCardView.isHidden = false
            drivingLicenseView.isHidden = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: -Actions
    @IBAction func idCardSelectionGesture(_ sender: UITapGestureRecognizer) {
        self.toggleSelectionView(selectedView: idCardView, selectedImageView: idCardCircle, unselectedViews: [drivingLicenseView,passportView], unselectedImageViews: [drivingLicenseCircle,passportCircle])
        self.idCardSelected = true
        self.ispassportSelected = false
        self.isDrivingLicenseSelected = false
    }
    
    @IBAction func passportSelectionGesture(_ sender: UITapGestureRecognizer) {
        self.toggleSelectionView(selectedView: passportView, selectedImageView: passportCircle, unselectedViews: [drivingLicenseView,idCardView] , unselectedImageViews: [drivingLicenseCircle,idCardCircle])
        self.ispassportSelected = true
        self.idCardSelected = false
        self.isDrivingLicenseSelected = false
    }
    
    @IBAction func drivingLicenseSelectionGesture(_ sender: UITapGestureRecognizer) {
        self.toggleSelectionView(selectedView: drivingLicenseView, selectedImageView: drivingLicenseCircle, unselectedViews: [passportView,idCardView] , unselectedImageViews: [passportCircle,idCardCircle])
        self.ispassportSelected = false
        self.idCardSelected = false
        self.isDrivingLicenseSelected = true
    }
    
    @IBAction private func didTapNext(_ sender : UIButton) {
        if ispassportSelected == true || idCardSelected == true || isDrivingLicenseSelected == true {
            let vc = DocumentDetailVC.documentDetailVc()
            vc.model = self.model
            vc.idCardSelected = self.idCardSelected
            vc.isDrivingLicenseSelected = self.isDrivingLicenseSelected
            vc.isPassportSelected = self.ispassportSelected
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            Utility.showAlertWithOk(title: "Empty", message: "Select the Above Document Field.")
        }
    }
    
    @IBAction private func didTapBack(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -Methods
    
    private func toggleSelectionView(selectedView : UIView,selectedImageView : UIImageView, unselectedViews : [UIView], unselectedImageViews : [UIImageView]) {
        selectedView.layer.borderWidth = 0.7
        selectedView.layer.borderColor = #colorLiteral(red: 1, green: 0.5852001864, blue: 0, alpha: 1)
        selectedImageView.image = UIImage(systemName: "circle.circle.fill")
        selectedImageView.tintColor = #colorLiteral(red: 1, green: 0.5852001864, blue: 0, alpha: 1)
        
        unselectedViews.forEach { unselectedView in
            unselectedView.layer.borderWidth = 0
            unselectedView.layer.borderColor = #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.24)
        }
        
        unselectedImageViews.forEach { unselectedImageView in
            unselectedImageView.image = UIImage(systemName: "circle.circle")
            unselectedImageView.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        }
    }
    
}
