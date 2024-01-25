//
//  OnBoardingViewController.swift
//  ScanDocument
//
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    //MARK: -Outlets
    @IBOutlet weak var lottieAnimationView : UIView!
    @IBOutlet weak var facekiLogo : UIImageView!

    //MARK: -Properties
    var viewModel = OnBoardingViewModel()
    
    //MARK: -lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   overrideUserInterfaceStyle = .light
               }
        
        if let url = URL(string: "https://facekiassets.faceki.com/public/powerbyFaceki.png") {
                  downloadImage(from: url)
              }
    }
    
    override func viewWillAppear(_ animated: Bool){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadAnimation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getTokenApiCall()
    }
    
    //MARK: -Methods
    private func presetHomeVC(){
        DispatchQueue.main.async {
            let vc = ViewController.viewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func loadAnimation(){
        let animationView = LottieAnimationView(name: "lottieFirstLoading.json", bundle: frameworkImageBundle)
        animationView.frame = lottieAnimationView.bounds
        lottieAnimationView.addSubview(animationView)
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.play()
    }
    
    private func getTokenApiCall(){
        Task {
            do{
    
                let result = try await viewModel.getToken(clientIdVal:Faceki_clientId ,clientSecretVal: Faceki_clientSecret)
                if let token = result.data?.accessToken {
                    Defaults.shared.setToken(token: token)
                }
                self.presetHomeVC()
            } catch (let error) {
                print(error)
                Utility.showAlertWithOk(title: "Error", message: "An error Occurred, try again later.")
            }
        }
    }
    
    func downloadImage(from url: URL) {
          URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                  // Ensure that the downloaded data is a valid image
                  if let image = UIImage(data: data) {
                      // Update the UI on the main thread
                      DispatchQueue.main.async {
                          self.facekiLogo.image = image
                      }
                  }
              }
          }.resume()
      }
}
