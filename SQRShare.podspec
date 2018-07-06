Pod::Spec.new do |s|

  s.name         = "SQRShare"
  s.version      = "0.1.9"
  s.summary  	 = '自定义分享'
  s.homepage     = "https://github.com/pengruiCode/SQRShare.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = {'pengrui' => 'pengruiCode@163.com'}
  s.source       = { :git => 'https://github.com/pengruiCode/SQRShare.git', :tag => s.version}
  s.platform 	 = :ios, "8.0"
  s.source_files = "SQRShare/**/*.{h,m}"
  s.resource     = 'SQRShare/Resource/*.{png,bundle}'
  s.vendored_frameworks = 'SQRShare/Frameworks/*.framework'
  s.requires_arc = true
  s.description  = <<-DESC
			自定义分享，基于sharesdk
                   DESC

  s.subspec "SQRBaseDefineWithFunction" do |ss|
     ss.dependency "SQRBaseDefineWithFunction"
  end

  s.subspec "WechatOpenSDK" do |ss|
     ss.dependency "WechatOpenSDK"
  end

 end