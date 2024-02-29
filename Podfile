# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'ListView' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
	pod 'SnapKit'
  pod 'HandyJSON'
  pod 'RxCocoa'
#  pod 'RATreeView'
  # Pods for ListView

end

post_install do |installer|
# 解决xcode 15 报错 xcode SDK does not contain ‘libarclite‘
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

