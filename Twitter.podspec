Pod::Spec.new do |s|
  s.name = 'Twitter'
  s.version = '0.0.5'
  s.summary = 'Twitter API1.1 Client.'
  s.homepage = 'https://github.com/yusuga/Twitter'
  s.license = 'MIT'
  s.author = 'Yu Sugawara'
  s.source = { :git => 'https://github.com/yusuga/Twitter.git', :tag => s.version.to_s }
  s.platform = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source_files = 'Classes/Twitter/*.{h,m}'
  s.resources    = 'Classes/Twitter/Localization/*.lproj'
  s.requires_arc = true
  s.compiler_flags = '-fmodules'
  
  s.dependency 'AFNetworking'
  s.dependency 'OAuthCore'
  
  s.subspec 'Constants' do |ss|
    ss.source_files = 'Classes/Twitter/Constants/*.{h,m}'
  end
  
  s.subspec 'Localization' do |ss|
    ss.source_files = 'Classes/Twitter/Localization/*.{h,m}'
  end
  
  s.subspec 'Category' do |ss|
    ss.dependency 'Twitter/Localization'
    ss.source_files = 'Classes/Twitter/Category/*.{h,m}'
  end
  
  s.subspec 'Parser' do |ss|
    ss.source_files = 'Classes/Twitter/Parser/*.{h,m}'
  end
  
  s.subspec 'Operation' do |ss|
    ss.dependency 'Twitter/Parser'
    ss.source_files = 'Classes/Twitter/Operation/*.{h,m}'
  end
  
  s.subspec 'Model' do |ss|
    ss.dependency 'Twitter/Category'
    ss.source_files = 'Classes/Twitter/Model/*.{h,m}'
  end
  
  s.subspec 'Serialization' do |ss|
    ss.dependency 'Twitter/Model'
    ss.dependency 'Twitter/Constants'
    ss.source_files = 'Classes/Twitter/Serialization/*.{h,m}'
  end
  
  s.subspec 'Authentication' do |ss|
    ss.dependency 'Twitter/Operation'
    ss.dependency 'Twitter/Serialization'
    ss.source_files = 'Classes/Twitter/Authentication/*.{h,m}'
  end
  
  s.subspec 'API' do |ss|
    ss.dependency 'Twitter/Authentication'
    ss.source_files = 'Classes/Twitter/API/*.{h,m}'
  end
end