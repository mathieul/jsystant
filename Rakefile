require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-c", "-f documentation", "-r ./spec/spec_helper.rb"]
  t.pattern    = "spec/jsystant/*_spec.rb"
end
