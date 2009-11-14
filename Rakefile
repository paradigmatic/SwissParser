begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'swissparser'

#task :default => 'test:run'
#task 'gem:release' => 'test:run'

Bones {
  name  'swissparser'
  authors  'paradigmatic'
  email  'paradigmatic@streum.org'
  url  'http://github.com/paradigmatic/SwissParser'
  version  Swiss::VERSION
  readme_file 'README.rdoc'
  history_file 'CHANGELOG.rdoc'
  ignore_file  '.gitignore'
  rdoc.exclude ["examples/data"]
}

# EOF
