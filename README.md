```markdown
# FACEKI-KYC-IOS-V2 SDK

## Overview

The FACEKI-KYC-IOS-V2 SDK is an iOS framework developed by Faceki, providing advanced eKYC (Electronic Know Your Customer) and Facial Recognition capabilities for iOS applications. This SDK enables seamless identity verification using document and selfie verification.

## Installation

### CocoaPods

To integrate FACEKI-KYC-IOS-V2 SDK into your Xcode project using CocoaPods, add the following lines to your `Podfile`:

```ruby
target 'YourProjectName' do
  pod 'FACEKI-KYC-IOS-V2', '~> 2.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Manual Installation

You can also manually integrate the FACEKI-KYC-IOS-V2 SDK into your project. Download the SDK from [GitHub releases](https://github.com/faceki/faceki-ios-sdk-revamp/releases) and follow the instructions provided in the documentation.

#### Permission

Add the following usage descriptions to your Info.plist 

```
<key>NSCameraUsageDescription</key>
<string>For taking photos for kyc</string>

```


## Usage

### Callbacks

Implement the following callbacks to handle the SDK responses:


Callback that will recieve the response back from the API for data level information https://kycdocv2.faceki.com/api-integration/verification-apis

```swift

func onComplete(data: [AnyHashable: Any]) {
    print("API Response")
    print(data["responseCode"])
    print(type(of: data))

    if let dataObject = data["data"] as? [AnyHashable: Any] {
        print(dataObject["requestId"]!)
    }
}

// Redirect After Result Screen

func onRedirectBack() {
    DispatchQueue.main.async {
        // Perform UI work here
        self.navigationController?.popToRootViewController(animated: true)
    }
}
```

### Initialization

```swift
import FACEKI_KYC_IOS_V2

class YourViewController: UIViewController {

    @IBAction func captureAction(_ sender: Any) {
        let smManagerVC = Logger.initiateSMSDK(
            setClientID: "yourClientId",
            setClientSecret: "yourClientSecret",
            setOnComplete: onComplete,
            redirectBack: onRedirectBack,
            selfieImageUrl: nil,
            cardGuideUrl: nil
        )
        navigationController?.pushViewController(smManagerVC, animated: true)
    }

    // ... (rest of your ViewController code)

}
```



## Requirements

- Swift 4.0
- iOS 12.0 and later

## License

FACEKI-KYC-IOS-V2 SDK is released under the [MIT License](LICENSE)