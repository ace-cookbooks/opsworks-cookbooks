begin
  load_balancers = search(:node, 'role:lb')
  num_load_balancers = load_balancers.size > 0 ? load_balancers.size : 1
  rails_pool_size = node[:rails][:max_pool_size].to_i / num_load_balancers
  Chef::Log.info("num_load_balancers: #{num_load_balancers}")
  Chef::Log.info("rails_pool_size: #{rails_pool_size}")
rescue => e
  Chef::Log.warn("exception: #{e}")
end

# hardcode bypass
rails_pool_size = node[:rails][:max_pool_size]

include_recipe 'haproxy::service'

template "/etc/haproxy/haproxy.cfg" do
  cookbook "haproxy"
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    rails_pool_size: rails_pool_size
  })
  notifies :restart, "eye_service[haproxy]", :delayed
  not_if { node[:opsworks][:activity] == 'setup' }
end
