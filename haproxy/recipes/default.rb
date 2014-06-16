#
# Cookbook Name:: haproxy
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
package 'haproxy' do
  action :install
end

if platform?('debian','ubuntu')
  template '/etc/default/haproxy' do
    source 'haproxy-default.erb'
    owner 'root'
    group 'root'
    mode 0644
  end
end

include_recipe 'haproxy::service'

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

template '/etc/haproxy/haproxy.cfg' do
  source 'haproxy.cfg.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables({
    rails_pool_size: rails_pool_size
  })
  notifies :restart, "service[haproxy]"
end

service 'haproxy' do
  action [:enable, :start]
end
