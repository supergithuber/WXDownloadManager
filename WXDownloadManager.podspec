Pod::Spec.new do |s|
  s.name         = "WXDownloadManager"
  s.version      = "0.5.0"
  s.summary      = "A short description of WXDownloadManager."
  s.description  = <<-DESC
                      a downloadmanager written in objective-C
                   DESC

  s.homepage     = "http://EXAMPLE/WXDownloadManager"
  s.license      = "MIT"
  s.platform     = :ios
  s.author             = { "sivanWu" => "1984430988@qq.com" }
  s.source       = { :git => "https://github.com/supergithuber/WXDownloadManager.git", :tag => "0.5.0" }
  s.source_files  = "WXDownloadManager/DownManager/*.{h,m}"
  s.requires_arc = true
end
