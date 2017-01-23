platform :ios, '8.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end

target 'MerryBlue' do
  use_frameworks!
  pod 'SwiftyJSON', :git =>'https://github.com/SwiftyJSON/SwiftyJSON.git'
  pod 'RxSwift',    '~> 3.0'
  pod 'RxCocoa',    '~> 3.0'

  pod 'SDWebImage'
  pod 'SlideMenuControllerSwift'
end

  # pod 'RxBlocking', '~> 3.0'
  # pod 'RxTests',    '~> 3.0'
