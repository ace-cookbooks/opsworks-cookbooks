use_inline_resources

action :install do
  app_name = new_resource.app_name
  app_config = new_resource.app_config
  app_root_path = new_resource.app_root_path

  raise 'No Gemfile found!' unless File.exists?(File.join(app_root_path, 'Gemfile'))

  execute 'bundle install' do
    user app_config[:user]
    group app_config[:group]
    environment(app_config[:environment])
    cwd app_root_path
    command "#{app_config[:bundle_binary]} install --deployment --path #{app_config[:home]}/.bundler/#{app_name} --without=#{app_config[:ignore_bundler_groups].join(' ')} 2>&1"
  end

  binstubs = %w(rake)
  binstubs << 'unicorn' if node[:opsworks][:rails_stack][:name] == 'nginx_unicorn'

  app_path = Pathname.new(app_root_path)
  if (app_path + 'bin').directory?
    binstubs.each do |binstub|
      raise "Missing #{binstub} binstub" unless (app_path.join('bin', binstub)).exist?
    end
  else
    directory((app_path + 'bin').to_s) do
      owner app_config[:user]
      group app_config[:group]
      mode 00755
      action :create
    end

    execute 'bundle binstubs' do
      user app_config[:user]
      group app_config[:group]
      environment(app_config[:environment])
      cwd app_root_path
      command "#{app_config[:bundle_binary]} binstubs #{binstubs.join(' ')}"
    end
  end
end
