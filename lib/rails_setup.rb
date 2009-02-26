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
      install_database_gems
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

    def install_database_gems
      puts "check if database gems are needed ..."

      required_database_gems = []

      if missing_adapter = detect_missing_database_adapter
        case missing_adapter
        when 'postgresql'
          required_database_gems << "postgres"
        end
      end

      unless required_database_gems.empty?
        # rake hook to install system libraries for example
        %x(rake "gems:db:prerequisites" "ADAPTER_GEMS=#{required_database_gems.join(' ')}") 

        install_gems(required_database_gems) 
      end
    end

    def install_gems(gems)
      cmd = %w{gem install} + gems 
      cmd = %w{sudo} + cmd if use_sudo

      sh cmd.join(' ')
    end

    private 

    def detect_missing_database_adapter
      begin
        require File.join(File.dirname(__FILE__), %w{..} * 4,%w{config environment})
      rescue RuntimeError => e
         $1 if e.message =~ /Please install the (.*) adapter/
      end
    end

  end

end

