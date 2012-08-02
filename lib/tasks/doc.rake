require 'yard'
require 'kramdown'

YARD::Rake::YardocTask.new(:yard) do |task|
  task.options = %w(--db #{PKG}/.yardoc --output-dir #{PKG}/doc)
end
task :yard => PKG
