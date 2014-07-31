
Gem::Specification.new do |s|
  s.name         = 'pry-ib'
  s.version      = '0.1.0.pre'  #File.read('VERSION')
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = 'A CLI for trading with Interative Brokers'
  s.description  = 'This pry plugin provides a CLI to interact with the Interactive Brokers TWS API with the ib-ruby gem'
  s.authors      = ['David Kinsfather']
  s.email        = ['david.kinsfather@gmail.com']
#  s.homepage     = 'https://github.com/davek42/pry-ib'
#  s.licenses     = 'MIt'

  s.platform     = Gem::Platform::RUBY
  s.require_paths= ['lib']
  s.files        = `git ls-files`.split("\n")

  s.add_runtime_dependency 'ib-ruby', '~> 0.9.2'

  s.add_development_dependency 'bacon'  # rspec subsitute
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
end