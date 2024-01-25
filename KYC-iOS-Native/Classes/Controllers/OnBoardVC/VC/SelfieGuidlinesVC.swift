//
//  SelfieGuidlinesVC.swift
//  ScanDocument
//
//

import UIKit
import MobileCoreServices

class SelfieGuidlinesVC: UIViewController {
    
    //MARK: -Instance Method
    class func selfieGuidlinesVc() -> SelfieGuidlinesVC {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "SelfieGuidlinesVC") as! SelfieGuidlinesVC
    }
    
    //MARK: -Properties
    private var imagePickerController: UIImagePickerController?
    private var overlayLabel = UILabel(frame: .zero)
    @IBOutlet weak var guideImage : UIImageView!

    var frontIdCardImage : UIImage?
    var backIdCardImage : UIImage?
    var frontPassportImage : UIImage?
    var frontDrivingLicenseImage : UIImage?
    var backDrivingLicenseImage : UIImage?
    
    var idCardImages : [UIImage] = []
    var passportImages : [UIImage] = []
    
    var model : DocumentCopyRulesModel?
    var isCardSelected : Bool?
    var isPassportSelected : Bool?
    var isDrivingLicenseSelected : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        
        if let url = URL(string: Faceki_selfieImageUrl) {
                  downloadImage(from: url)
              }
    }
    
    @IBAction private func didTapReady(_ sender : UIButton) {
        let vc = SelfieVC.selfieVc()
        vc.model = self.model
        vc.isCardSelected = self.isCardSelected
        vc.isDrivingLicenseSelected = self.isDrivingLicenseSelected
        vc.isPassportSelected = self.isPassportSelected
        
        if self.model?.data?.allowSingle ?? false {
            
            if isCardSelected ?? false {
                vc.idCardFrontImg = self.frontIdCardImage
                vc.idCardBackImg = self.backIdCardImage
                
            } else if isPassportSelected ?? false {
                vc.passportFrontImg = self.frontPassportImage
                
            } else if isDrivingLicenseSelected ?? false {
                vc.drivingLicenseFrontImg = self.frontDrivingLicenseImage
                vc.drivingLicenseBackImg = self.backDrivingLicenseImage
            }
            
        } else {
            vc.idCardFrontImg = self.frontIdCardImage
            vc.idCardBackImg = self.backIdCardImage
            vc.passportFrontImg = self.frontPassportImage
            vc.drivingLicenseFrontImg = self.frontDrivingLicenseImage
            vc.drivingLicenseBackImg = self.backDrivingLicenseImage
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func didTapBack(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func downloadImage(from url: URL) {
          URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                  // Ensure that the downloaded data is a valid image
                  if let image = UIImage(data: data) {
                      // Update the UI on the main thread
                      DispatchQueue.main.async {
                          self.guideImage.image = image
                      }
                  }
              }
          }.resume()
      }

}
