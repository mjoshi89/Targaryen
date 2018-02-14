#
# Cookbook Name:: common
# Recipe:: default
#
# Copyright 2018, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
instance = search("aws_opsworks_instance", "self:true").first
hostname = instance[:hostname].dup
pub_ip = instance[:public_ip]
pri_ip = instance[:private_ip]
influxdb_url = "http://#{pub_ip}:8086"
common_app = search("aws_opsworks_app", "name:common").first
grafana_admin_password = common_app[:environment][:GrafanaPassword]
grafana_admin_username = common_app[:environment][:GrafanaUsername]


docker_service 'default' do
  action [:create, :start]
end

docker_image 'telegraf' do
  tag "#{node['telegraf']['release_version']}"
  action :pull
end

create_dir("#{node['common']['install_path']}/telegraf",0750)

template "#{node['common']['install_path']}/telegraf/telegraf.conf" do
  source 'telegraf.conf.erb'
  variables({
    :influxdb_url => "#{influxdb_url}"
  })
  action :create
  owner 'root'
  group 'root'
  mode 0664
end

docker_container "telegraf" do
  repo "telegraf"
  tag "#{node['telegraf']['release_version']}"
  volumes ["#{node['common']['install_path']}/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:ro", "/var/run/docker.sock:/var/run/docker.sock" ]
  port '8094:8094'
  host_name "#{hostname}"
  restart_policy 'always'
  action :run
end

bash "Grafana init" do
    code <<-EOH
    curl --user #{grafana_admin_username}:#{grafana_admin_password} 'http://#{pri_ip}:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"telegraf","isDefault":true ,"type":"influxdb","url":"http://#{pri_ip}:8086","database":"telegraf","access":"proxy","basicAuth":false}'

    curl --user #{grafana_admin_username}:#{grafana_admin_password} 'http://#{pri_ip}:3000/api/dashboards/import' -X POST -H 'Content-Type: application/json' -d '@#{node['common']['install_path']}/grafana/docker-metrics-per-container_rev2.json'
    EOH
end
