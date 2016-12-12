platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!

target 'Accent' do
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Digits'
  pod 'TwitterCore'

  pod 'MGSwipeTableCell', '~> 1.5'
  pod 'RealmSwift', '~> 2.1'
  pod 'SwiftyJSON', '~> 3.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.0'
      end
  end
end
