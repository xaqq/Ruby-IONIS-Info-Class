Gem::Specification.new do |s|
  s.name         = 'ionis'
  s.version      = '0.0.9'
  s.date         = '2012-04-05'
  s.summary      = "IONIS Epitech/Epita class set"
  s.description  = "A Ruby set of Classes to get informations about students in Ionis group"
  s.authors      = ["Thibault MEYER"]
  s.email        = 'meyer.thibault@hotmail.fr'
  s.files        = ["lib/ionis.rb", "lib/ionisauthentication.rb", "lib/ionisnetsoul.rb", "lib/ionisexceptions.rb", "README.rdoc"]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Net-scp", "--main", "README.rdoc"]
  s.homepage     = 'https://github.com/0xbaadf00d/Ruby-IONIS-Info-Class'
  s.add_dependency('net-ssh', '>= 2.3.0')
  s.add_dependency('net-scp', '>= 1.0.4')
  s.add_dependency('bcrypt-ruby', '>= 3.0.1')
end
