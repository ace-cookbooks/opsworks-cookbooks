if node[:haproxy][:errorfile]
  node[:haproxy][:errorfile].each do |code, location|
    remote_file "/etc/haproxy/#{code}.http" do
      source location
    end
  end
end
