//
//  SelfieVC.swift
//  ScanDocument
//
//

import UIKit
import AVFoundation
import AudioToolbox

class SelfieVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    //MARK: -Instance Method
    class func selfieVc() -> SelfieVC {
        return UIStoryboard(name: "MainFACEKI", bundle: frameworkImageBundle).instantiateViewController(withIdentifier: "SelfieVC") as! SelfieVC
    }
    
    //MARK: -Outlets
    @IBOutlet weak var overLayView: UIView!
    @IBOutlet weak var overLayView2: UIView!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var safeAreaView : UIView!
    @IBOutlet weak var overlayImage : UIImageView!
    
    
    
    // MARK: - Properties
    var idCardFrontImg : UIImage?
    var idCardBackImg : UIImage?
    var passportFrontImg : UIImage?
    var drivingLicenseFrontImg : UIImage?
    var drivingLicenseBackImg : UIImage?
    
    var model : DocumentCopyRulesModel?
    var imagesData : [(imageName: String, imageData: Data)]?
    var isCardSelected : Bool?
    var isPassportSelected : Bool?
    var isDrivingLicenseSelected : Bool?
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    //MARK: -lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        self.configureCam()
        navigationController?.navigationBar.isHidden = true
        
    }
    
    //MARK: -Actions
    @IBAction private func didTapBack(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        stopActivityIndicator()
        if let imageData = photo.fileDataRepresentation() {
            if let capturedImage = UIImage(data: imageData) {
                
                /// ToDO
                if let selfieImgData = capturedImage.convertImageToJPEGData() {
                    
                    if (self.model?.data?.allowSingle ?? false) {
                        var docFrontData : Data?
                        var docBackData : Data?
                        
                        if self.isCardSelected ?? false,
                            let idCardFrontImgData = self.idCardFrontImg?.convertImageToJPEGData(),
                            let idCardBackImgData = self.idCardBackImg?.convertImageToJPEGData() {
                            docFrontData = idCardFrontImgData
                            docBackData = idCardBackImgData
                        } else if self.isPassportSelected ?? false,
                                  let passportFrontImgData = self.passportFrontImg?.convertImageToJPEGData() {
                            docFrontData = passportFrontImgData
                            docBackData = passportFrontImgData
                        } else if self.isDrivingLicenseSelected ?? false,
                                  let drivingLicenseFrontImgData = self.drivingLicenseFrontImg?.convertImageToJPEGData(),
                                  let drivingLicenseBackImgData = self.drivingLicenseBackImg?.convertImageToJPEGData() {
                            docFrontData = drivingLicenseFrontImgData
                            docBackData = drivingLicenseBackImgData
                        }
                        guard let docBackData,
                              let docFrontData else {return}
                        self.imagesData = [
                            (imageName: "selfie_image", imageData: selfieImgData),
                            (imageName: "doc_front_image", imageData: docFrontData),
                            (imageName: "doc_back_image", imageData: docBackData)
                        ]
                        
                    } else {
                        if let selfieImgData = capturedImage.convertImageToJPEGData() {
                            self.imagesData = [(imageName: "selfie_image", imageData: selfieImgData)]
                            if self.isTypeAllowed(type: .idCard),
                               let idCardFrontImgData = self.idCardFrontImg?.convertImageToJPEGData(),
                               let idCardBackImgData = self.idCardBackImg?.convertImageToJPEGData() {
                                self.imagesData?.append(contentsOf: [(imageName: "id_front_image", imageData: idCardFrontImgData),
                                                                     (imageName: "id_back_image", imageData: idCardBackImgData)])
                            }
                            if self.isTypeAllowed(type: .passport),
                               let passportFrontImgData = self.passportFrontImg?.convertImageToJPEGData() {
                                self.imagesData?.append(contentsOf: [(imageName: "pp_front_image", imageData: passportFrontImgData),
                                                                     (imageName: "pp_back_image", imageData: passportFrontImgData)])
                            }
                            if self.isTypeAllowed(type: .drivingLicense),
                               let drivingLicenseFrontImgData = self.drivingLicenseFrontImg?.convertImageToJPEGData(),
                               let drivingLicenseBackImgData = self.drivingLicenseBackImg?.convertImageToJPEGData(){
                                self.imagesData?.append(contentsOf: [(imageName: "dl_front_image", imageData: drivingLicenseFrontImgData),
                                                                     (imageName: "dl_back_image", imageData: drivingLicenseBackImgData)])
                            }
                        }
                    }
                }
                
                let vc = ResultVC.resultVc()
                vc.imagesData = self.imagesData
                vc.model = self.model
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }
    
    func isTypeAllowed(type: DocumentType) -> Bool {
            return self.model?.data?.allowedKycDocuments?.contains(type.rawValue) == true
        }
    
    private func configureDevice() {
        let _: NSErrorPointer = nil
        if let device = captureDevice {
            do {
                try captureDevice!.lockForConfiguration()
                
            } catch _ as NSError {
            }
            
            device.unlockForConfiguration()
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
        overlayImage.frame = view.layer.bounds
        
        view.addSubview(overlayImage)
        view.addSubview(overLayView)
        view.addSubview(overLayView2)
        view.addSubview(safeAreaView)

        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
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
    
    private func configureCam() {
        capturePhotoOutput = AVCapturePhotoOutput()
        
        if let capturePhotoOutput = capturePhotoOutput {
            if captureSession.canAddOutput(capturePhotoOutput) {
                captureSession.addOutput(capturePhotoOutput)
            }
        }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo  // Updated for iOS 15
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        let devices = discoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.front {
                captureDevice = device
                if captureDevice != nil {
                    print("Capture device found")
                    beginSession()
                }
            }
        }
    }
    
}

extension UIImage {
    func convertImageToJPEGData() -> Data? {
        return self.jpegData(compressionQuality: 0.8)
    }
}
