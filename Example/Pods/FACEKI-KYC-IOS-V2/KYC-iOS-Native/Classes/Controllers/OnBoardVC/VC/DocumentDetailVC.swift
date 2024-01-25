//
//  DocumentDetailVC.swift
//  ScanDocument
//
//

import UIKit

class DocumentDetailVC: UIViewController {
    
    //MARK: -Instance Method
    class func documentDetailVc() -> DocumentDetailVC {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "DocumentDetailVC") as! DocumentDetailVC
    }
    
    //MARK: -Outlets
    @IBOutlet weak var checkMarkButton : UIButton!
    @IBOutlet weak var frontPicLabel : UILabel!
    @IBOutlet weak var backPicLabel : UILabel!
    @IBOutlet weak var passportFrontLabel : UILabel!
    @IBOutlet weak var drivingLicenseFrontLabel : UILabel!
    @IBOutlet weak var drivingLicenseBackLabel : UILabel!
    
    @IBOutlet weak var idFrontNumberLabel : UILabel!
    @IBOutlet weak var idBackNumberLabel : UILabel!
    @IBOutlet weak var passportNumberLabel : UILabel!
    @IBOutlet weak var dlFrontNumberLabel : UILabel!
    @IBOutlet weak var dlBackNumberLabel : UILabel!
    @IBOutlet weak var selfieNumberLabel : UILabel!
    
    @IBOutlet weak var frontPicView : UIView!
    @IBOutlet weak var backPicView : UIView!
    @IBOutlet weak var passportFrontView : UIView!
    @IBOutlet weak var drivingLicenseFrontView : UIView!
    @IBOutlet weak var drivingLicenseBackView : UIView!
    
    
    //MARK: -Properties
    var isMarkChecked = false
    var params : [String : Any] = [:]
    
    var idCardSelected : Bool?
    var isPassportSelected : Bool?
    var isDrivingLicenseSelected : Bool?
    var model : DocumentCopyRulesModel?
    
    //MARK: -LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        
        if self.model?.data?.allowSingle ?? false {
            
            if self.idCardSelected ?? false {
                backPicView.isHidden = false
                frontPicView.isHidden = false
                frontPicLabel.text = "Picture of your ID Card Front"
                backPicLabel.text = "Picture of your ID Card Back"
                
                passportFrontView.isHidden = true
                drivingLicenseBackView.isHidden = true
                drivingLicenseFrontView.isHidden = true
                
                idFrontNumberLabel.text = "1"
                idBackNumberLabel.text = "2"
                
            } else if self.isPassportSelected ?? false {
                backPicView.isHidden = true
                frontPicView.isHidden = false
                frontPicLabel.text = "Picture of your Passport Front"
                
                passportFrontView.isHidden = true
                drivingLicenseBackView.isHidden = true
                drivingLicenseFrontView.isHidden = true
                
                passportNumberLabel.text = "1"
                
            }  else if self.isDrivingLicenseSelected ?? false {
                backPicView.isHidden = false
                frontPicView.isHidden = false
                frontPicLabel.text = "Picture of your Driving License Front"
                backPicLabel.text = "Picture of your Driving License Back"
                
                passportFrontView.isHidden = true
                drivingLicenseBackView.isHidden = true
                drivingLicenseFrontView.isHidden = true
                
                dlFrontNumberLabel.text = "1"
                dlBackNumberLabel.text = "2"
            }
            selfieNumberLabel.text = "3"
        } else {
            var number = 1
            if isTypeAllowed(type: .idCard) {
                idFrontNumberLabel.text = String(describing: number)
                number += 1
                idBackNumberLabel.text = String(describing: number)
                number += 1
            }
            if isTypeAllowed(type: .passport) {
                passportNumberLabel.text = String(describing: number)
                number += 1
            }
            if isTypeAllowed(type: .drivingLicense) {
                dlFrontNumberLabel.text = String(describing: number)
                number += 1
                dlBackNumberLabel.text = String(describing: number)
                number += 1
            }
            selfieNumberLabel.text = String(describing: number)
            
            backPicView.isHidden = !isTypeAllowed(type: .idCard)
            frontPicView.isHidden = !isTypeAllowed(type: .idCard)
            frontPicLabel.text = "Picture of your ID Card Front"
            backPicLabel.text = "Picture of your ID Card Back"
            
            passportFrontView.isHidden = !isTypeAllowed(type: .passport)
            passportFrontLabel.text = "Picture of your Passport Front"
            
            drivingLicenseBackView.isHidden = !isTypeAllowed(type: .drivingLicense)
            drivingLicenseFrontView.isHidden = !isTypeAllowed(type: .drivingLicense)
            drivingLicenseFrontLabel.text = "Picture of your Driving License Front"
            drivingLicenseBackLabel.text = "Picture of your Driving License Back"
        }
        
        
        checkMarkButton.setImage(UIImage(systemName: "square"), for: .normal)
        
    }
    func isTypeAllowed(type: DocumentType) -> Bool {
            return self.model?.data?.allowedKycDocuments?.contains(type.rawValue) == true
        }
    
    //MARK: -Actions
    @IBAction private func didTapCheckMark(_ sender : UIButton ){
        if !isMarkChecked {
            checkMarkButton.tintColor = #colorLiteral(red: 1, green: 0.5852001864, blue: 0, alpha: 1)
            checkMarkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            isMarkChecked = true
        } else {
            checkMarkButton.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            checkMarkButton.setImage(UIImage(systemName: "square"), for: .normal)
            isMarkChecked = false
        }
    }
    
    @IBAction private func didTapNext(_ sender : UIButton) {
        if isMarkChecked {
            let vc = IDGuidelinesVC.idGiudlinesVc()
            vc.model = self.model
            vc.isCardSelected = self.idCardSelected
            vc.isPassportSelected = self.isPassportSelected
            vc.isDrivingLicenseSelected = self.isDrivingLicenseSelected
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            Utility.showAlertWithOk(title: "Alert", message: "Fill the Above checkmark First.")
        }
    }
    
    @IBAction private func didTapBack(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
