//
//  ScanDocumentVC.swift
//  ScanDocument
//
//

import UIKit
import AVFoundation
import AudioToolbox

class ScanDocumentVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    //MARK: -Instance Method
    class func scanDocument() -> ScanDocumentVC {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "ScanDocumentVC") as! ScanDocumentVC
    }
    
    //MARK: -Outlets
    @IBOutlet weak var overLayView: UIView!
    @IBOutlet weak var overLayView2: UIView!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var safeAreaView: UIView!
    @IBOutlet weak var scanTitle: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var qualityCheckErrorView: UIView!
    @IBOutlet weak var errorDescription : UILabel!
    @IBOutlet weak var errorTitle : UILabel!
    
    //MARK: -Properties
    var model : DocumentCopyRulesModel?
    var isCardSelected: Bool?
    var isDrivingLicenseSelected : Bool?
    var isPassportSelected : Bool?
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    var idCardFrontImg: UIImage?
    var idCardBackImg: UIImage?
    var passportFrontImg: UIImage?
    //    var passportBackImg: UIImage?
    var drivingLicenseFrontImg : UIImage?
    var drivingLicenseBackImg : UIImage?
    
    //MARK: -lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        qualityCheckErrorView.isHidden = true
        qualityCheckErrorView.clipsToBounds = true
        
        var scanLabelTitle = ""
        
        if self.model?.data?.allowSingle ?? false {
            if isCardSelected ?? false {
                scanLabelTitle = "Scan the Front ID Card side"
            } else if isPassportSelected ?? false {
                scanLabelTitle = "Scan the Front Passport side"
            } else if isDrivingLicenseSelected ?? false {
                scanLabelTitle = "Scan the Front Driving License side"
            }
        } else {
            if isTypeAllowed(type: .idCard) {
                scanLabelTitle = "Scan the Front ID Card side"
            } else if isTypeAllowed(type: .passport) {
                scanLabelTitle = "Scan the Front Passport side"
            } else if isTypeAllowed(type: .drivingLicense) {
                scanLabelTitle = "Scan the Front Driving License side"
            }
        }
        
        self.configureScanLabel(label: scanLabelTitle)
        
        capturePhotoOutput = AVCapturePhotoOutput()
        
        if let capturePhotoOutput = capturePhotoOutput {
            if captureSession.canAddOutput(capturePhotoOutput) {
                captureSession.addOutput(capturePhotoOutput)
            }
        }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo  // Updated for iOS 15
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        let devices = discoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                captureDevice = device
                if captureDevice != nil {
                    print("Capture device found")
                    beginSession()
                }
            }
        }
    }
    
    //MARK: -Actions
    @IBAction private func didTapBack(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func capturePhoto(_ sender : UIButton) {
        DispatchQueue.main.async {[weak self] in
            guard let self else { return}
            startActivityIndicator(style: .large)
        }
        
        guard let capturePhotoOutput = capturePhotoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        
        if let videoConnection = capturePhotoOutput.connection(with: .video) {
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        } else {
            print("No active and enabled video connection")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = UIScreen.main.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: self.view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: self.view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
                    
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                }
            }
        }
    }
    
    private func configureDevice() {
        let _: NSErrorPointer = nil
        if let device = captureDevice {
            //device.lockForConfiguration(nil)
            
            do {
                try captureDevice!.lockForConfiguration()
                
            } catch _ as NSError {
                //                error.memory = error1
            }
            
            device.focusMode = .locked
            device.unlockForConfiguration()
        }
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData) {
                
                
                /// ToDO
               let newimage = image.scale(newWidth: 640)
               let datax = newimage.convertImageToJPEGData()
                /// ToDO xxx
                var imagelooksFine : Bool?
                let uniqueImageName = UUID().uuidString
                //haziq
                if let jpegData = datax {
                 
                    Task {
                        do {
                            let data = try await Request.shared.uploadData(AdvanceDetectModel.self, method: .post, imageData: jpegData, url: "https://addon.faceki.com/advance/detect", imageName: "image")
                            stopActivityIndicator()
                            
                            imagelooksFine = data.liveness?.actual
#warning("Change this line (imagelooksFine ?? true) to this (imagelooksFine ?? false) after Development.")
                            if  (imagelooksFine ?? false) {
                                
                                if self.model?.data?.allowSingle ?? false {
                                    
                                    if isCardSelected ?? false {
                                        if idCardFrontImg == nil {
                                            idCardFrontImg = image
                                            scanBackIDCard()
                                            self.unhideQualityCheckViewWithAnimation(view : qualityCheckErrorView)
                                            self.hideQualityCheckViewWithAnimation(view : qualityCheckErrorView, deadline: .now() + 6)
                                            
                                        } else if idCardBackImg == nil {
                                            idCardBackImg = image
                                            self.moveToSelfieVc()
                                        }
                                        
                                    } else if isPassportSelected ?? false {
                                        passportFrontImg = image
                                        self.moveToSelfieVc()
                                        
                                    } else if isDrivingLicenseSelected ?? false {
                                        
                                        if drivingLicenseFrontImg == nil {
                                            drivingLicenseFrontImg = image
                                            scanBackDL()
                                            self.unhideQualityCheckViewWithAnimation(view : qualityCheckErrorView)
                                            self.hideQualityCheckViewWithAnimation(view : qualityCheckErrorView, deadline: .now() + 6)
                                            
                                        }else if drivingLicenseBackImg == nil {
                                            drivingLicenseBackImg = image
                                            self.moveToSelfieVc()
                                        }
                                    }
                                    
                                } else {
                                    if isTypeAllowed(type: .idCard) && (idCardFrontImg == nil || idCardBackImg == nil) {
                                        if idCardFrontImg == nil {
                                            if imagelooksFine == true {
                                                idCardFrontImg = image
                                                scanBackIDCard()
                                            } else {
                                                scanBackIDCard()
                                            }
                                            self.unhideQualityCheckViewWithAnimation(view : qualityCheckErrorView)
                                            self.hideQualityCheckViewWithAnimation(view : qualityCheckErrorView, deadline: .now() + 6)
                                        } else if idCardBackImg == nil {
                                            if imagelooksFine == true {
                                                idCardBackImg = image
                                                if isTypeAllowed(type: .passport) {
                                                    scanFrontPassport()
                                                } else if isTypeAllowed(type: .drivingLicense) {
                                                    scanFrontDL()
                                                } else {
                                                    moveToSelfieVc()
                                                }
                                            } else {
                                                scanBackDL()
                                            }
                                            self.unhideQualityCheckViewWithAnimation(view : qualityCheckErrorView)
                                            self.hideQualityCheckViewWithAnimation(view : qualityCheckErrorView, deadline: .now() + 6)
                                        }
                                    }
                                   else if passportFrontImg == nil, isTypeAllowed(type: .passport) {
                                       passportFrontImg = image
                                       if imagelooksFine == true {
                                           if isTypeAllowed(type: .drivingLicense) {
                                               scanFrontDL()
                                           } else {
                                               moveToSelfieVc()
                                           }
                                       } else {
                                           scanFrontPassport()
                                       }
                                        self.unhideQualityCheckViewWithAnimation(view : qualityCheckErrorView)
                                        self.hideQualityCheckViewWithAnimation(view : qualityCheckErrorView, deadline: .now() + 6)
                                        
                                    }
                                   else if isTypeAllowed(type: .drivingLicense) && (drivingLicenseFrontImg == nil || drivingLicenseBackImg == nil) {
                                        if drivingLicenseFrontImg == nil {
                                            if imagelooksFine == true {
                                                drivingLicenseFrontImg = image
                                                scanBackDL()
                                            } else {
                                                scanFrontDL()
                                            }
                                            
                                            self.unhideQualityCheckViewWithAnimation(view : qualityCheckErrorView)
                                            self.hideQualityCheckViewWithAnimation(view : qualityCheckErrorView, deadline: .now() + 6)
                                        } else if drivingLicenseBackImg == nil {
                                            if imagelooksFine == true {
                                                drivingLicenseBackImg = image
                                                moveToSelfieVc()
                                            } else {
                                                scanBackDL()
                                            }
                                        }
                                    }
                                    else {
                                        moveToSelfieVc()
                                    }
                                    
                                        
                                }
                            } else {
                                if let errorMessage = data.message {
                                    errorTitle.text = "Please Try Again!"
                                    errorDescription.text = errorMessage
                                } else {
                                    errorTitle.text = "Please Try Again!"
                                    errorDescription.text = "Captured Image unable to pass Quality check!"
                                }
                                self.unhideQualityCheckViewWithAnimation(view : qualityCheckErrorView)
                                self.hideQualityCheckViewWithAnimation(view : qualityCheckErrorView)
                            }
                        } catch (let error) {
                            print(error)
                            stopActivityIndicator()
                        }
                    }
                }
            }
        }
    }
    
    func scanFrontIDCard() {
        self.configureScanLabel(label: "Scan the Front ID Card side")
        errorTitle.text = "👍 Looks Great! 🔥"
        errorDescription.text = "Now, Scan the Front ID Card side"
    }
    
    func scanBackIDCard() {
        self.configureScanLabel(label: "Scan the Back ID Card side")
        errorTitle.text = "👍 Looks Great! 🔥"
        errorDescription.text = "Now, Scan the Back ID Card side"
    }
    
    func scanFrontPassport() {
        self.configureScanLabel(label: "Scan the Front Passport side")
        errorTitle.text = "👍 Looks Great! 🔥"
        errorDescription.text = "Now, Scan the Front Passport side"
    }
    
    func scanFrontDL() {
        self.configureScanLabel(label: "Scan the Front Driving License side")
        errorTitle.text = "👍 Looks Great! 🔥"
        errorDescription.text = "Now, Scan the Front Driving License side"
    }
    func scanBackDL() {
        self.configureScanLabel(label: "Scan the Back Driving License side")
        errorTitle.text = "👍 Looks Great! 🔥"
        errorDescription.text = "Now, Scan the Back Driving License side"
    }
    
    func isTypeAllowed(type: DocumentType) -> Bool {
        return self.model?.data?.allowedKycDocuments?.contains(type.rawValue) == true
    }
    
    private func unhideQualityCheckViewWithAnimation(view : UIView) {
        view.alpha = 1.0
        view.isHidden = false
        UIView.animate(withDuration: 0.2) {
        }
    }
    
    private func hideQualityCheckViewWithAnimation(view : UIView, deadline : DispatchTime = .now() + 4) {
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            guard let _ = self else { return }
            UIView.animate(withDuration: 0.5, animations: {
                view.alpha = 0.0 // Fade out the view
            }) { _ in
                view.isHidden = true
            }
        }
    }
    
    private func moveToSelfieVc(){
        DispatchQueue.main.async {[weak self] in
            guard let self else { return}
            let vc = SelfieGuidlinesVC.selfieGuidlinesVc()
            
            vc.model = self.model
            vc.isCardSelected = self.isCardSelected
            vc.isPassportSelected = self.isPassportSelected
            vc.isDrivingLicenseSelected = self.isDrivingLicenseSelected
            
            if self.model?.data?.allowSingle ?? false {
                
                if isCardSelected ?? false {
                    vc.frontIdCardImage = self.idCardFrontImg
                    vc.backIdCardImage = self.idCardBackImg
                    
                } else if isPassportSelected ?? false {
                    vc.frontPassportImage = self.passportFrontImg
                    
                } else if isDrivingLicenseSelected ?? false {
                    vc.frontDrivingLicenseImage = self.drivingLicenseFrontImg
                    vc.backDrivingLicenseImage = self.drivingLicenseBackImg
                    
                }
                
            } else {
                vc.frontIdCardImage = self.idCardFrontImg
                vc.backIdCardImage = self.idCardBackImg
                vc.frontPassportImage = self.passportFrontImg
                vc.frontDrivingLicenseImage = self.drivingLicenseFrontImg
                vc.backDrivingLicenseImage = self.drivingLicenseBackImg
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func configureScanLabel(label : String) {
        DispatchQueue.main.async {[weak self] in
            guard let self else { return}
            self.scanTitle.text = label
        }
    }
    
    private func beginSession() {
        configureDevice()
        var err: NSError? = nil
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(deviceInput)
        } catch let error as NSError {
            err = error
        }
        
        if err != nil {
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        
        view.layer.addSublayer(previewLayer!)
        
        overLayView.frame = view.layer.bounds
        overLayView2.frame = view.layer.bounds
        safeAreaView.frame = view.layer.bounds
        
        view.addSubview(overLayView)
        view.addSubview(overLayView2)
        view.addSubview(safeAreaView)
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
}
