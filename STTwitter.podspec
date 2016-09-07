Pod::Spec.new do |s|
    s.name          =   "STTwitter"
    s.version       =   "0.0.1"
    s.summary       =   "A lightweight Objective-C wrapper for Twitter REST API 1.1"
    s.license       =   "BSD 3-Clause License"
    s.source        =   { :git => "https://github.com/govi/STTwitter.git", :tag => "0.0.1" }
    s.source_files  =   'STTWitter', 'STTWitter/**/*.{h,m}'
    s.frameworks    =   'Social', 'Accounts', 'Security'
    s.requires_arc  =   false
    s.homepage     = "https://github.com/nst/STTwitter/"
    s.authors      = 'Nicolas Seriot', 'Bavarious', 'Chris Ricca', 'Evan Roth', 'Frank Dowsett', 'James Howard', 'Matthew Tomlinson', 'Pawel Niewiadomski', 'Sven Weidauer', 'Thijs Alkemade', 'Victor Ng', 'b123400', 'daisy1754', 'forcha', 'germanSancho', 'ijaycho', 'passwordreset'
end