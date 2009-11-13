begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'swiss_parser'

#task :default => 'test:run'
#task 'gem:release' => 'test:run'

Bones {
  name  'swissparser'
  authors  'paradigmatic'
  email  'paradigmatic@streum.org'
  url  'http://github.com/paradigmatic/SwissParser'
  version  Swiss::VERSION
  ignore_file  '.gitignore'
  rdoc.exclude ["examples/data"]
}

# EOF
