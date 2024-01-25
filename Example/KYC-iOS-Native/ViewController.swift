//
//  ViewController.swift
//  KYC-iOS-Native
//
//  Created by faceki on 01/04/2022.
//  Copyright (c) 2022 faceki. All rights reserved.
//

import UIKit
import FACEKI_KYC_IOS_V2

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func onComplete(data:[AnyHashable:Any]){
        print("API Response")
        print( data["responseCode"])
        print(type(of: data))

        if let dataObject = data["data"] as? [AnyHashable: Any]{
            print(dataObject["requestId"]!)
        }
     
    }
    func onRedirectBack(){
        DispatchQueue.main.async {
           // UI work here
            self.navigationController?.popToRootViewController(animated: true)

        }

        
    }
    @IBAction func captueACtion(_ sender: Any) {
        
        // Example Usage for FACEKI SDK
        
        let smManagerVC = Logger.initiateSMSDK(setClientID : "clientid", setClientSecret: "clientSecret", setOnComplete:onComplete,redirectBack: onRedirectBack,selfieImageUrl: nil,cardGuideUrl: nil)
        navigationController?.pushViewController(smManagerVC, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

