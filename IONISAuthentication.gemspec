Gem::Specification.new do |s|
  s.name         = 'ionisauthentication'
  s.version      = '0.0.4'
  s.date         = '2012-03-14'
  s.summary      = "IONIS Authentication"
  s.description  = "A Ruby Class to get informations about students in Ionis group"
  s.authors      = ["Thibault MEYER"]
  s.email        = 'meyer.thibault@hotmail.fr'
  s.files        = ["lib/ionisauthentication.rb", "lib/ionisexceptions.rb", "README.rdoc"]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Net-scp", "--main", "README.rdoc"]
  s.homepage     = 'https://github.com/corbeau-web/Ruby-IONIS-Info-Class'
  s.add_dependency('net-ssh', '>= 2.3.0')
  s.add_dependency('net-scp', '>= 1.0.4')
  s.add_dependency('bcrypt-ruby', '>= 3.0.1')
end
