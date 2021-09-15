# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GBFramework' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GBFramework
  pod 'GoogleMaps'
  pod 'RxSwift', '6.2.0'
  pod 'RxCocoa', '6.2.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
    end
  end
end

