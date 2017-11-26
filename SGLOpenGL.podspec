Pod::Spec.new do |s|
  s.name             = 'SGLOpenGL'
  s.version          = '3.1.0'
  s.summary          = 'SwiftGL OpenGL Library'
  s.description      = <<-DESC
The SwiftGL OpenGL library allows for easy acess of OpenGL API from Swfit on macOS.
                       DESC
  s.homepage         = 'https://github.com/SwiftGL/OpenGL'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AE9RB' => 'dturnbull@gmail.com' }
  s.source           = { :git => 'https://github.com/SwiftGL/OpenGL.git', :tag => s.version.to_s }
  s.osx.deployment_target = '10.11'
  s.osx.source_files     = 'Sources/SGLOpenGL/*.swift'
end
