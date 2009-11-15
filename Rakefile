begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'swissparser'

require 'cucumber/rake/task'

task :default => :features

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty"
  t.rcov = true
end

CLOBBER << "coverage/"

Bones {
  name  'swissparser'
  authors  'paradigmatic'
  email  'paradigmatic@streum.org'
  url  'http://github.com/paradigmatic/SwissParser'
  version  Swiss::VERSION
  gem.development_dependencies = [["cucumber", ">= 0.4"]]
  readme_file 'README.rdoc'
  history_file 'CHANGELOG.rdoc'
  ignore_file  '.gitignore'
  rdoc.exclude ["examples/","features/"]
}

# EOF
