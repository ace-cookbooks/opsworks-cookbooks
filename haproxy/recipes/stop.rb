include_recipe "haproxy::service"

ruby_block 'stop haproxy' do
  block do
    true
  end
  notifies :safe_stop, 'eye_service[haproxy]', :immediately
end
