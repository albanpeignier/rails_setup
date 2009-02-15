require 'fileutils'

%w{rails_setup rake_with_rails_setup}.each do |f|
  FileUtils.rm "#{File.dirname(__FILE__)}/../../../script/#{f}"
end


