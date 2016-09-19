Pod::Spec.new do |spec|
    spec.name           = 'NovaProgress'
    spec.version        = '0.0.1'
    spec.license        = { :type => 'MIT' }
    spec.homepage       = 'https://github.com/netizen01/NovaProgress'
    spec.authors        = { 'Netizen01' => 'n01@invco.de' }
    spec.summary        = 'Library of Custom UIViews'
    spec.source         = { :git => 'https://github.com/netizen01/NovaProgress.git',
                            :tag => spec.version.to_s }
    spec.source_files   = 'Source/**/*.swift'

    spec.ios.deployment_target  = '8.2'
end
