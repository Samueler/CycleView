Pod::Spec.new do |s|
    s.name             = 'CycleView'
    s.version          = '1.0.0'
    s.summary          = '自动轮播器 by Swift'
    s.homepage         = 'https://github.com/Samueler/CycleView.git'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Samueler' => 'samueler.chen@gmail.com' }
    s.source           = { :git => 'https://github.com/Samueler/CycleView.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '10.0'
    s.source_files = 'CycleView/Classes/**/*'
    
    s.resource_bundles = {
        'CycleView' => ['CycleView/Assets/*.png']
    }
    s.dependency 'Kingfisher', '6.2.1'
end
