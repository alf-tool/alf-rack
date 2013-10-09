require "rspec/core/rake_task"
desc "Run all examples"
RSpec::Core::RakeTask.new(:examples) do |t|
  t.pattern = "examples/*.rb"
  t.rspec_opts = ["--color"]
end
task :test => [:rspec, :examples]
