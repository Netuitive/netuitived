Gem::Specification.new do |s|
  s.name        = 'netuitived'
  s.version     = '0.9.12'
  s.date        = '2015-12-30'
  s.summary     = "Metric collection druby server"
  s.description = "Collects metrics over a certain interval and then sends them to Netuitive"
  s.authors     = ["John King"]
  s.email       = 'jking@netuitive.com'
  files = Dir['lib/**/*.{rb}'] + Dir['lib/*.{rb}'] + Dir['config/*.{yml}'] + Dir['./LICENSE'] + Dir['log/*'] + Dir['./README.md']
  s.files       = files
  s.homepage    =
    'http://rubygems.org/gems/netuitived' 
  s.license       = 'Apache v2.0'
  s.required_ruby_version = '>= 1.9.0'
  s.executables << 'netuitived'
end
