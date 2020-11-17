
target 'DriveFast' do
  use_frameworks!

  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/AdMob'
  pod 'Firebase/Crashlytics'
  pod 'GoogleUserMessagingPlatform'
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
end

