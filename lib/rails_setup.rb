require 'rubygems'

module Kernel
  alias_method :orig_gem, :gem
  
  def gem(name, *version_requirements)
    unless 'rails' == name
      orig_gem(name, *version_requirements)
    else
      begin
        orig_gem('rails', *version_requirements)
      rescue Gem::LoadError
        RailsSetup.install_rails_gem(version_requirements.first)
        Gem::refresh
        orig_gem('rails', *version_requirements)
      end
    end
  end
end

require 'rake'

class RailsSetup
  class << self

  attr_accessor :use_sudo

  def run
    install_rails
    install_configured_gems
  end

  def install_rails(use_sudo = true)
    puts "check if rails gems are needed ..."
    # Kernel.gem is modified to install rails gem if needed :
    require File.join(File.dirname(__FILE__), %w{..} * 4,%w{config boot})
  end

  def install_rails_gem(version)
    cmd = %w{gem install rails}
    cmd << "--version" << version if version

    cmd = %w{sudo} + cmd if use_sudo

    puts "install rails #{version}" 
    sh cmd.join(' ')
  end

  def install_configured_gems
    gems_install_task = 'gems:install'
    gems_install_task << '_with_sudo' if use_sudo

    puts "check if configured gems are needed ..."
    sh "rake #{gems_install_task}"
  end

  end

end

