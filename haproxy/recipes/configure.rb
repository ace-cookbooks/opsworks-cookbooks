service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action :nothing # only define so that it can be restarted if the config changed
end

begin
  load_balancers = search(:node, 'role:haproxy')
  num_load_balancers = load_balancers.size > 0 ? load_balancers.size : 1
  Chef::Log.info("load_balancers: #{load_balancers}")
  Chef::Log.info("num_load_balancers: #{num_load_balancers}")
  Chef::Log.info("rails_pool_size: #{node[:rails][:max_pool_size].to_i / num_load_balancers}")
  load_balancers = node[:opsworks][:layers][:haproxy][:instances]
  Chef::Log.info("load_balancers_2: #{load_balancers}")
  Chef::Log.info("load_balancers_2 size: #{load_balancers.size}")
rescue => e
  Chef::Log.warn("exception: #{e}")
end

template "/etc/haproxy/haproxy.cfg" do
  cookbook "haproxy"
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    rails_pool_size: node[:rails][:max_pool_size]
  })
  notifies :reload, "service[haproxy]"
end

execute "echo 'checking if HAProxy is not running - if so start it'" do
  not_if "pgrep haproxy"
  notifies :start, "service[haproxy]"
end

