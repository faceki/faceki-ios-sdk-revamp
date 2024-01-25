#
# Be sure to run `pod lib lint KYC-iOS-Native.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FACEKI-KYC-IOS-V2'
  s.version          = '2.0.0'
  s.summary          = 'iOS SDK For FACEKI EKYC'
  s.description      = "Faceki eKYC & Facial Recognition system, iOS SDK for verifying the user with their document and selfie"
  s.homepage         = 'https://github.com/faceki/faceki-ios-sdk-revamp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'faceki' => 'tech@faceki.com' }
  s.source           = { :git => 'https://github.com/faceki/faceki-ios-sdk-revamp.git', :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.ios.deployment_target = '13.0'
  s.source_files = 'KYC-iOS-Native/Classes/**/*'
  s.resources = 'KYC-iOS-Native/Assets/**'
  s.frameworks = 'UIKit', 'AVFoundation'
  s.dependency 'lottie-ios'
  
  
end
