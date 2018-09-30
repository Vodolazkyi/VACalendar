Pod::Spec.new do |s|
  s.name             = 'VACalendar'
  s.version          = '1.3'
  s.summary          = 'Custom Calendar for iOS in Swift'
  s.swift_version    = '4.2'

  s.description      = <<-DESC
VACalendar helps create customizable calendar for your app. It also supports vertical and horizontal scroll directions!
                       DESC

  s.homepage         = 'https://github.com/Vodolazkyi/VACalendar'
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { 'Anton Vodolazkyi' => 'vodolazky@me.com' }
  s.platform         = :ios, '10.0'
  s.source           = { :git => 'https://github.com/Vodolazkyi/VACalendar.git', :tag => s.version.to_s }
  s.source_files     = 'VACalendar/*.swift'

end