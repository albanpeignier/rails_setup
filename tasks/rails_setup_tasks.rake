namespace :gems do

  task :use_sudo do
    class Rails::GemDependency
      # use sudo to install 
      def gem_command; 'sudo gem'; end
    end
  end

  desc "Installs with sudo all required gems for this rails application"
  task :install_with_sudo => [ 'use_sudo', 'gems:install']

end
