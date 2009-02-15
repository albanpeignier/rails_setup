require 'fileutils'

%w{rails_setup rake_with_rails_setup}.each do |f|
  puts "  create script/#{f}"
  FileUtils.install "#{File.dirname(__FILE__)}/script/#{f}", "#{File.dirname(__FILE__)}/../../../script", :mode => 0755
end


