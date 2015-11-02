Gem::Specification.new do |s|
  s.name        = 'netuitived'
  s.version     = '0.9.1'
  s.date        = '2015-11-02'
  s.summary     = "Metric collection druby server"
  s.description = "Collects metrics over a certain interval and then sends them to Netuitive"
  s.authors     = ["John King"]
  s.email       = 'jking@netuitive.com'
  files = Dir['lib/**/*.{rb}'] + Dir['lib/*.{rb}'] + Dir['config/*.{yml}'] + Dir['./LICENSE']
  s.files       = files
  s.homepage    =
    'http://rubygems.org/gems/netuitived'
  s.license       = 'Apache v2.0'
end
