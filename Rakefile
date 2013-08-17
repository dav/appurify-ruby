require "bundler"
require 'rspec/core/rake_task'

Bundler.setup
RSpec::Core::RakeTask.new('spec')

gemspec = eval(File.read("appurify.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["appurify.gemspec"] do
  system "gem build appurify.gemspec"
end

desc "deploy the gem and tag the version"
task :deploy do
  `gem build appurify.gemspec`
  `git tag v#{Appurify::VERSION}` if $?.exitstatus == 0
  `git push origin v#{Appurify::VERSION}` if $?.exitstatus == 0
  `curl -F p1=@appurify-#{Appurify::VERSION}.gem https://gems.gemfury.com/P6HxhuAq3NRTM1wqCxJS/` if $?.exitstatus == 0
  `rm *.gem`
end