#
# Cookbook Name:: common
# Recipe:: default
#
# Copyright 2018, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
common_app = search("aws_opsworks_app", "name:common").first
influxdb_admin_username = common_app[:environment][:DBUsername]
influxdb_admin_password = common_app[:environment][:DBPassword]
influxdb_username = common_app[:environment][:DBUsername]
influxdb_password = common_app[:environment][:DBPassword]
grafana_admin_password = common_app[:environment][:GrafanaPassword]
grafana_admin_username = common_app[:environment][:GrafanaUsername]
instance = search("aws_opsworks_instance", "self:true").first
pub_ip = instance[:public_ip]


docker_service 'default' do
  action [:create, :start]
end

docker_image 'influxdb' do
  tag "#{node['influxdb']['release_version']}"
  action :pull
end

docker_image 'grafana/grafana' do
  action :pull
end

create_dir("#{node['common']['install_path']}/influxdb/data",0750)

create_dir("#{node['common']['install_path']}/grafana",0750)

cookbook_file "#{node['common']['install_path']}/influxdb/influxdb.conf" do
    source "default/influxdb.conf"
    mode "0644"
    owner 'root'
    group 'root'
end

cookbook_file "#{node['common']['install_path']}/grafana/docker-metrics-per-container_rev2.json" do
    source "default/docker-metrics-per-container_rev2.json"
    mode "0644"
    owner 'root'
    group 'root'
end


docker_container "influxdb" do
  repo "influxdb"
  tag "#{node['influxdb']['release_version']}"
  volumes ["#{node['common']['install_path']}/influxdb/data:/var/lib/influxdb", "#{node['common']['install_path']}/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf:ro" ]
  env ["INFLUXDB_ADMIN_PASSWORD=#{influxdb_admin_password}", "INFLUXDB_ADMIN_USER=#{influxdb_admin_username}", "INFLUXDB_USER_PASSWORD=#{influxdb_password}", "INFLUXDB_USER=#{influxdb_username}", "INFLUXDB_DB=telegraf", "INFLUXDB_ADMIN_ENABLED=true" ]
  port '8086:8086'
  restart_policy 'always'
  action :run
end

docker_container "grafana" do
  repo "grafana/grafana"
  tag "#{node['grafana']['release_version']}"
  volumes ["#{node['common']['install_path']}/grafana:/var/lib/grafana" ]
  env ["GF_SECURITY_ADMIN_PASSWORD=#{grafana_admin_password}", "GF_SECURITY_ADMIN_USER=#{grafana_admin_username}"]
  port '3000:3000'
  restart_policy 'always'
  action :run
end

docker_service 'default' do
  action [:restart]
end
