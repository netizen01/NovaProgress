Pod::Spec.new do |spec|

    spec.name                   = 'NovaProgress'
    spec.version                = '0.6'
    spec.summary                = 'Another Progress Overlay. Because.'

    spec.homepage               = 'https://github.com/netizen01/NovaProgress'
    spec.license                = { :type => 'MIT', :file => 'LICENSE' }
    spec.author                 = { 'Netizen01' => 'n01@invco.de' }

    spec.ios.deployment_target  = '9.3'

    spec.source                 = { :git => 'https://github.com/netizen01/NovaProgress.git',
                                    :tag => spec.version.to_s }
    spec.source_files           = 'Source/**/*.swift'
    spec.swift_version          = '4.2'

end
