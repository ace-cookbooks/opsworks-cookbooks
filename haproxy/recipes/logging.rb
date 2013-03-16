service 'rsyslog' do
  supports :restart => true, :status => true
  action :nothing
end

template "/etc/rsyslog.d/haproxy.conf" do
  cookbook "haproxy"
  source "rsyslog.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => 'rsyslog')
  variables({
    :log_to_files => node[:haproxy][:log_to_files]
  })
end
