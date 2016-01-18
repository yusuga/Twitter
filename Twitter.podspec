Pod::Spec.new do |s|
  s.name = 'Twitter'
  s.version = '0.3.1'
  s.summary = 'Twitter API1.1 Client.'
  s.homepage = 'https://github.com/yusuga/Twitter'
  s.license = 'MIT'
  s.author = 'Yu Sugawara'
  s.source = { :git => 'https://github.com/yusuga/Twitter.git', :tag => s.version.to_s }
  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source_files = 'Classes/Twitter/**/*.{h,m}'
  s.resources    = 'Classes/Twitter/**/*.lproj'
  s.requires_arc = true
  s.compiler_flags = '-fmodules'
  
  s.dependency 'AFNetworking', '~> 2.0'
  s.dependency 'OAuthCore', '~> 0.0.1'
end