
# Gem::Specification for Passiverecord-0.2
# Originally generated by Echoe

Gem::Specification.new do |s|
  s.name = %q{passiverecord}
  s.version = "0.2"
  s.date = %q{2007-11-08}
  s.summary = %q{Pacifying overactive records}
  s.email = %q{jasper@ambethia.com}
  s.homepage = %q{http://code.itred.org/projects/passive-record}
  s.rubyforge_project = %q{paintitred}
  s.description = %q{Pacifying overactive records}
  s.has_rdoc = true
  s.authors = ["Jason L Perry"]
  s.files = ["CHANGELOG", "lib/passive_record/associations.rb", "lib/passive_record/base.rb", "lib/passive_record/schema.rb", "lib/passive_record.rb", "Manifest", "README", "test/fixtures/candraspouses.yml", "test/fixtures/continents.rb", "test/fixtures/fosses.rb", "test/fixtures/rhizocables.yml", "test/fixtures/sambocranks.yml", "test/fixtures/schema.rb", "test/test_associations.rb", "test/test_base.rb", "test/test_helper.rb", "passiverecord.gemspec"]
  s.test_files = ["test/test_associations.rb", "test/test_base.rb", "test/test_helper.rb"]
  s.add_dependency(%q<activerecord>, [">= 0", "= 2.3.16"])
end


# # Original Rakefile source (requires the Echoe gem):
# 
# require 'rubygems'
# require 'rake'
# 
# ENV['RUBY_FLAGS'] = "-I#{%w(lib ext bin test).join(File::PATH_SEPARATOR)}"
# 
# begin
#   require 'echoe'
# 
#   Echoe.new("passiverecord") do |p|
#     p.rubyforge_name  = 'paintitred'
#     p.author          = 'Jason L Perry'
#     p.email           = 'jasper@ambethia.com'
#     p.summary         = 'Pacifying overactive records'
#     p.url             = "http://code.itred.org/projects/passive-record"
#     p.dependencies    = ["activerecord >= 1.15.3"]
#   end
#   
# rescue LoadError => boom
#   desc "Run the test suite."
#   task :test do
#      system "ruby -Ilib:ext:bin:test -e 'require \"test/test_associations.rb\"; require \"test/test_base.rb\"'"
#   end
# 
#   task(:default) do
#     puts "You are missing a dependency required for meta-operations on this gem."
#     puts "#{boom.to_s.capitalize}."
#   
#     Rake::Task["test"].invoke 
#   end    
# end