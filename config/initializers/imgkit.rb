IMGKit.configure do |config|
   config.default_options = {
     height: Settings.crawler.height.to_i,
     quality: 80,
     encoding: 'UTF-8',
     disable_smart_width: true
     #binmode: true
   }
  config.default_format = :jpg
end