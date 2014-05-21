lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mget/version'

Gem::Specification.new do |spec|
    spec.name       = "mget"
    spec.version    = MangeGet::VEERSION
    spec.platform   = Gem::Platform::RUBY
    
    spec.author     = ["Ross Bayer"]
    spec.email      = ["rostepher.dev@gmail.com"]
    spec.homepage   = "http://github.com/Rostepher/mget"
    spec.summary    = "A simple ruby script to download and package manga into" +
                      "cbz archives from multiple sources"
    
    spec.files      = Dir.glob("../lib/**/*.rb") + %w(README.md)
end
