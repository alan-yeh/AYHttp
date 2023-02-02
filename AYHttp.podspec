#
# Be sure to run 'pod lib lint AYHttp.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AYHttp'
  s.version          = '2.1.0'
  s.summary          = 'Promise style HTTP client base on AFNetworking.'

  s.homepage         = 'https://github.com/alan-yeh/AYHttp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alan Yeh' => 'alan@yerl.cn' }
  s.source           = { :git => 'https://github.com/alan-yeh/AYHttp.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'AYHttp/Classes/**/*'
  s.public_header_files = 'AYHttp/Classes/*.h'
  
  s.dependency 'AFNetworking/Reachability', "~> 3.0"
  s.dependency 'AFNetworking/Serialization', "~> 3.0"
  s.dependency 'AFNetworking/Security', "~> 3.0"
  s.dependency 'AFNetworking/NSURLSession', "~> 3.0"
  s.dependency 'AYPromise'
  s.dependency 'AYFile'
  s.dependency 'AYQuery'
  s.dependency 'AYCategory'
end
