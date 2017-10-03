# Uncomment the next line to define a global platform for your project
#platform :ios, '9.3'

 target 'Bulldog Bucks' do
   # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
   use_frameworks!
   platform :ios, '9.3'
   pod "Kanna", :git => 'https://github.com/tid-kijyun/Kanna.git', :branch => 'feature/v4.0.0'
   pod 'Alamofire'
   pod "PromiseKit"
   pod 'KeychainAccess'
   pod 'DGElasticPullToRefresh'
   pod 'MBProgressHUD', '~> 1.0.0'
   # Pods for Bulldog Bucks

 end

target 'Bulldog Bucks - Watch' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  platform :watchos, '3.0'
  # Pods for Bulldog Buck Balance

end

target 'Bulldog Bucks - Watch Extension' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  platform :watchos, '3.0'
  pod "Kanna", :git => 'https://github.com/tid-kijyun/Kanna.git', :branch => 'feature/v4.0.0'
  pod 'Alamofire'
  pod "PromiseKit"
  pod 'KeychainAccess'
  # Pods for Bulldog Buck Balance Extension

end

target 'Bulldog Bucks - Widget' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  platform :ios, '9.3'
  pod "Kanna", :git => 'https://github.com/tid-kijyun/Kanna.git', :branch => 'feature/v4.0.0'
  pod 'Alamofire'
  pod "PromiseKit"
  pod 'KeychainAccess'
  # Pods for Bulldog Bucks - Widget

end

target 'Bulldog Bucks - Swipes Widget' do
	use_frameworks!
	platform :ios, '9.3'
	pod "Kanna", :git => 'https://github.com/tid-kijyun/Kanna.git', :branch => 'feature/v4.0.0'
	pod 'Alamofire'
	pod "PromiseKit"
	pod 'KeychainAccess'

end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		swift3_projects = ['DGElasticPullToRefresh']
		if swift3_projects.include? target.name
			target.build_configurations.each do |config|
				config.build_settings['SWIFT_VERSION'] = '3.2'
			end
		end
	end
end
