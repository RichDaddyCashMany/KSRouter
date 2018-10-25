Pod::Spec.new do |s|
  s.name         = "KSRouter"
  s.version      = "0.0.1"
  s.summary      = "支持自动注册的的iOS组件化解决方案"
  s.homepage     = "https://github.com/HJaycee/KSRouter"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "HJaycee" => "huangxisu@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/HJaycee/KSRouter.git", :tag => s.version }
  s.source_files  = "KSRouter/KSRouter/*.{h,m}"
  s.requires_arc = true
end
