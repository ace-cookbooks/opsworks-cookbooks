module OpsWorks
  module RailsConfiguration
    def self.determine_database_adapter(app_name, app_config, app_root_path, options = {})
      options = {
        :consult_gemfile => true,
        :force => false
      }.update(options)
      if options[:force] || app_config[:database][:adapter].blank?
        Chef::Log.info("No database adapter specified for #{app_name}, guessing")
        adapter = ''

        if options[:consult_gemfile] and File.exists?("#{app_root_path}/Gemfile")
          show_mysql2 = Mixlib::ShellOut.new("#{app_config[:bundle_binary]} show mysql2", :env => app_config[:environment], :user => app_config[:user], :group => app_config[:group])
          show_mysql2.run_command
          adapter = if !show_mysql2.error?
            Chef::Log.info("Looks like #{app_name} uses mysql2 in its Gemfile")
            'mysql2'
          else
            Chef::Log.info("Gem mysql2 not found in the Gemfile of #{app_name}, defaulting to mysql")
            'mysql'
          end
        else # no Gemfile - guess adapter by Rails version
          adapter = if File.exists?("#{app_root_path}/config/application.rb")
            Chef::Log.info("Looks like #{app_name} is a Rails 3 application, defaulting to mysql2")
            'mysql2'
          else
            Chef::Log.info("No config/application.rb found, assuming #{app_name} is a Rails 2 application, defaulting to mysql")
            'mysql'
          end
        end

        adapter
      else
        app_config[:database][:adapter]
      end
    end
  end
end
