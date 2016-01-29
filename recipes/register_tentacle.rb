#
# Cookbook Name:: octopus
# Recipe:: register_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

#  land cert file
cookbook_file "C:\\chef\\cache\\tentacle-cert" do
	source "tentacle-cert"
	action :create
end

# register the tentacle with octopus server
powershell_script "register_tentacle" do
	code <<-EOH
	Set-Alias tentacle "#{node['octopus']['tentacle']['install_dir']}\\Tentacle.exe"
	tentacle create-instance --instance "#{node['octopus']['tentacle']['name']}" --config "#{node['octopus']['tentacle']['home']}\\Tentacle\\Tentacle.config" --console
	if ($? -ne 1) {
		throw "tentacle create failed"
	}
	Start-Sleep -s 10
	$certImport = tentacle import-certificate --instance "#{node['octopus']['tentacle']['name']}" -f C:\\chef\\cache\\tentacle-cert --console 2>&1
	if ($? -ne 1) {
		throw "cert import failed: $certImport"
	}
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --home "#{node['octopus']['tentacle']['home']}\\" --console
	if ($? -ne 1) {
		throw "home config failed"
	}
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --app "#{node['octopus']['tentacle']['home']}\\Applications" --console
	if ($? -ne 1) {
		throw "app config failed"
	}
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --port "#{node['octopus']['tentacle']['port']}" --console
	if ($? -ne 1) {
		throw "port config failed"
	}
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --trust "#{node['octopus']['server']['thumbprint']}" --console
	if ($? -ne 1) {
		throw "trust config failed"
	}
	tentacle register-with --instance "#{node['octopus']['tentacle']['name']}" --name="#{node['octopus']['tentacle']['name']}" --publicHostName=#{node['ipaddress']} --server=#{node['octopus']['api']['uri']} --apiKey=#{node['octopus']['api']['key']} --role=#{node['octopus']['tentacle']['role']} --environment=#{node['octopus']['tentacle']['environment']} --comms-style TentaclePassive --console
	if ($? -ne 1) {
		throw "register with command failed"
	}
	tentacle service --instance "#{node['octopus']['tentacle']['name']}" --install --start --console
	if ($? -ne 1) {
		throw "tentacle start command failed"
	}
	EOH
	not_if {::File.exists?("#{node['octopus']['tentacle']['home']}\\Tentacle\\Tentacle.config")}
end
