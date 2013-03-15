include_recipe "haproxy::service"

template "/etc/haproxy/default.pem" do
  cookbook "haproxy"
  source "cert.pem.erb"
  owner "root"
  group "root"
  mode 0600
  notifies :reload, resources(:service => "haproxy")
  variables({
    :private_key => node[:haproxy][:ssl][:private_key],
    :certificate => node[:haproxy][:ssl][:certificate],
    :intermediate => node[:haproxy][:ssl][:intermediate]
  })
end
