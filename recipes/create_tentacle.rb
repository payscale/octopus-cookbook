#
# Cookbook Name:: octopus
# Recipe:: register_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

# register the tentacle with octopus server
powershell_script "register_tentacle" do
	code <<-EOH
	Set-Alias tentacle "#{node['octopus']['tentacle']['install_dir']}\\Tentacle.exe"
	tentacle create-instance --instance "#{node['octopus']['tentacle']['name']}" --config "#{node['octopus']['tentacle']['home']}\\Tentacle\\Tentacle.config" --console
	tentacle new-certificate --instance "#{node['octopus']['tentacle']['name']}" --console
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --home "#{node['octopus']['tentacle']['home']}\\" --console
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --app "#{node['octopus']['tentacle']['home']}\\Applications" --console
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --port "#{node['octopus']['tentacle']['port']}" --console
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --trust "#{node['octopus']['server']['thumbprint']}" --console
	tentacle service --instance "#{node['octopus']['tentacle']['name']}" --install --start --console
	EOH
	not_if {::File.exists?("#{node['octopus']['tentacle']['home']}\\Tentacle\\Tentacle.config")}
end
