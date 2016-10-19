#
# Be sure to run `pod lib lint ROStorageBar.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
    spec.name         = 'RONetworking'
    spec.version      = '2.1.4'
    spec.license      = { :type => 'MIT' }
    spec.homepage     = 'https://gitlab.com/rascor-apps/RONetworking'
    spec.authors      = { 'Robin Oster' => 'robin.oster@rascor.com' }
    spec.summary      = 'Networking methods and JSON Mapping'
    spec.source       = { :git => 'https://gitlab.com/rascor-apps/RONetworking.git', :tag => "2.1.2" }
    spec.source_files = 'Source/**/*'
    spec.framework    = 'SystemConfiguration'
    spec.ios.deployment_target  = '9.0'
    spec.dependency 'Alamofire', '~> 4.0'
    spec.dependency 'SwiftyJSON', '~> 3.0.0'
end
