actions :install
default_action :install

attribute :app_name, :kind_of => String, :name_attribute => true
attribute :app_config, :kind_of => Hash, :required => true
attribute :app_root_path, :kind_of => String, :required => true
