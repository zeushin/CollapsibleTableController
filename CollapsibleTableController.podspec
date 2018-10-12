#
# Be sure to run `pod lib lint CollapsibleTableController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CollapsibleTableController'
  s.version          = '0.1.1'
  s.summary          = 'Collapsible table view controller.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'The table controller that is enable to collapses and expands table rows when tapping table section header.'

  s.homepage         = 'https://github.com/zeushin/CollapsibleTableController'
  s.screenshots     = 'https://github.com/zeushin/CollapsibleTableController/blob/master/CollapsibleTableController.gif?raw=true'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Masher' => 'zeushin@gmail.com' }
  s.source           = { :git => 'https://github.com/zeushin/CollapsibleTableController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/masher_s'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'CollapsibleTableController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CollapsibleTableController' => ['CollapsibleTableController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
