require "rspec/core/rake_task"
desc "Run unit tests"
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = "spec/**/test_*.rb"
  t.rspec_opts = ["--color"]
end
task :test => :rspec