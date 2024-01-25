//
//  IDGuidelinesVC.swift
//  ScanDocument
//
//

import UIKit

class IDGuidelinesVC: UIViewController {
    
    //MARK: -Instance Method
    class func idGiudlinesVc() -> IDGuidelinesVC {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "IDGuidelinesVC") as! IDGuidelinesVC
    }
    
    @IBOutlet weak var guideImage : UIImageView!

    
    //MARK: -Properties
    var model : DocumentCopyRulesModel?
    var isCardSelected : Bool?
    var isPassportSelected : Bool?
    var isDrivingLicenseSelected : Bool?
    
    //MARK: -LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        
        if let url = URL(string: Faceki_cardGuideUrl) {
                  downloadImage(from: url)
              }
    }
    
    //MARK: -Actions
    @IBAction private func didTapReady(_ sender : UIButton) {
        let vc = ScanDocumentVC.scanDocument()
        vc.model = self.model
        vc.isCardSelected = self.isCardSelected
        vc.isPassportSelected = self.isPassportSelected
        vc.isDrivingLicenseSelected = self.isDrivingLicenseSelected
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
