unless defined?(Spring)
  require 'rubygems'
  require 'bundler'

  lockfile = Bundler::LockfileParser.new(Bundler.default_lockfile.read)
  if spring = lockfile.specs.detect { |spec| spec.name == "spring" }
    Gem.use_paths Gem.dir, Bundler.bundle_path.to_s, *Gem.path
    gem 'spring', spring.version
    require 'spring/binstub'
  end
end
